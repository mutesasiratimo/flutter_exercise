import 'dart:convert';

import 'package:flutter_fund/api/api_client.dart';
import 'package:flutter_fund/api/api_exception.dart';
import 'package:flutter_fund/api/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response jsonResponse(int status, Object body) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

http.Response errorResponse(int status, String code, String message, [Map<String, String>? fields]) =>
    jsonResponse(status, {
      'error': {'code': code, 'message': message, 'fields': ?fields},
    });

/// Minimal stand-in for the mock server's auth rules.
class FakeAuthServer {
  String validAccessToken = 'access-0';
  String validRefreshToken = 'refresh-0';
  int refreshCalls = 0;
  int meCalls = 0;
  bool rejectRefresh = false;
  final requests = <http.Request>[];

  late final client = MockClient((request) async {
    requests.add(request);
    await Future<void>.delayed(Duration.zero);

    switch (request.url.path) {
      case '/v1/auth/login':
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['password'] != 'Passw0rd!') {
          return errorResponse(401, 'invalid_credentials', 'Email or password is incorrect.');
        }
        return _issueTokens();
      case '/v1/auth/refresh':
        refreshCalls++;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (rejectRefresh || body['refreshToken'] != validRefreshToken) {
          return errorResponse(401, 'invalid_refresh_token', 'Refresh token is invalid or already used.');
        }
        return _issueTokens();
      case '/v1/me':
        meCalls++;
        if (request.headers['Authorization'] != 'Bearer $validAccessToken') {
          return errorResponse(401, 'token_expired', 'Access token expired. Refresh it.');
        }
        return jsonResponse(200, {'id': 'u1', 'name': 'Demo Saver', 'email': 'demo@flutterfund.test'});
      case '/v1/auth/logout':
        return http.Response('', 204);
    }
    return errorResponse(404, 'not_found', 'No route');
  });

  int _issued = 0;

  http.Response _issueTokens() {
    _issued++;
    validAccessToken = 'access-$_issued';
    validRefreshToken = 'refresh-$_issued';
    return jsonResponse(200, {
      'accessToken': validAccessToken,
      'refreshToken': validRefreshToken,
      'expiresIn': 20,
      'user': {'id': 'u1', 'name': 'Demo Saver', 'email': 'demo@flutterfund.test'},
    });
  }

  /// Simulates the access token's TTL running out.
  void expireAccessToken() => validAccessToken = '${validAccessToken}x';
}

ApiClient buildClient(http.Client httpClient, TokenStorage storage) => ApiClient(
      baseUrl: 'http://test',
      tokenStorage: storage,
      httpClient: httpClient,
      retryDelay: (_) => Duration.zero,
    );

void main() {
  group('login', () {
    test('stores both tokens and returns the user', () async {
      final server = FakeAuthServer();
      final storage = InMemoryTokenStorage();
      final api = buildClient(server.client, storage);

      final result = await api.login('demo@flutterfund.test', 'Passw0rd!');

      expect(result.user?.name, 'Demo Saver');
      final tokens = await storage.read();
      expect(tokens?.accessToken, 'access-1');
      expect(tokens?.refreshToken, 'refresh-1');
      expect(server.requests.single.headers['Content-Type'], startsWith('application/json'));
    });

    test('wrong password surfaces the server message', () async {
      final server = FakeAuthServer();
      final api = buildClient(server.client, InMemoryTokenStorage());

      await expectLater(
        api.login('demo@flutterfund.test', 'nope'),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'invalid_credentials')
            .having((e) => e.userMessage, 'userMessage', 'Email or password is incorrect.')),
      );
    });

    test('422 exposes field errors', () async {
      final client = MockClient((_) async =>
          errorResponse(422, 'validation_error', 'Invalid input.', {'email': 'Email is required.'}));
      final api = buildClient(client, InMemoryTokenStorage());

      await expectLater(
        api.login('', 'x'),
        throwsA(isA<ApiException>().having((e) => e.fields, 'fields', {'email': 'Email is required.'})),
      );
    });
  });

  group('session refresh', () {
    test('an expired token is refreshed and the request retried', () async {
      final server = FakeAuthServer();
      final storage = InMemoryTokenStorage();
      final api = buildClient(server.client, storage);
      await api.login('demo@flutterfund.test', 'Passw0rd!');
      server.expireAccessToken();

      final user = await api.me();

      expect(user.email, 'demo@flutterfund.test');
      expect(server.refreshCalls, 1);
      expect((await storage.read())?.accessToken, server.validAccessToken);
    });

    test('three requests expiring together make exactly one refresh call', () async {
      final server = FakeAuthServer();
      final api = buildClient(server.client, InMemoryTokenStorage());
      await api.login('demo@flutterfund.test', 'Passw0rd!');
      server.expireAccessToken();

      final users = await Future.wait([api.me(), api.me(), api.me()]);

      expect(users, hasLength(3));
      expect(server.refreshCalls, 1);
      expect(server.meCalls, 6);
    });

    test('a failed refresh logs the user out', () async {
      final server = FakeAuthServer()..rejectRefresh = true;
      final storage = InMemoryTokenStorage();
      final api = buildClient(server.client, storage);
      var expiredCalls = 0;
      api.onSessionExpired = () => expiredCalls++;
      await api.login('demo@flutterfund.test', 'Passw0rd!');
      server.expireAccessToken();

      await expectLater(
        Future.wait([api.me(), api.me()]),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'session_expired')),
      );

      expect(expiredCalls, 1);
      expect(await storage.read(), isNull);
      expect(await api.hasSession(), isFalse);
    });

    test('a 503 during refresh keeps the session', () async {
      var refreshCalls = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/v1/auth/refresh') {
          refreshCalls++;
          return errorResponse(503, 'service_unavailable', 'Random failure (chaos).');
        }
        return errorResponse(401, 'token_expired', 'Access token expired.');
      });
      final storage = InMemoryTokenStorage(
        const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      );
      final api = ApiClient(
        baseUrl: 'http://test',
        tokenStorage: storage,
        httpClient: client,
        maxRetries: 0,
        retryDelay: (_) => Duration.zero,
      );
      var expired = false;
      api.onSessionExpired = () => expired = true;

      await expectLater(api.me(), throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 503)));

      expect(refreshCalls, 1);
      expect(expired, isFalse);
      expect(await storage.read(), isNotNull);
    });
  });

  group('errors and retries', () {
    test('GET retries 503s up to 3 times, then succeeds', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        if (calls <= 3) return errorResponse(503, 'service_unavailable', 'chaos');
        return jsonResponse(200, {'id': 'u1', 'name': 'Demo Saver', 'email': 'd@x.io'});
      });
      final api = buildClient(
        client,
        InMemoryTokenStorage(const AuthTokens(accessToken: 'a', refreshToken: 'r')),
      );

      await api.me();

      expect(calls, 4);
    });

    test('network failures become a no-internet error', () async {
      final client = MockClient((_) async => throw http.ClientException('Connection refused'));
      final api = buildClient(client, InMemoryTokenStorage());

      await expectLater(
        api.login('demo@flutterfund.test', 'Passw0rd!'),
        throwsA(isA<ApiException>().having((e) => e.isNetworkError, 'isNetworkError', isTrue)),
      );
    });

    test('logs hide passwords and tokens', () {
      final redacted = ApiClient.redact({
        'email': 'demo@flutterfund.test',
        'password': 'Passw0rd!',
        'nested': {'accessToken': 'abc', 'refreshToken': 'def'},
      });

      expect(redacted, {
        'email': 'demo@flutterfund.test',
        'password': '***',
        'nested': {'accessToken': '***', 'refreshToken': '***'},
      });
    });
  });
}

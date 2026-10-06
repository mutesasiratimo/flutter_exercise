import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/login.dart';
import '../utils/constants.dart';
import 'api_exception.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenStorage,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 3,
    Duration Function(int attempt)? retryDelay,
  })  : _http = httpClient ?? http.Client(),
        _retryDelay = retryDelay ?? _defaultRetryDelay;

  final String baseUrl;
  final TokenStorage tokenStorage;
  final Duration timeout;
  final int maxRetries;
  final http.Client _http;
  final Duration Function(int attempt) _retryDelay;

  /// Called once when the session can't be renewed (refresh token rejected).
  VoidCallback? onSessionExpired;

  AuthTokens? _tokens;
  bool _tokensLoaded = false;
  Future<AuthTokens>? _refreshing;

  static Duration _defaultRetryDelay(int attempt) =>
      Duration(milliseconds: 300 * (1 << attempt));

  Future<bool> hasSession() async => await _currentTokens() != null;

  Future<LoginResponseModel> login(String email, String password) async {
    final response = await _send(
      'POST',
      Constants.loginEndpoint,
      body: {'email': email, 'password': password},
    );
    final login = LoginResponseModel.fromJson(_decode(response));
    await _saveTokens(AuthTokens(
      accessToken: login.accessToken,
      refreshToken: login.refreshToken,
    ));
    return login;
  }

  /// Best effort: the local session is cleared even if the server call fails.
  Future<void> logout() async {
    final tokens = await _currentTokens();
    try {
      if (tokens != null) {
        await _send('POST', Constants.logoutEndpoint, accessToken: tokens.accessToken);
      }
    } on ApiException {
      // Ignored: the user is logging out either way.
    } finally {
      await _clearTokens();
    }
  }

  Future<AuthUser> me() async {
    final json = await get(Constants.meEndpoint);
    return AuthUser.fromJson(json!);
  }

  Future<Map<String, dynamic>?> get(String path) => request('GET', path);

  /// Authenticated request. Renews the session once on `token_expired`, and
  /// retries GETs on network errors and 503s with exponential backoff.
  Future<Map<String, dynamic>?> request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final retries = method == 'GET' ? maxRetries : 0;
    for (var attempt = 0;; attempt++) {
      try {
        return await _authenticatedRequest(method, path, body: body, headers: headers);
      } on ApiException catch (e) {
        if (!e.isRetryable || attempt >= retries) rethrow;
        await Future<void>.delayed(_retryDelay(attempt));
      }
    }
  }

  Future<Map<String, dynamic>?> _authenticatedRequest(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final tokens = await _currentTokens();
    if (tokens == null) throw const ApiException.sessionExpired();

    try {
      return _decodeOrNull(await _send(method, path,
          body: body, headers: headers, accessToken: tokens.accessToken));
    } on ApiException catch (e) {
      if (!e.isTokenExpired) rethrow;
    }

    final fresh = await _renewSession(tokens.accessToken);
    return _decodeOrNull(await _send(method, path,
        body: body, headers: headers, accessToken: fresh.accessToken));
  }

  /// Every caller that hit `token_expired` with the same stale token shares a
  /// single refresh call, because each refresh token can only be used once.
  Future<AuthTokens> _renewSession(String staleAccessToken) {
    final current = _tokens;
    if (current != null && current.accessToken != staleAccessToken) {
      return Future.value(current);
    }
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Future<AuthTokens> _refresh() async {
    final refreshToken = _tokens?.refreshToken;
    if (refreshToken == null) {
      await _expireSession();
      throw const ApiException.sessionExpired();
    }

    for (var attempt = 0;; attempt++) {
      try {
        final response = await _send(
          'POST',
          Constants.refreshTokenEndpoint,
          body: {'refreshToken': refreshToken},
        );
        final login = LoginResponseModel.fromJson(_decode(response));
        final tokens = AuthTokens(
          accessToken: login.accessToken,
          refreshToken: login.refreshToken,
        );
        await _saveTokens(tokens);
        return tokens;
      } on ApiException catch (e) {
        // A network blip or 503 doesn't mean the session is dead, so keep the
        // tokens and let the user retry. Anything else means log out.
        if (e.isRetryable) {
          if (attempt < maxRetries) {
            await Future<void>.delayed(_retryDelay(attempt));
            continue;
          }
          rethrow;
        }
        await _expireSession();
        throw const ApiException.sessionExpired();
      }
    }
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
    String? accessToken,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers.addAll({
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        ...?headers,
      });
    if (body != null) request.body = jsonEncode(body);

    _log('→ $method $path ${body == null ? '' : jsonEncode(redact(body))}');
    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(timeout),
      );
    } on TimeoutException {
      _log('✕ $method $path timed out');
      throw const ApiException.network();
    } on http.ClientException catch (e) {
      _log('✕ $method $path ${e.message}');
      throw const ApiException.network();
    }
    _log('← ${response.statusCode} $method $path ${_redactBody(response.body)}');

    if (response.statusCode >= 400) throw ApiException.fromResponse(response);
    return response;
  }

  Future<AuthTokens?> _currentTokens() async {
    if (!_tokensLoaded) {
      _tokens = await tokenStorage.read();
      _tokensLoaded = true;
    }
    return _tokens;
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
    _tokensLoaded = true;
    await tokenStorage.write(tokens);
  }

  Future<void> _clearTokens() async {
    _tokens = null;
    _tokensLoaded = true;
    await tokenStorage.clear();
  }

  Future<void> _expireSession() async {
    await _clearTokens();
    onSessionExpired?.call();
  }

  Map<String, dynamic> _decode(http.Response response) =>
      jsonDecode(response.body) as Map<String, dynamic>;

  Map<String, dynamic>? _decodeOrNull(http.Response response) =>
      response.body.isEmpty ? null : _decode(response);

  static const _secretKeys = {'password', 'accessToken', 'refreshToken'};

  @visibleForTesting
  static Object? redact(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key: _secretKeys.contains(entry.key) ? '***' : redact(entry.value),
      };
    }
    if (value is List) return value.map(redact).toList();
    return value;
  }

  String _redactBody(String body) {
    if (body.isEmpty) return '';
    try {
      return jsonEncode(redact(jsonDecode(body)));
    } on FormatException {
      return '<non-JSON body>';
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[api] $message');
  }
}

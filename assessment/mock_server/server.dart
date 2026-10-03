// FlutterFund mock backend (Tasks 5, 6 and 9).
//
// Run:  dart run assessment/mock_server/server.dart [options]
//
//   --port=8080            Port to listen on.
//   --latency-ms=300       Artificial latency added to every request.
//   --failure-rate=0.0     Probability (0..1) of a random 503 on /v1 routes.
//   --token-ttl=60         Access token lifetime in seconds.
//
// Send the header `X-Chaos: off` to bypass latency and random failures
// (useful in integration tests). See assessment/tasks/task_05_backend_login.md
// for the API contract.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

final _random = Random();

late final int _port;
late final int _latencyMs;
late final double _failureRate;
late final int _tokenTtl;

const _demoUser = {
  'id': 'u1',
  'name': 'Demo Saver',
  'email': 'demo@flutterfund.test',
};
const _demoPassword = 'Passw0rd!';

class _Session {
  _Session(this.userId, this.expiresAt);
  final String userId;
  final DateTime expiresAt;
}

final _accessTokens = <String, _Session>{};
final _refreshTokens = <String, String>{};
final _goals = <String, Map<String, dynamic>>{};
final _contributions = <String, List<Map<String, dynamic>>>{};
final _idempotency = <String, _CachedResponse>{};
var _nextGoalId = 1;
var _nextContributionId = 1;

class _CachedResponse {
  _CachedResponse(this.status, this.body, this.fingerprint);
  final int status;
  final Object body;
  final String fingerprint;
}

Future<void> main(List<String> args) async {
  final opts = {
    for (final a in args.where((a) => a.startsWith('--') && a.contains('=')))
      a.substring(2, a.indexOf('=')): a.substring(a.indexOf('=') + 1),
  };
  _port = int.parse(opts['port'] ?? '8080');
  _latencyMs = int.parse(opts['latency-ms'] ?? '300');
  _failureRate = double.parse(opts['failure-rate'] ?? '0.0');
  _tokenTtl = int.parse(opts['token-ttl'] ?? '60');

  _seed();

  final server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
  stdout.writeln(
    'FlutterFund mock API on http://localhost:$_port '
    '(latency=${_latencyMs}ms, failure-rate=$_failureRate, '
    'token-ttl=${_tokenTtl}s)',
  );
  stdout.writeln('Android emulator: http://10.0.2.2:$_port');
  stdout.writeln('Login: ${_demoUser['email']} / $_demoPassword');

  await for (final request in server) {
    _handle(request);
  }
}

void _seed() {
  const titles = [
    'Emergency fund', 'New laptop', 'School fees', 'Wedding', 'Car',
    'Holiday in Zanzibar', 'Land in Mukono', 'Phone upgrade', 'Business stock',
    'Medical cover',
  ];
  const currencies = ['UGX', 'UGX', 'UGX', 'USD', 'KES'];
  final now = DateTime.now().toUtc();
  for (var i = 0; i < 45; i++) {
    final currency = currencies[i % currencies.length];
    final scale = currency == 'UGX' ? 1000 : 100;
    final target = (50 + _random.nextInt(950)) * scale * 10;
    final saved = i % 7 == 0 ? target : (target * _random.nextDouble()).round();
    final id = 'g${_nextGoalId++}';
    _goals[id] = {
      'id': id,
      'title': '${titles[i % titles.length]}${i >= titles.length ? ' #${i ~/ titles.length + 1}' : ''}',
      'target': {'amountMinor': target, 'currency': currency},
      'saved': {'amountMinor': saved, 'currency': currency},
      'deadline': i % 3 == 0
          ? null
          : now.add(Duration(days: -30 + _random.nextInt(365))).toIso8601String(),
      'status': i % 11 == 10
          ? 'archived'
          : saved >= target
              ? 'completed'
              : 'active',
      'updatedAt': now.subtract(Duration(minutes: i)).toIso8601String(),
    };
    _contributions[id] = [];
  }
}

Future<void> _handle(HttpRequest req) async {
  final res = req.response;
  res.headers.contentType = ContentType.json;
  final chaos = req.headers.value('x-chaos') != 'off';
  final path = req.uri.path;
  final started = DateTime.now();

  try {
    if (chaos && _latencyMs > 0) {
      await Future<void>.delayed(
        Duration(milliseconds: _latencyMs ~/ 2 + _random.nextInt(_latencyMs + 1)),
      );
    }
    if (path == '/health') return _send(res, 200, {'status': 'ok'});

    if (chaos && path.startsWith('/v1') && _random.nextDouble() < _failureRate) {
      return _error(res, 503, 'service_unavailable', 'Random failure (chaos).');
    }

    final body = await _readJson(req);
    final segments = req.uri.pathSegments;

    if (req.method == 'POST' && path == '/v1/auth/login') return _login(res, body);
    if (req.method == 'POST' && path == '/v1/auth/refresh') return _refresh(res, body);

    final session = _authenticate(req, res);
    if (session == null) return;

    if (req.method == 'POST' && path == '/v1/auth/logout') {
      _accessTokens.remove(_bearer(req));
      _refreshTokens.removeWhere((_, userId) => userId == session.userId);
      return _send(res, 204, null);
    }
    if (req.method == 'GET' && path == '/v1/me') return _send(res, 200, _demoUser);

    if (segments.length >= 2 && segments[0] == 'v1' && segments[1] == 'goals') {
      if (segments.length == 2) {
        if (req.method == 'GET') return _listGoals(req, res);
        if (req.method == 'POST') return _createGoal(res, body);
      }
      final goal = segments.length >= 3 ? _goals[segments[2]] : null;
      if (goal == null) return _error(res, 404, 'not_found', 'Goal not found.');
      if (segments.length == 3 && req.method == 'GET') return _send(res, 200, _public(goal));
      if (segments.length == 4 && segments[3] == 'contributions') {
        if (req.method == 'GET') {
          return _send(res, 200, {'data': _contributions[goal['id']]});
        }
        if (req.method == 'POST') return _contribute(req, res, goal, body);
      }
    }
    return _error(res, 404, 'not_found', 'No route for ${req.method} $path');
  } on FormatException catch (e) {
    return _error(res, 400, 'bad_request', 'Malformed JSON: ${e.message}');
  } finally {
    final ms = DateTime.now().difference(started).inMilliseconds;
    stdout.writeln('${req.method} ${req.uri} -> ${res.statusCode} (${ms}ms)');
  }
}

Future<Map<String, dynamic>> _readJson(HttpRequest req) async {
  final text = await utf8.decoder.bind(req).join();
  if (text.trim().isEmpty) return {};
  final decoded = jsonDecode(text);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Expected a JSON object');
  }
  return decoded;
}

String? _bearer(HttpRequest req) {
  final header = req.headers.value(HttpHeaders.authorizationHeader);
  if (header == null || !header.startsWith('Bearer ')) return null;
  return header.substring(7);
}

_Session? _authenticate(HttpRequest req, HttpResponse res) {
  final token = _bearer(req);
  final session = token == null ? null : _accessTokens[token];
  if (session == null) {
    _error(res, 401, 'unauthorized', 'Missing or invalid access token.');
    return null;
  }
  if (DateTime.now().isAfter(session.expiresAt)) {
    _accessTokens.remove(token);
    _error(res, 401, 'token_expired', 'Access token expired. Refresh it.');
    return null;
  }
  return session;
}

void _issueTokens(HttpResponse res, String userId) {
  final access = _token();
  final refresh = _token();
  _accessTokens[access] = _Session(
    userId,
    DateTime.now().add(Duration(seconds: _tokenTtl)),
  );
  _refreshTokens[refresh] = userId;
  _send(res, 200, {
    'accessToken': access,
    'refreshToken': refresh,
    'expiresIn': _tokenTtl,
    'user': _demoUser,
  });
}

void _login(HttpResponse res, Map<String, dynamic> body) {
  final email = body['email'];
  final password = body['password'];
  final fields = <String, String>{
    if (email is! String || email.isEmpty) 'email': 'Email is required.',
    if (password is! String || password.isEmpty) 'password': 'Password is required.',
  };
  if (fields.isNotEmpty) {
    return _error(res, 422, 'validation_error', 'Invalid input.', fields: fields);
  }
  if (email != _demoUser['email'] || password != _demoPassword) {
    return _error(res, 401, 'invalid_credentials', 'Email or password is incorrect.');
  }
  _issueTokens(res, _demoUser['id']!);
}

void _refresh(HttpResponse res, Map<String, dynamic> body) {
  final token = body['refreshToken'];
  final userId = token is String ? _refreshTokens.remove(token) : null;
  if (userId == null) {
    return _error(res, 401, 'invalid_refresh_token', 'Refresh token is invalid or already used.');
  }
  _issueTokens(res, userId);
}

void _listGoals(HttpRequest req, HttpResponse res) {
  final page = int.tryParse(req.uri.queryParameters['page'] ?? '1') ?? 1;
  final pageSize = (int.tryParse(req.uri.queryParameters['pageSize'] ?? '20') ?? 20).clamp(1, 50);
  final status = req.uri.queryParameters['status'];
  final query = req.uri.queryParameters['q']?.toLowerCase();
  final updatedSince = DateTime.tryParse(req.uri.queryParameters['updatedSince'] ?? '');

  final all = _goals.values.where((g) {
    if (status != null && g['status'] != status) return false;
    if (query != null && !(g['title'] as String).toLowerCase().contains(query)) return false;
    if (updatedSince != null &&
        !DateTime.parse(g['updatedAt'] as String).isAfter(updatedSince)) {
      return false;
    }
    return true;
  }).toList();
  final start = (page - 1) * pageSize;
  final slice = start >= all.length ? <Map<String, dynamic>>[] : all.skip(start).take(pageSize);
  _send(res, 200, {
    'data': slice.map(_public).toList(),
    'page': page,
    'pageSize': pageSize,
    'total': all.length,
    'hasMore': start + pageSize < all.length,
  });
}

void _createGoal(HttpResponse res, Map<String, dynamic> body) {
  final title = body['title'];
  final target = body['target'];
  final deadline = body['deadline'];
  final fields = <String, String>{};
  if (title is! String || title.trim().length < 3) {
    fields['title'] = 'Title must be at least 3 characters.';
  }
  if (target is! Map ||
      target['amountMinor'] is! int ||
      (target['amountMinor'] as int) <= 0 ||
      !const ['UGX', 'USD', 'EUR', 'KES'].contains(target['currency'])) {
    fields['target'] = 'Target must be a positive amount in UGX, USD, EUR or KES.';
  }
  if (deadline != null && (deadline is! String || DateTime.tryParse(deadline) == null)) {
    fields['deadline'] = 'Deadline must be an ISO-8601 date.';
  }
  if (fields.isNotEmpty) {
    return _error(res, 422, 'validation_error', 'Invalid goal.', fields: fields);
  }
  final id = 'g${_nextGoalId++}';
  final t = target as Map;
  _goals[id] = {
    'id': id,
    'title': (title as String).trim(),
    'target': {'amountMinor': t['amountMinor'], 'currency': t['currency']},
    'saved': {'amountMinor': 0, 'currency': t['currency']},
    'deadline': deadline == null ? null : DateTime.parse(deadline as String).toUtc().toIso8601String(),
    'status': 'active',
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
  };
  _contributions[id] = [];
  _send(res, 201, _public(_goals[id]!));
}

void _contribute(
  HttpRequest req,
  HttpResponse res,
  Map<String, dynamic> goal,
  Map<String, dynamic> body,
) {
  final key = req.headers.value('idempotency-key');
  if (key == null || key.isEmpty) {
    return _error(res, 400, 'idempotency_key_required', 'Send an Idempotency-Key header.');
  }
  final fingerprint = '${goal['id']}:${jsonEncode(body)}';
  final cached = _idempotency[key];
  if (cached != null) {
    if (cached.fingerprint != fingerprint) {
      return _error(res, 409, 'idempotency_conflict', 'Key reused with a different payload.');
    }
    res.headers.set('Idempotent-Replayed', 'true');
    return _send(res, cached.status, cached.body);
  }

  final amount = body['amount'];
  final saved = goal['saved'] as Map<String, dynamic>;
  if (amount is! Map ||
      amount['amountMinor'] is! int ||
      (amount['amountMinor'] as int) <= 0) {
    return _error(res, 422, 'validation_error', 'Invalid contribution.',
        fields: {'amount': 'Amount must be a positive integer of minor units.'});
  }
  if (amount['currency'] != saved['currency']) {
    return _error(res, 422, 'validation_error', 'Invalid contribution.',
        fields: {'amount': 'Currency must be ${saved['currency']}.'});
  }
  if (goal['status'] != 'active') {
    return _error(res, 409, 'goal_not_active', 'Only active goals accept contributions.');
  }

  final newSaved = (saved['amountMinor'] as int) + (amount['amountMinor'] as int);
  saved['amountMinor'] = newSaved;
  if (newSaved >= ((goal['target'] as Map)['amountMinor'] as int)) {
    goal['status'] = 'completed';
  }
  goal['updatedAt'] = DateTime.now().toUtc().toIso8601String();
  final contribution = {
    'id': 'c${_nextContributionId++}',
    'goalId': goal['id'],
    'amount': {'amountMinor': amount['amountMinor'], 'currency': amount['currency']},
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };
  _contributions[goal['id']]!.add(contribution);
  final responseBody = {'contribution': contribution, 'goal': _public(goal)};
  _idempotency[key] = _CachedResponse(201, responseBody, fingerprint);
  _send(res, 201, responseBody);
}

Map<String, dynamic> _public(Map<String, dynamic> goal) => {
      for (final e in goal.entries) e.key: e.value,
    };

String _token() =>
    base64Url.encode(List.generate(24, (_) => _random.nextInt(256))).replaceAll('=', '');

void _error(
  HttpResponse res,
  int status,
  String code,
  String message, {
  Map<String, String>? fields,
}) {
  _send(res, status, {
    'error': {'code': code, 'message': message, 'fields': ?fields},
  });
}

void _send(HttpResponse res, int status, Object? body) {
  res.statusCode = status;
  if (body != null) res.write(jsonEncode(body));
  res.close();
}

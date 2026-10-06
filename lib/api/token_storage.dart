import 'package:shared_preferences/shared_preferences.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});
}

abstract class TokenStorage {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

/// Not encrypted. Production should use the Keychain / Keystore
/// (e.g. flutter_secure_storage) behind this same interface.
class SharedPrefsTokenStorage implements TokenStorage {
  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';

  @override
  Future<AuthTokens?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_accessKey);
    final refresh = prefs.getString(_refreshKey);
    if (access == null || refresh == null) return null;
    return AuthTokens(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, tokens.accessToken);
    await prefs.setString(_refreshKey, tokens.refreshToken);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }
}

class InMemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  InMemoryTokenStorage([this._tokens]);

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> write(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

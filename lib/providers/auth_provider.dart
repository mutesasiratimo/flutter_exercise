import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/login.dart';

enum AuthStatus { unknown, signedOut, signedIn, sessionExpired }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api) {
    _api.onSessionExpired = _handleSessionExpired;
  }

  final ApiClient _api;

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _user;

  AuthStatus get status => _status;
  AuthUser? get user => _user;

  Future<void> restoreSession() async {
    final hasSession = await _api.hasSession();
    _setStatus(hasSession ? AuthStatus.signedIn : AuthStatus.signedOut);
  }

  /// Throws [ApiException] so the login form can show the server's message.
  Future<void> login(String email, String password) async {
    final response = await _api.login(email, password);
    _user = response.user;
    _setStatus(AuthStatus.signedIn);
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _setStatus(AuthStatus.signedOut);
  }

  void _handleSessionExpired() {
    if (_status != AuthStatus.signedIn) return;
    _user = null;
    _setStatus(AuthStatus.sessionExpired);
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}

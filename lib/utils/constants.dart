import 'package:flutter/foundation.dart';

class Constants {
  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Pass `--dart-define=API_BASE_URL=http://<host>:8080` to override.
  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080'
        : 'http://localhost:8080';
  }

  static const String loginEndpoint = '/v1/auth/login';
  static const String logoutEndpoint = '/v1/auth/logout';
  static const String refreshTokenEndpoint = '/v1/auth/refresh';
  static const String meEndpoint = '/v1/me';
}

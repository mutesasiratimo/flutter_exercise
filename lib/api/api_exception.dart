import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String code;
  final String message;
  final Map<String, String> fields;

  const ApiException({
    this.statusCode,
    required this.code,
    required this.message,
    this.fields = const {},
  });

  const ApiException.network()
      : statusCode = null,
        code = 'network_error',
        message = 'No internet connection.',
        fields = const {};

  const ApiException.sessionExpired()
      : statusCode = 401,
        code = 'session_expired',
        message = 'Your session has expired.',
        fields = const {};

  factory ApiException.fromResponse(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>;
      final fields = error['fields'] as Map<String, dynamic>?;
      return ApiException(
        statusCode: response.statusCode,
        code: error['code'] as String? ?? 'unknown',
        message: error['message'] as String? ?? 'Something went wrong.',
        fields: {
          for (final entry in (fields ?? const {}).entries)
            entry.key: entry.value.toString(),
        },
      );
    } catch (_) {
      return ApiException(
        statusCode: response.statusCode,
        code: 'unknown',
        message: 'Unexpected response (${response.statusCode}).',
      );
    }
  }

  bool get isNetworkError => code == 'network_error';
  bool get isTokenExpired => statusCode == 401 && code == 'token_expired';
  bool get isRetryable => isNetworkError || statusCode == 503;

  String get userMessage {
    if (isNetworkError) return 'No internet connection. Check your network and try again.';
    if (code == 'invalid_credentials') return message;
    return switch (statusCode) {
      401 => 'Your session has expired. Please log in again.',
      404 => "We couldn't find what you were looking for.",
      422 => 'Please fix the highlighted fields.',
      final status? when status >= 500 => 'Something went wrong on our side. Please try again.',
      _ => message,
    };
  }

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

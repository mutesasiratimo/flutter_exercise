import 'package:flutter/material.dart';

/// The app's semantic colours. `success`, `info` and `warning` aren't in
/// Material's [ColorScheme]; `error` mirrors [ColorScheme.error] so every
/// status colour can be read from one place.
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color onSuccess;
  final Color info;
  final Color onInfo;
  final Color warning;
  final Color onWarning;
  final Color error;
  final Color onError;

  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.info,
    required this.onInfo,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
  });

  static const light = AppColors(
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    info: Color(0xFF1565C0),
    onInfo: Color(0xFFFFFFFF),
    warning: Color(0xFFFFB300),
    onWarning: Color(0xFF000000),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    success: Color(0xFF81C784),
    onSuccess: Color(0xFF000000),
    info: Color(0xFF64B5F6),
    onInfo: Color(0xFF000000),
    warning: Color(0xFFFFD54F),
    onWarning: Color(0xFF000000),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
  );

  /// Builds the palette for [scheme], taking `error` from the scheme so it
  /// can't drift from the red Material widgets use.
  factory AppColors.fromScheme(ColorScheme scheme) {
    final base = scheme.brightness == Brightness.dark ? dark : light;
    return base.copyWith(error: scheme.error, onError: scheme.onError);
  }

  /// Falls back to [AppColors.fromScheme] when a theme hasn't registered the
  /// extension, e.g. in widget tests.
  static AppColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppColors>() ??
        AppColors.fromScheme(theme.colorScheme);
  }

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? info,
    Color? onInfo,
    Color? warning,
    Color? onWarning,
    Color? error,
    Color? onError,
  }) {
    return AppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      error: error ?? this.error,
      onError: onError ?? this.onError,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
    );
  }
}

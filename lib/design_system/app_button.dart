import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'design_constants.dart';

enum AppButtonStyle { primary, success, info, warning, danger }

class AppButton extends StatefulWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;
  final AppButtonStyle style;
  final Icon? icon;
  const AppButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.icon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  (Color background, Color foreground) _colors(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);
    return switch (widget.style) {
      AppButtonStyle.primary => (scheme.primary, scheme.onPrimary),
      AppButtonStyle.success => (appColors.success, appColors.onSuccess),
      AppButtonStyle.info => (appColors.info, appColors.onInfo),
      AppButtonStyle.warning => (appColors.warning, appColors.onWarning),
      AppButtonStyle.danger => (appColors.error, appColors.onError),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors(context);

    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: EdgeInsets.symmetric(horizontal: DesignConstants.padding, vertical: DesignConstants.padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.borderRadius),
        ),
      ),
      child: widget.isLoading ? const CircularProgressIndicator() : (widget.icon != null ? Row(children: [widget.icon!, Text(widget.label)],) : Text(widget.label)),
      );
  }
}

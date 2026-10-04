import 'package:flutter/material.dart';

import 'app_colors.dart';

class GoalProgressBar extends StatefulWidget {
  final double progress;
  final Color? color;
  final String? label;
  const GoalProgressBar({super.key, required this.progress, required this.color, this.label,});

  @override
  State<GoalProgressBar> createState() => _GoalProgressBarState();
}

class _GoalProgressBarState extends State<GoalProgressBar> {
  Color _color(BuildContext context, double progress) {
    final colors = AppColors.of(context);
    return progress <= 0.5 ? colors.warning : colors.success;
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: widget.progress,
      color: widget.color ?? _color(context, widget.progress),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
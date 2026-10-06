import 'package:flutter/material.dart';

import '../design_system/screen_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget narrow;
  final Widget? large;
  const ResponsiveLayout({super.key, required this.narrow, this.large});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width > ScreenBreakpoints.tablet) {
          return large ?? narrow;
        } else {
          return narrow;
        }
      },
    );
  }
}
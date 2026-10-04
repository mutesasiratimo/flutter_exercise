import 'package:flutter/material.dart';
import 'package:flutter_fund/design_system/app_colors.dart';
import 'package:flutter_fund/design_system/app_button.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppColors> readColors(WidgetTester tester, ThemeData theme) async {
  late AppColors colors;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          colors = AppColors.of(context);
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return colors;
}

void main() {
  group('AppColors', () {
    testWidgets('reads the registered light and dark extensions',
        (tester) async {
      final light = await readColors(
        tester,
        ThemeData(extensions: const [AppColors.light]),
      );
      expect(light.success, AppColors.light.success);

      final dark = await readColors(
        tester,
        ThemeData(
          brightness: Brightness.dark,
          extensions: const [AppColors.dark],
        ),
      );
      expect(dark.success, AppColors.dark.success);
    });

    testWidgets('falls back by brightness when not registered',
        (tester) async {
      final dark = await readColors(
        tester,
        ThemeData(brightness: Brightness.dark),
      );
      expect(dark.warning, AppColors.dark.warning);
    });

    test('fromScheme takes error from the ColorScheme', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      );
      final colors = AppColors.fromScheme(scheme);
      expect(colors.error, scheme.error);
      expect(colors.onError, scheme.onError);
      expect(colors.success, AppColors.dark.success);
    });

    test('lerp blends halfway between two palettes', () {
      final mid = AppColors.light.lerp(AppColors.dark, 0.5);
      expect(
        mid.success,
        Color.lerp(AppColors.light.success, AppColors.dark.success, 0.5),
      );
    });

    testWidgets('AppButton success style uses the extension colours',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColors.light]),
          home: Scaffold(
            body: AppButton(
              label: 'Save',
              isLoading: false,
              style: AppButtonStyle.success,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final background = button.style!.backgroundColor!.resolve({});
      expect(background, AppColors.light.success);
    });
  });
}

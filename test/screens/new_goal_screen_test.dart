import 'package:flutter/material.dart';
import 'package:flutter_fund/screens/new_goal_screen.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpNewGoalScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: NewGoalScreen()));
}

void main() {
  group('NewGoalScreen', () {
    testWidgets('shows the title, the form fields and UGX by default',
        (tester) async {
      await pumpNewGoalScreen(tester);

      expect(find.text('New Goal'), findsOneWidget);
      expect(find.text('Goal Name'), findsOneWidget);
      expect(find.text('Target Amount'), findsOneWidget);
      expect(find.text('UGX'), findsOneWidget);
    });

    testWidgets('accepts a goal name and a target amount', (tester) async {
      await pumpNewGoalScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'Laptop');
      await tester.enterText(find.byType(TextField).at(1), '2000000');
      await tester.pump();

      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('2000000'), findsOneWidget);
    });

    testWidgets('changing the currency updates the dropdown', (tester) async {
      await pumpNewGoalScreen(tester);

      await tester.tap(find.text('UGX'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('USD').last);
      await tester.pumpAndSettle();

      expect(find.text('USD'), findsOneWidget);
      expect(find.text('UGX'), findsNothing);
    });
  });
}

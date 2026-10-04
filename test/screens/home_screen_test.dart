import 'package:flutter/material.dart';
import 'package:flutter_fund/screens/goal_details_screen.dart';
import 'package:flutter_fund/screens/home_screen.dart';
import 'package:flutter_fund/screens/new_goal_screen.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpHomeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
}

Finder buttonContaining(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
    );

void main() {
  group('HomeScreen', () {
    testWidgets('shows the title, a zero total and five goals', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('FlutterFund'), findsOneWidget);
      expect(find.text('Total Amount Saved: UGX 0'), findsOneWidget);
      for (final name in [
        'New phone',
        'Vacation',
        'Car',
        'Laptop',
        'Rainy Day',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Add UGX 10,000'), findsNWidgets(5));
    });

    testWidgets('tapping Add UGX 10,000 updates the card and the total',
        (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('UGX 10,000 of UGX 100,000 (10%)'), findsNothing);

      await tester.tap(find.text('Add UGX 10,000').first);
      await tester.pump();

      expect(find.text('UGX 10,000 of UGX 100,000 (10%)'), findsOneWidget);
      expect(find.text('Total Amount Saved: UGX 10,000'), findsOneWidget);
    });

    testWidgets('adding to two goals sums the total across goals',
        (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('Add UGX 10,000').at(0));
      await tester.pump();
      await tester.tap(find.text('Add UGX 10,000').at(1));
      await tester.pump();

      expect(find.text('UGX 10,000 of UGX 100,000 (10%)'), findsNWidgets(2));
      expect(find.text('Total Amount Saved: UGX 20,000'), findsOneWidget);
    });

    testWidgets('a goal that reaches its target is completed and disabled',
        (tester) async {
      await pumpHomeScreen(tester);

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('Add UGX 10,000').first);
        await tester.pump();
      }

      expect(find.text('UGX 100,000 of UGX 100,000 (100%)'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Add UGX 10,000'), findsNWidgets(4));

      final button = tester.widget<ElevatedButton>(
        buttonContaining('Completed'),
      );
      expect(button.onPressed, isNull);
      expect(find.text('Total Amount Saved: UGX 100,000'), findsOneWidget);
    });

    testWidgets('tapping a completed goal button does not add more money',
        (tester) async {
      await pumpHomeScreen(tester);

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('Add UGX 10,000').first);
        await tester.pump();
      }
      await tester.tap(find.text('Completed'), warnIfMissed: false);
      await tester.pump();

      expect(find.text('UGX 100,000 of UGX 100,000 (100%)'), findsOneWidget);
      expect(find.text('Total Amount Saved: UGX 100,000'), findsOneWidget);
    });

    testWidgets('tapping a goal opens its details screen', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('Laptop'));
      await tester.pumpAndSettle();

      expect(find.byType(GoalDetailsScreen), findsOneWidget);
      expect(find.text('Goal Details'), findsOneWidget);
    });

    testWidgets('tapping the add button opens the new goal screen',
        (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();

      expect(find.byType(NewGoalScreen), findsOneWidget);
      expect(find.text('New Goal'), findsOneWidget);
    });
  });
}

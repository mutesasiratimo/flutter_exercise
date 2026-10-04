import 'package:flutter/material.dart';
import 'package:flutter_fund/models/contribution.dart';
import 'package:flutter_fund/models/goal.dart';
import 'package:flutter_fund/screens/goal_details_screen.dart';
import 'package:flutter_fund/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrapDetails(
  Goal goal, {
  DateTime Function()? now,
  ValueChanged<Money>? onAddContribution,
}) {
  return MaterialApp(
    home: GoalDetailsScreen(
      goal: goal,
      now: now,
      onAddContribution: onAddContribution ?? (_) {},
    ),
  );
}

void main() {
  group('GoalDetailsScreen', () {
    testWidgets('shows the title, name, amounts and progress', (tester) async {
      final goal = Goal(
        goalName: 'School fees',
        targetAmount: const Money(2000000, Currency.ugx),
        savedAmount: const Money(500000, Currency.ugx),
        contributions: [],
      );

      await tester.pumpWidget(wrapDetails(goal));

      expect(find.text('Goal Details'), findsOneWidget);
      expect(find.text('School fees'), findsOneWidget);
      expect(find.text('UGX 500,000 of UGX 2,000,000'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('No contributions yet'), findsOneWidget);
    });

    Future<void> pumpDeadline(
      WidgetTester tester, {
      required DateTime now,
      required DateTime deadline,
    }) async {
      final goal = Goal(
        goalName: 'Laptop',
        targetAmount: const Money(100000, Currency.ugx),
        savedAmount: const Money.zero(Currency.ugx),
        contributions: [],
        targetDate: deadline,
      );
      await tester.pumpWidget(wrapDetails(goal, now: () => now));
    }

    testWidgets('shows days left for a future deadline', (tester) async {
      await pumpDeadline(
        tester,
        now: DateTime(2026, 10, 4),
        deadline: DateTime(2026, 10, 16),
      );
      expect(find.text('12 days left'), findsOneWidget);
    });

    testWidgets('shows Due today for today\'s deadline', (tester) async {
      await pumpDeadline(
        tester,
        now: DateTime(2026, 10, 4),
        deadline: DateTime(2026, 10, 4),
      );
      expect(find.text('Due today'), findsOneWidget);
    });

    testWidgets('shows days overdue for a past deadline', (tester) async {
      await pumpDeadline(
        tester,
        now: DateTime(2026, 10, 4),
        deadline: DateTime(2026, 10, 1),
      );
      expect(find.text('3 days overdue'), findsOneWidget);
    });

    testWidgets('lists contributions newest first', (tester) async {
      final goal = Goal(
        goalName: 'Laptop',
        targetAmount: const Money(100000, Currency.ugx),
        savedAmount: const Money(30000, Currency.ugx),
        contributions: [
          Contribution(
            amount: const Money(10000, Currency.ugx),
            date: DateTime(2026, 10, 1),
          ),
          Contribution(
            amount: const Money(20000, Currency.ugx),
            date: DateTime(2026, 10, 3),
          ),
        ],
      );

      await tester.pumpWidget(wrapDetails(goal));

      final first = tester.getTopLeft(find.text('UGX 20,000'));
      final second = tester.getTopLeft(find.text('UGX 10,000'));
      expect(first.dy < second.dy, isTrue);
    });

    testWidgets('amount over the remaining shows an error', (tester) async {
      final goal = Goal(
        goalName: 'Laptop',
        targetAmount: const Money(100000, Currency.ugx),
        savedAmount: const Money(90000, Currency.ugx),
        contributions: [],
      );

      await tester.pumpWidget(wrapDetails(goal));
      await tester.tap(find.text('Add Contribution'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '20000');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(
        find.text('Amount exceeds the remaining UGX 10,000'),
        findsOneWidget,
      );
    });

    testWidgets('a valid amount updates the goal', (tester) async {
      Money? received;
      final goal = Goal(
        goalName: 'Laptop',
        targetAmount: const Money(100000, Currency.ugx),
        savedAmount: const Money.zero(Currency.ugx),
        contributions: [],
      );

      await tester.pumpWidget(
        wrapDetails(goal, onAddContribution: (amount) => received = amount),
      );
      await tester.tap(find.text('Add Contribution'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '25000');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(received, const Money(25000, Currency.ugx));
      expect(find.text('UGX 25,000 of UGX 100,000'), findsOneWidget);
      expect(find.text('UGX 25,000'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_fund/models/contribution.dart';
import 'package:flutter_fund/models/goal.dart';
import 'package:flutter_fund/screens/new_goal_screen.dart';
import 'package:flutter_fund/utils/money.dart';
import 'package:flutter_fund/widgets/goal_card.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Goal> savingsGoals = [
    Goal(
      goalName: 'New phone',
      targetAmount: const Money(100000, Currency.ugx),
      savedAmount: const Money.zero(Currency.ugx),
      contributions: [],
    ),
    Goal(
      goalName: 'Vacation',
      targetAmount: const Money(100000, Currency.ugx),
      savedAmount: const Money.zero(Currency.ugx),
      contributions: [],
    ),
    Goal(
      goalName: 'Car',
      targetAmount: const Money(4000000, Currency.ugx),
      savedAmount: const Money.zero(Currency.ugx),
      contributions: [],
    ),
    Goal(
      goalName: 'Laptop',
      targetAmount: const Money(100000, Currency.ugx),
      savedAmount: const Money.zero(Currency.ugx),
      contributions: [],
    ),
    Goal(
      goalName: 'Rainy Day',
      targetAmount: const Money(500000, Currency.ugx),
      savedAmount: const Money.zero(Currency.ugx),
      contributions: [],
    ),
  ];

  String get _totalSavedText {
    final totals = <Currency, Money>{};
    for (final goal in savingsGoals) {
      final current = totals[goal.currency] ?? Money.zero(goal.currency);
      totals[goal.currency] = current + goal.savedAmount;
    }
    return totals.values.map((total) => total.format()).join(' · ');
  }

  void _addContribution(int index, Money contributionAmount) {
    setState(() {
      final goal = savingsGoals[index];
      final remaining = goal.targetAmount - goal.savedAmount;
      final toAdd =
          contributionAmount > remaining ? remaining : contributionAmount;

      savingsGoals[index] = goal.copyWith(
        savedAmount: goal.savedAmount + toAdd,
        contributions: [
          ...goal.contributions,
          Contribution(amount: toAdd, date: DateTime.now()),
        ],
      );
    });
  }

  Future<void> _createNewGoal() async {
    final newGoal = await Navigator.push<Goal>(
      context,
      MaterialPageRoute(builder: (context) => const NewGoalScreen()),
    );
    if (!mounted || newGoal == null) return;
    setState(() {
      savingsGoals.insert(0, newGoal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlutterFund'), centerTitle: true, actions: [IconButton(onPressed: () => context.read<ThemeProvider>().toggleTheme(), icon: const Icon(Icons.dark_mode))],),
      body: savingsGoals.isEmpty ?  Center(
              child: GestureDetector(onTap: _createNewGoal, child:  Row(mainAxisAlignment: MainAxisAlignment.center,children: [Icon(Icons.add), Text('Create your first goal')],),
              ),
              ) : Column(
        children: [
          Text('Total Amount Saved: $_totalSavedText'),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: savingsGoals.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final goal = savingsGoals.removeAt(oldIndex);
                  savingsGoals.insert(newIndex, goal);
                });
              },
              itemBuilder: (context, index) {
                final goal = savingsGoals[index];
                return Dismissible(
                  onDismissed: (direction) {
                    setState(() {
                      savingsGoals.removeAt(index);
                    });
                  },
                  background: Container(color: Colors.red, child: const Icon(Icons.delete),),
                  key: Key(goal.goalName), 
                  child: GoalCard(
                  goal: goal,
                  onAddContribution: (amount) =>
                      _addContribution(index, amount),
                ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        style: IconButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: _createNewGoal,
      ),
    );
  }
}

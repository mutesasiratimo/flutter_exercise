import 'package:flutter/material.dart';
import 'package:flutter_fund/models/contribution.dart';
import 'package:flutter_fund/models/goal.dart';
import 'package:flutter_fund/screens/new_goal_screen.dart';
import 'package:flutter_fund/utils/money.dart';
import 'package:flutter_fund/widgets/goal_card.dart';
import 'package:provider/provider.dart';

import '../design_system/design_constants.dart';
import '../design_system/empy_state.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_layout.dart';
import 'goal_details_screen.dart';
import 'settings_screen.dart';

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
  Goal? selectedGoal;
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

      final updated = goal.copyWith(
        savedAmount: goal.savedAmount + toAdd,
        contributions: [
          ...goal.contributions,
          Contribution(amount: toAdd, date: DateTime.now()),
        ],
      );
      savingsGoals[index] = updated;
      if (identical(selectedGoal, goal)) selectedGoal = updated;
    });
  }

  void _selectGoal(int index) {
    setState(() {
      selectedGoal = savingsGoals[index];
    });
  }

  void _openGoalDetails(int index) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => GoalDetailsScreen(
          goal: savingsGoals[index],
          onAddContribution: (amount) => _addContribution(index, amount),
        ),
      ),
    );
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

  void _reorderGoals(int oldIndex, int newIndex) {
    setState(() {
      // ReorderableListView reports newIndex as if the item were still in
      // the list, so moving down overshoots by one.
      if (newIndex > oldIndex) newIndex -= 1;
      final goal = savingsGoals.removeAt(oldIndex);
      savingsGoals.insert(newIndex, goal);
    });
  }

  void _deleteGoal(int index) {
    final removed = savingsGoals[index];
    setState(() {
      savingsGoals.removeAt(index);
      if (identical(selectedGoal, removed)) selectedGoal = null;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Goal deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              if (!mounted) return;
              setState(() => savingsGoals.insert(index, removed));
            },
          ),
        ),
      );
  }

  Widget _buildGoalList(
    ColorScheme colors, {
    required ValueChanged<int> onGoalTap,
    bool highlightSelected = false,
  }) {
    return ReorderableListView.builder(
      itemCount: savingsGoals.length,
      onReorder: _reorderGoals,
      itemBuilder: (context, index) {
        final goal = savingsGoals[index];
        return Dismissible(
          key: ObjectKey(goal),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteGoal(index),
          background: Container(
            color: colors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignConstants.padding,
            ),
            child: Icon(Icons.delete, color: colors.onError),
          ),
          child: GoalCard(
            goal: goal,
            selected: highlightSelected && identical(goal, selectedGoal),
            onTap: () => onGoalTap(index),
            onAddContribution: (amount) => _addContribution(index, amount),
          ),
        );
      },
    );
  }

  Widget _buildDetailPane(ThemeData theme) {
    final selected = selectedGoal;
    if (selected == null) {
      return Center(
        child: Text(
          'Select a goal to see its details',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }
    return GoalDetailsScreen(
      goal: selected,
      onAddContribution: (amount) {
        final index = savingsGoals.indexOf(selected);
        if (index != -1) _addContribution(index, amount);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return EmptyState(onNewGoal: _createNewGoal, theme: theme);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterFund'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            icon: const Icon(Icons.dark_mode),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: savingsGoals.isEmpty
          ? _buildEmptyState(theme)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(DesignConstants.padding),
                  child: Text(
                    'Total Amount Saved: $_totalSavedText',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ResponsiveLayout(
                    narrow: _buildGoalList(
                      theme.colorScheme,
                      onGoalTap: _openGoalDetails,
                    ),
                    large: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildGoalList(
                            theme.colorScheme,
                            onGoalTap: _selectGoal,
                            highlightSelected: true,
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          flex: 3,
                          child: _buildDetailPane(theme),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New goal',
        onPressed: _createNewGoal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

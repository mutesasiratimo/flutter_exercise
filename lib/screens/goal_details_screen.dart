import 'package:flutter/material.dart';
import 'package:flutter_fund/models/contribution.dart';
import 'package:flutter_fund/models/goal.dart';
import 'package:flutter_fund/utils/money.dart';
import 'package:flutter_fund/widgets/amount_field.dart';
import 'package:intl/intl.dart';

import 'new_goal_screen.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Goal goal;
  final DateTime Function()? now;
  final ValueChanged<Money> onAddContribution;

  const GoalDetailsScreen({
    super.key,
    required this.goal,
    required this.onAddContribution,
    this.now,
  });

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late Goal goal;
  final _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    goal = widget.goal;
  }

  @override
  void didUpdateWidget(covariant GoalDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.goal, oldWidget.goal)) {
      goal = widget.goal;
    }
  }

  Money get _remaining => goal.targetAmount - goal.savedAmount;

  String get _deadlineStatus {
    final deadline = goal.targetDate;
    if (deadline == null) return 'No deadline';

    final today = widget.now?.call() ?? DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDate = DateTime(deadline.year, deadline.month, deadline.day);
    final days = dueDate.difference(todayDate).inDays;

    if (days > 0) return '$days days left';
    if (days == 0) return 'Due today';
    return '${days.abs()} days overdue';
  }

  List<Contribution> get _contributionsNewestFirst {
    final items = List<Contribution>.from(goal.contributions);
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Future<void> _showAddContributionSheet() async {
    final amount = await showModalBottomSheet<Money>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _AddContributionSheet(
          currency: goal.currency,
          remaining: _remaining,
        );
      },
    );

    if (amount == null || !mounted) return;
    _addContribution(amount);
  }

  void _addContribution(Money amount) {
    final now = widget.now?.call() ?? DateTime.now();
    setState(() {
      goal = goal.copyWith(
        savedAmount: goal.savedAmount + amount,
        contributions: [
          ...goal.contributions,
          Contribution(amount: amount, date: now),
        ],
      );
    });
    widget.onAddContribution(amount);
  }

  Future<void> _editGoal() async {
    final newGoal = await Navigator.push<Goal>(
      context,
      MaterialPageRoute(builder: (context) =>  NewGoalScreen(goal: goal)),
    );
    if (!mounted || newGoal == null) return;
    setState(() {
      goal = newGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final contributions = _contributionsNewestFirst;

    return Scaffold(
      appBar: AppBar(title: const Text('Goal Details'), centerTitle: true, actions: [IconButton(onPressed: _editGoal, icon: const Icon(Icons.edit))],),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.goalName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${goal.savedAmount.format()} of ${goal.targetAmount.format()}',
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: goal.progress),
                const SizedBox(height: 4),
                Text('${(goal.progress * 100).toStringAsFixed(0)}%'),
                const SizedBox(height: 8),
                Text(
                  goal.targetDate == null
                      ? 'Deadline: None'
                      : 'Deadline: ${_dateFormat.format(goal.targetDate!)}',
                ),
                Text(_deadlineStatus),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Contribution history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: contributions.isEmpty
                ? const Center(child: Text('No contributions yet'))
                : ListView.builder(
                    itemCount: contributions.length,
                    itemBuilder: (context, index) {
                      final contribution = contributions[index];
                      return ListTile(
                        title: Text(contribution.amount.format()),
                        subtitle: Text(_dateFormat.format(contribution.date)),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: goal.isCompleted ? null : _showAddContributionSheet,
              child: const Text('Add Contribution'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddContributionSheet extends StatefulWidget {
  final Currency currency;
  final Money remaining;

  const _AddContributionSheet({
    required this.currency,
    required this.remaining,
  });

  @override
  State<_AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<_AddContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Amount is required';
    }

    try {
      final amount = Money.parse(text, widget.currency.code);
      if (amount.minorUnits <= 0) {
        return 'Amount must be greater than 0';
      }
      if (amount > widget.remaining) {
        return 'Amount exceeds the remaining ${widget.remaining.format()}';
      }
      return null;
    } on FormatException {
      return 'Amount must be a number';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = Money.parse(
      _amountController.text,
      widget.currency.code,
    );
    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add contribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _amountController,
              label: 'Amount',
              validator: _validateAmount,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

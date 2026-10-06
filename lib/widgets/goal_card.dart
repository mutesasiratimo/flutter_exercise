import 'package:flutter/material.dart';
import 'package:flutter_fund/models/goal.dart';
import 'package:flutter_fund/utils/money.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final ValueChanged<Money> onAddContribution;
  final VoidCallback? onTap;
  final bool selected;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onAddContribution,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final quickAdd = Money(10000, goal.currency);

    return Card(
      child: ListTile(
        selected: selected,
        title: Text(goal.goalName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${goal.savedAmount.format()} of ${goal.targetAmount.format()} (${(goal.progress * 100).toStringAsFixed(0)}%)',
            ),
            LinearProgressIndicator(
              value: goal.progress,
              semanticsLabel: 'Progress: ${goal.progress}',
            ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: goal.isCompleted ? null : () => onAddContribution(quickAdd),
          label: Text(
            goal.isCompleted ? 'Completed' : 'Add ${quickAdd.format()}',
          ),
          icon: Icon(goal.isCompleted ? Icons.check_circle : Icons.add),
        ),
        onTap: onTap,
      ),
    );
  }
}

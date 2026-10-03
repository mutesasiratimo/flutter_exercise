import 'package:flutter_fund/models/contribution.dart';

class Goal {
  final String goalName;
  final int targetAmount;
  final int savedAmount;
  final List<Contribution> contributions;

  Goal({
    required this.goalName,
    required this.targetAmount,
    required this.savedAmount,
    required this.contributions,
  });

  Goal copyWith({
    String? goalName,
    int? targetAmount,
    int? savedAmount,
    List<Contribution>? contributions,
  }) {
    return Goal(
      goalName: goalName ?? this.goalName,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      contributions: contributions ?? this.contributions,
    );
  }
}

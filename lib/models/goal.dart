import 'package:flutter_fund/models/contribution.dart';
import 'package:flutter_fund/utils/money.dart';

class Goal {
  final String goalName;
  final Money targetAmount;
  final Money savedAmount;
  final List<Contribution> contributions;
  final DateTime? targetDate;

  Goal({
    required this.goalName,
    required this.targetAmount,
    required this.savedAmount,
    required this.contributions,
    this.targetDate,
  }) : assert(
         targetAmount.currency == savedAmount.currency,
         'Target and saved amounts must use the same currency',
       );

  Currency get currency => targetAmount.currency;

  double get progress {
    if (targetAmount.minorUnits <= 0) return 0;
    return (savedAmount.minorUnits / targetAmount.minorUnits).clamp(0.0, 1.0);
  }

  bool get isCompleted => savedAmount >= targetAmount;

  Goal copyWith({
    String? goalName,
    Money? targetAmount,
    Money? savedAmount,
    List<Contribution>? contributions,
    DateTime? targetDate,
  }) {
    return Goal(
      goalName: goalName ?? this.goalName,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      contributions: contributions ?? this.contributions,
      targetDate: targetDate ?? this.targetDate,
    );
  }
}

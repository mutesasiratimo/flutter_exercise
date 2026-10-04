import 'package:flutter_fund/utils/money.dart';

class Contribution {
  final Money amount;
  final DateTime date;

  Contribution({required this.amount, required this.date});

  Contribution copyWith({Money? amount, DateTime? date}) {
    return Contribution(amount: amount ?? this.amount, date: date ?? this.date);
  }
}

class Contribution {
  final int amount;
  final DateTime date;

  Contribution({required this.amount, required this.date});

  Contribution copyWith({int? amount, DateTime? date}) {
    return Contribution(amount: amount ?? this.amount, date: date ?? this.date);
  }
}

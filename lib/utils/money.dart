import 'dart:math';
import 'app_functions.dart';

enum Currency {
  ugx(decimals: 0),
  usd(decimals: 2),
  kes(decimals: 2);

  const Currency({required this.decimals});

  final int decimals;

  String get code => name.toUpperCase();

  int get subunits => pow(10, decimals).toInt();

  static Currency fromCode(String code) {
    final upper = code.trim().toUpperCase();
    for (final currency in values) {
      if (currency.code == upper) return currency;
    }
    throw FormatException('Unsupported currency', code);
  }
}

class Money implements Comparable<Money> {
  /// The amount in the currency's smallest unit: cents for USD/KES,
  /// shillings for UGX.
  final int minorUnits;
  final Currency currency;

  const Money(this.minorUnits, this.currency);

  const Money.zero(this.currency) : minorUnits = 0;

  static final _amountPattern = RegExp(r'^(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d+))?$');

  /// Parses user input such as `'12.50'` or `'1,000'` using only integer
  /// arithmetic, so `'4.35'` is exactly 435 cents.
  factory Money.parse(String input, String currencyCode) {
    final currency = Currency.fromCode(currencyCode);
    final match = _amountPattern.firstMatch(input.trim());
    if (match == null) {
      throw FormatException('Not a valid amount', input);
    }

    final fraction = match[2] ?? '';
    if (fraction.length > currency.decimals) {
      throw FormatException(
        currency.decimals == 0
            ? '${currency.code} does not allow decimals'
            : '${currency.code} allows at most ${currency.decimals} decimals',
        input,
      );
    }

    final whole = int.parse(match[1]!.replaceAll(',', ''));
    final paddedFraction = fraction.padRight(currency.decimals, '0');
    final fractionUnits = paddedFraction.isEmpty ? 0 : int.parse(paddedFraction);

    return Money(whole * currency.subunits + fractionUnits, currency);
  }

  bool get isZero => minorUnits == 0;

  String format() {
    final sign = minorUnits < 0 ? '-' : '';
    final units = minorUnits.abs();
    final whole = AppFunctions.numberFormat(units ~/ currency.subunits);
    if (currency.decimals == 0) {
      return '${currency.code} $sign$whole';
    }
    final fraction = (units % currency.subunits)
        .toString()
        .padLeft(currency.decimals, '0');
    return '${currency.code} $sign$whole.$fraction';
  }

  /// The plain amount without currency code or separators, e.g. `12.50`,
  /// so it can be put back into a text field and re-parsed.
  String toInputString() {
    final sign = minorUnits < 0 ? '-' : '';
    final units = minorUnits.abs();
    final whole = units ~/ currency.subunits;
    if (currency.decimals == 0) {
      return '$sign$whole';
    }
    final fraction = (units % currency.subunits)
        .toString()
        .padLeft(currency.decimals, '0');
    return '$sign$whole.$fraction';
  }

  Money operator +(Money other) {
    _checkSameCurrency(other);
    return Money(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _checkSameCurrency(other);
    return Money(minorUnits - other.minorUnits, currency);
  }

  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  int compareTo(Money other) {
    _checkSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _checkSameCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Cannot combine ${currency.code} with ${other.currency.code}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => format();
}

import 'package:flutter_fund/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.parse', () {
    test("'4.35' USD is exactly 435 cents", () {
      expect(Money.parse('4.35', 'USD'), const Money(435, Currency.usd));
    });

    test("'12.50' USD is 1250 cents", () {
      expect(Money.parse('12.50', 'USD').minorUnits, 1250);
    });

    test('a single decimal digit is padded', () {
      expect(Money.parse('12.5', 'USD').minorUnits, 1250);
    });

    test('a whole number gets zero cents', () {
      expect(Money.parse('7', 'KES').minorUnits, 700);
    });

    test("'1,000' accepts thousands separators", () {
      expect(Money.parse('1,000', 'UGX'), const Money(1000, Currency.ugx));
      expect(Money.parse('1,000.25', 'KES').minorUnits, 100025);
    });

    test('ignores surrounding spaces and lower-case currency codes', () {
      expect(Money.parse(' 50000 ', 'ugx'), const Money(50000, Currency.ugx));
    });

    test("rejects 'abc'", () {
      expect(() => Money.parse('abc', 'USD'), throwsFormatException);
    });

    test('rejects empty input', () {
      expect(() => Money.parse('', 'USD'), throwsFormatException);
    });

    test('rejects badly placed separators and negatives', () {
      expect(() => Money.parse('1,00', 'UGX'), throwsFormatException);
      expect(() => Money.parse('-5', 'UGX'), throwsFormatException);
      expect(() => Money.parse('1.2.3', 'USD'), throwsFormatException);
    });

    test('rejects more than 2 decimals for USD and KES', () {
      expect(() => Money.parse('4.355', 'USD'), throwsFormatException);
      expect(() => Money.parse('1.001', 'KES'), throwsFormatException);
    });

    test('rejects any decimals for UGX', () {
      expect(() => Money.parse('1000.5', 'UGX'), throwsFormatException);
    });

    test('rejects unknown currencies', () {
      expect(() => Money.parse('10', 'EUR'), throwsFormatException);
    });
  });

  group('Money.format', () {
    test('UGX has no decimals', () {
      expect(const Money(50000, Currency.ugx).format(), 'UGX 50,000');
    });

    test('USD shows two decimals', () {
      expect(const Money(1250, Currency.usd).format(), 'USD 12.50');
    });

    test('KES shows two decimals with thousands separators', () {
      expect(const Money(100000, Currency.kes).format(), 'KES 1,000.00');
    });

    test('pads small cent values', () {
      expect(const Money(5, Currency.usd).format(), 'USD 0.05');
    });

    test('formats zero and negative amounts', () {
      expect(const Money.zero(Currency.ugx).format(), 'UGX 0');
      expect(const Money(-1250, Currency.usd).format(), 'USD -12.50');
    });

    test('toInputString gives a re-parsable amount', () {
      expect(const Money(100000, Currency.ugx).toInputString(), '100000');
      expect(const Money(1250, Currency.usd).toInputString(), '12.50');
      expect(
        Money.parse(const Money(5, Currency.kes).toInputString(), 'KES'),
        const Money(5, Currency.kes),
      );
    });

    test('parse then format round-trips', () {
      expect(Money.parse('4.35', 'USD').format(), 'USD 4.35');
    });
  });

  group('arithmetic and comparison', () {
    const tenDollars = Money(1000, Currency.usd);
    const fiveDollars = Money(500, Currency.usd);
    const tenThousandShillings = Money(10000, Currency.ugx);

    test('adds and subtracts in the same currency', () {
      expect(tenDollars + fiveDollars, const Money(1500, Currency.usd));
      expect(tenDollars - fiveDollars, fiveDollars);
    });

    test('0.10 + 0.20 is exactly 0.30', () {
      final sum = Money.parse('0.10', 'USD') + Money.parse('0.20', 'USD');
      expect(sum, Money.parse('0.30', 'USD'));
    });

    test('compares amounts in the same currency', () {
      expect(tenDollars > fiveDollars, isTrue);
      expect(fiveDollars < tenDollars, isTrue);
      expect(tenDollars >= const Money(1000, Currency.usd), isTrue);
      expect(tenDollars <= fiveDollars, isFalse);
      expect(tenDollars.compareTo(fiveDollars), greaterThan(0));
    });

    test('equal amounts are equal and share a hash code', () {
      const a = Money(1000, Currency.usd);
      const b = Money(1000, Currency.usd);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('the same number in different currencies is not equal', () {
      expect(const Money(1000, Currency.usd) == const Money(1000, Currency.kes),
          isFalse);
    });

    test('mixing currencies throws', () {
      expect(() => tenDollars + tenThousandShillings, throwsArgumentError);
      expect(() => tenDollars - tenThousandShillings, throwsArgumentError);
      expect(() => tenDollars > tenThousandShillings, throwsArgumentError);
      expect(() => tenDollars.compareTo(tenThousandShillings),
          throwsArgumentError);
    });
  });
}

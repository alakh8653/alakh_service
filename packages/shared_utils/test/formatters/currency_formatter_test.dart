import 'package:test/test.dart';
import 'package:shared_utils/shared_utils.dart';

void main() {
  group('CurrencyFormatter.formatCurrency', () {
    test('formats INR correctly', () {
      final result = CurrencyFormatter.formatCurrency(1234.5);
      expect(result, contains('1,234.50'));
      expect(result, contains('₹'));
    });

    test('formats USD correctly', () {
      final result = CurrencyFormatter.formatCurrency(
        99.99,
        currency: 'USD',
        locale: 'en_US',
      );
      expect(result, contains('99.99'));
      expect(result, contains('\$'));
    });

    test('formats zero amount', () {
      final result = CurrencyFormatter.formatCurrency(0.0);
      expect(result, contains('0.00'));
    });
  });

  group('CurrencyFormatter.formatCompact', () {
    test('formats thousands with K suffix', () {
      expect(CurrencyFormatter.formatCompact(1200.0), '1.2K');
    });

    test('formats millions with M suffix', () {
      expect(CurrencyFormatter.formatCompact(1500000.0), '1.5M');
    });

    test('formats billions with B suffix', () {
      expect(CurrencyFormatter.formatCompact(2300000000.0), '2.3B');
    });

    test('leaves small numbers as-is', () {
      expect(CurrencyFormatter.formatCompact(500.0), '500.00');
    });
  });

  group('CurrencyFormatter.parseCurrency', () {
    test('parses INR string', () {
      expect(CurrencyFormatter.parseCurrency('₹1,234.50'), closeTo(1234.5, 0.01));
    });

    test('parses plain numeric string', () {
      expect(CurrencyFormatter.parseCurrency('99.99'), closeTo(99.99, 0.01));
    });

    test('returns 0.0 for non-numeric string', () {
      expect(CurrencyFormatter.parseCurrency('not a number'), 0.0);
    });
  });
}

import 'package:test/test.dart';
import 'package:shared_utils/shared_utils.dart';

void main() {
  group('EmailValidator.isValid', () {
    test('accepts standard email', () {
      expect(EmailValidator.isValid('user@example.com'), isTrue);
    });

    test('accepts email with dots in local part', () {
      expect(EmailValidator.isValid('first.last@sub.domain.org'), isTrue);
    });

    test('accepts email with plus sign', () {
      expect(EmailValidator.isValid('user+tag@example.co.uk'), isTrue);
    });

    test('rejects email without @', () {
      expect(EmailValidator.isValid('notanemail'), isFalse);
    });

    test('rejects email without domain', () {
      expect(EmailValidator.isValid('user@'), isFalse);
    });

    test('rejects email without TLD', () {
      expect(EmailValidator.isValid('user@domain'), isFalse);
    });

    test('rejects email with spaces', () {
      expect(EmailValidator.isValid('us er@example.com'), isFalse);
    });

    test('rejects empty string', () {
      expect(EmailValidator.isValid(''), isFalse);
    });
  });

  group('EmailValidator.validate', () {
    test('returns null for valid email', () {
      expect(EmailValidator.validate('valid@example.com'), isNull);
    });

    test('returns error for null', () {
      expect(EmailValidator.validate(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(EmailValidator.validate(''), isNotNull);
    });

    test('returns error for invalid format', () {
      expect(EmailValidator.validate('bad-email'), isNotNull);
    });
  });
}

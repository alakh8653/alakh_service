import 'package:test/test.dart';
import 'package:shared_utils/shared_utils.dart';

void main() {
  group('StringHelpers.capitalize', () {
    test('capitalises first letter', () {
      expect(StringHelpers.capitalize('hello'), 'Hello');
    });

    test('lowercases the rest', () {
      expect(StringHelpers.capitalize('hELLO'), 'Hello');
    });

    test('handles empty string', () {
      expect(StringHelpers.capitalize(''), '');
    });

    test('handles single character', () {
      expect(StringHelpers.capitalize('a'), 'A');
    });
  });

  group('StringHelpers.titleCase', () {
    test('capitalises each word', () {
      expect(StringHelpers.titleCase('hello world'), 'Hello World');
    });

    test('handles single word', () {
      expect(StringHelpers.titleCase('dart'), 'Dart');
    });
  });

  group('StringHelpers.maskEmail', () {
    test('masks local part beyond first 2 chars', () {
      expect(StringHelpers.maskEmail('alice@gmail.com'), 'al***@gmail.com');
    });

    test('masks very short local part completely', () {
      expect(StringHelpers.maskEmail('a@gmail.com'), '***@gmail.com');
    });

    test('returns original for invalid email', () {
      expect(StringHelpers.maskEmail('notanemail'), 'notanemail');
    });
  });

  group('StringHelpers.maskPhone', () {
    test('masks all but last 5 digits', () {
      final result = StringHelpers.maskPhone('+91 9876543210');
      expect(result, contains('43210'));
      expect(result, contains('*'));
    });
  });

  group('StringHelpers.initials', () {
    test('extracts two initials from full name', () {
      expect(StringHelpers.initials('John Doe'), 'JD');
    });

    test('extracts one initial from single name', () {
      expect(StringHelpers.initials('Alice'), 'A');
    });

    test('respects maxChars parameter', () {
      expect(StringHelpers.initials('John Michael Doe', maxChars: 3), 'JMD');
    });

    test('handles extra whitespace', () {
      expect(StringHelpers.initials('  Jane   Smith  '), 'JS');
    });
  });

  group('StringHelpers.slugify', () {
    test('converts to lowercase with hyphens', () {
      expect(StringHelpers.slugify('Hello World'), 'hello-world');
    });

    test('removes special characters', () {
      expect(StringHelpers.slugify('Hello World!'), 'hello-world');
    });

    test('collapses multiple spaces', () {
      expect(StringHelpers.slugify('a  b  c'), 'a-b-c');
    });
  });

  group('StringHelpers.camelToWords', () {
    test('converts camelCase to words', () {
      expect(StringHelpers.camelToWords('camelCase'), 'Camel Case');
    });

    test('converts PascalCase to words', () {
      expect(StringHelpers.camelToWords('ShopOwner'), 'Shop Owner');
    });
  });

  group('StringHelpers.isNullOrEmpty', () {
    test('returns true for null', () {
      expect(StringHelpers.isNullOrEmpty(null), isTrue);
    });

    test('returns true for empty string', () {
      expect(StringHelpers.isNullOrEmpty(''), isTrue);
    });

    test('returns true for whitespace-only', () {
      expect(StringHelpers.isNullOrEmpty('   '), isTrue);
    });

    test('returns false for non-empty string', () {
      expect(StringHelpers.isNullOrEmpty('hello'), isFalse);
    });
  });

  group('StringHelpers.truncate', () {
    test('truncates long strings', () {
      expect(StringHelpers.truncate('Hello World', 5), 'Hello...');
    });

    test('leaves short strings unchanged', () {
      expect(StringHelpers.truncate('Hi', 10), 'Hi');
    });

    test('uses custom ellipsis', () {
      expect(
        StringHelpers.truncate('Hello World', 5, ellipsis: '…'),
        'Hello…',
      );
    });
  });
}

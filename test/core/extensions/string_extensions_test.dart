import 'package:flutter_test/flutter_test.dart';
import 'package:price_list/core/extensions/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    group('capitalize', () {
      test('should capitalize first letter of string', () {
        expect('hello'.capitalize(), 'Hello');
        expect('HELLO'.capitalize(), 'HELLO');
        expect(''.capitalize(), '');
      });
    });

    group('capitalizeWords', () {
      test('should capitalize first letter of each word', () {
        expect('hello world'.capitalizeWords(), 'Hello World');
        expect('hello WORLD test'.capitalizeWords(), 'Hello WORLD Test');
        expect(''.capitalizeWords(), '');
      });
    });

    group('isValidEmail', () {
      test('should validate email addresses correctly', () {
        expect('test@example.com'.isValidEmail, true);
        expect('user.name@domain.co.uk'.isValidEmail, true);
        expect('invalid-email'.isValidEmail, false);
        expect('test@'.isValidEmail, false);
        expect('@domain.com'.isValidEmail, false);
      });
    });

    group('isValidPin', () {
      test('should validate PIN codes correctly', () {
        expect('1234'.isValidPin, true);
        expect('123456'.isValidPin, true);
        expect('12345678'.isValidPin, true);
        expect('123'.isValidPin, false);
        expect('123456789'.isValidPin, false);
        expect('abcd'.isValidPin, false);
      });
    });

    group('isValidNumber', () {
      test('should validate numbers correctly', () {
        expect('123'.isValidNumber, true);
        expect('123.45'.isValidNumber, true);
        expect('-123.45'.isValidNumber, true);
        expect('abc'.isValidNumber, false);
        expect('12.34.56'.isValidNumber, false);
      });
    });

    group('isValidPercentage', () {
      test('should validate percentage values correctly', () {
        expect('50'.isValidPercentage, true);
        expect('100'.isValidPercentage, true);
        expect('0'.isValidPercentage, true);
        expect('50.5'.isValidPercentage, true);
        expect('101'.isValidPercentage, false);
        expect('-5'.isValidPercentage, false);
        expect('abc'.isValidPercentage, false);
      });
    });

    group('removeWhitespace', () {
      test('should remove all whitespace from string', () {
        expect('hello world'.removeWhitespace(), 'helloworld');
        expect('  test  string  '.removeWhitespace(), 'teststring');
        expect('no-spaces'.removeWhitespace(), 'no-spaces');
      });
    });

    group('truncate', () {
      test('should truncate string to max length', () {
        expect('hello world'.truncate(5), 'he...');
        expect('short'.truncate(10), 'short');
        expect('exact length'.truncate(12), 'exact length');
      });
    });

    group('toDoubleOrDefault', () {
      test('should convert string to double with fallback', () {
        expect('123.45'.toDoubleOrDefault(), 123.45);
        expect('invalid'.toDoubleOrDefault(), 0.0);
        expect('invalid'.toDoubleOrDefault(99.0), 99.0);
      });
    });

    group('toIntOrDefault', () {
      test('should convert string to int with fallback', () {
        expect('123'.toIntOrDefault(), 123);
        expect('invalid'.toIntOrDefault(), 0);
        expect('invalid'.toIntOrDefault(99), 99);
      });
    });

    group('formatAsCurrency', () {
      test('should format string as currency', () {
        expect('123.45'.formatAsCurrency(), '₺123.45');
        expect('100'.formatAsCurrency(symbol: '\$'), '\$100.00');
        expect('invalid'.formatAsCurrency(), 'invalid');
      });
    });

    group('formatAsPercentage', () {
      test('should format string as percentage', () {
        expect('50'.formatAsPercentage(), '50.0%');
        expect('75.5'.formatAsPercentage(), '75.5%');
        expect('invalid'.formatAsPercentage(), 'invalid');
      });
    });

    group('mask', () {
      test('should mask sensitive parts of string', () {
        expect('12345678'.mask(), '1234****');
        expect('123'.mask(), '123');
        expect('1234567890'.mask(visibleChars: 2), '12********');
      });
    });

    group('Character type validation', () {
      test('isNumeric should validate numeric strings', () {
        expect('123'.isNumeric, true);
        expect('abc'.isNumeric, false);
        expect('12a'.isNumeric, false);
      });

      test('isAlphabetic should validate alphabetic strings', () {
        expect('abc'.isAlphabetic, true);
        expect('123'.isAlphabetic, false);
        expect('ab1'.isAlphabetic, false);
      });

      test('isAlphanumeric should validate alphanumeric strings', () {
        expect('abc123'.isAlphanumeric, true);
        expect('abc'.isAlphanumeric, true);
        expect('123'.isAlphanumeric, true);
        expect('abc-123'.isAlphanumeric, false);
      });
    });

    group('reverse', () {
      test('should reverse string', () {
        expect('hello'.reverse(), 'olleh');
        expect('12345'.reverse(), '54321');
        expect(''.reverse(), '');
      });
    });

    group('wordCount', () {
      test('should count words in string', () {
        expect('hello world'.wordCount, 2);
        expect('  hello   world  test  '.wordCount, 3);
        expect(''.wordCount, 1);
        expect('single'.wordCount, 1);
      });
    });

    group('extractNumbers', () {
      test('should extract numbers from string', () {
        expect('Price: 123.45, Tax: 20.5'.extractNumbers(), [123.45, 20.5]);
        expect('No numbers here'.extractNumbers(), []);
        expect('Mix 123 and 45.6 numbers'.extractNumbers(), [123, 45.6]);
      });
    });

    group('Case conversion', () {
      test('toKebabCase should convert to kebab-case', () {
        expect('HelloWorld'.toKebabCase(), 'hello-world');
        expect('hello_world'.toKebabCase(), 'hello-world');
        expect('hello world'.toKebabCase(), 'hello-world');
      });

      test('toSnakeCase should convert to snake_case', () {
        expect('HelloWorld'.toSnakeCase(), 'hello_world');
        expect('hello-world'.toSnakeCase(), 'hello_world');
        expect('hello world'.toSnakeCase(), 'hello_world');
      });

      test('toCamelCase should convert to camelCase', () {
        expect('hello_world'.toCamelCase(), 'helloWorld');
        expect('hello-world'.toCamelCase(), 'helloWorld');
        expect('hello world'.toCamelCase(), 'helloWorld');
      });
    });
  });

  group('NullableStringExtensions', () {
    group('isNullOrEmpty', () {
      test('should check if string is null or empty', () {
        expect((null as String?).isNullOrEmpty, true);
        expect(''.isNullOrEmpty, true);
        expect('test'.isNullOrEmpty, false);
        expect('  '.isNullOrEmpty, false);
      });
    });

    group('isNotNullOrEmpty', () {
      test('should check if string is not null and not empty', () {
        expect((null as String?).isNotNullOrEmpty, false);
        expect(''.isNotNullOrEmpty, false);
        expect('test'.isNotNullOrEmpty, true);
        expect('  '.isNotNullOrEmpty, true);
      });
    });

    group('orDefault', () {
      test('should return string or default value', () {
        expect((null as String?).orDefault(), '');
        expect((null as String?).orDefault('default'), 'default');
        expect('test'.orDefault('default'), 'test');
      });
    });

    group('orNA', () {
      test('should return string or N/A', () {
        expect((null as String?).orNA, 'N/A');
        expect(''.orNA, 'N/A');
        expect('test'.orNA, 'test');
      });
    });

    group('toDoubleOrNull', () {
      test('should convert to double or return null', () {
        expect((null as String?).toDoubleOrNull(), null);
        expect('123.45'.toDoubleOrNull(), 123.45);
        expect('invalid'.toDoubleOrNull(), null);
      });
    });

    group('toIntOrNull', () {
      test('should convert to int or return null', () {
        expect((null as String?).toIntOrNull(), null);
        expect('123'.toIntOrNull(), 123);
        expect('invalid'.toIntOrNull(), null);
      });
    });
  });
}
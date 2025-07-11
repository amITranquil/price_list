import 'package:flutter_test/flutter_test.dart';
import 'package:price_list/services/validation_service.dart';

void main() {
  group('StandardValidationService', () {
    late ValidationService validationService;

    setUp(() {
      validationService = StandardValidationService();
    });

    group('validatePrice', () {
      test('should return success for valid prices', () {
        final result1 = validationService.validatePrice('100.50');
        expect(result1.isValid, true);
        expect(result1.errorMessage, null);

        final result2 = validationService.validatePrice('0.01');
        expect(result2.isValid, true);

        final result3 = validationService.validatePrice('999999');
        expect(result3.isValid, true);
      });

      test('should return error for empty price', () {
        final result = validationService.validatePrice('');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Price cannot be empty');
        expect(result.localizedErrorKey, 'originalPriceEmpty');
      });

      test('should return error for invalid price format', () {
        final result = validationService.validatePrice('abc');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Invalid price format');
        expect(result.localizedErrorKey, 'invalidPriceFormat');
      });

      test('should return error for negative price', () {
        final result = validationService.validatePrice('-10');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Price must be greater than zero');
        expect(result.localizedErrorKey, 'priceGreaterThanZero');
      });

      test('should return error for zero price', () {
        final result = validationService.validatePrice('0');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Price must be greater than zero');
        expect(result.localizedErrorKey, 'priceGreaterThanZero');
      });

      test('should return error for too large price', () {
        final result = validationService.validatePrice('1000001');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Price is too large');
        expect(result.localizedErrorKey, 'priceTooLarge');
      });

      test('should handle whitespace in price', () {
        final result = validationService.validatePrice('  100.50  ');
        expect(result.isValid, true);
      });
    });

    group('validatePercentage', () {
      test('should return success for valid percentages', () {
        final result1 = validationService.validatePercentage('50');
        expect(result1.isValid, true);

        final result2 = validationService.validatePercentage('0');
        expect(result2.isValid, true);

        final result3 = validationService.validatePercentage('100');
        expect(result3.isValid, true);

        final result4 = validationService.validatePercentage('25.5');
        expect(result4.isValid, true);
      });

      test('should return success for empty percentage', () {
        final result = validationService.validatePercentage('');
        expect(result.isValid, true);
      });

      test('should return error for invalid percentage format', () {
        final result = validationService.validatePercentage('abc');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Invalid percentage format');
        expect(result.localizedErrorKey, 'invalidPercentageFormat');
      });

      test('should return error for negative percentage', () {
        final result = validationService.validatePercentage('-10');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Percentage cannot be negative');
        expect(result.localizedErrorKey, 'percentageCannotBeNegative');
      });

      test('should return error for percentage greater than 100', () {
        final result = validationService.validatePercentage('101');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Percentage cannot be greater than 100');
        expect(result.localizedErrorKey, 'percentageCannotBeGreaterThan100');
      });

      test('should handle whitespace in percentage', () {
        final result = validationService.validatePercentage('  50  ');
        expect(result.isValid, true);
      });
    });

    group('validatePresetLabel', () {
      test('should return success for valid labels', () {
        final result1 = validationService.validatePresetLabel('My Preset');
        expect(result1.isValid, true);

        final result2 = validationService.validatePresetLabel('ab');
        expect(result2.isValid, true);

        final result3 = validationService.validatePresetLabel('A' * 50);
        expect(result3.isValid, true);
      });

      test('should return error for empty label', () {
        final result = validationService.validatePresetLabel('');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Preset label cannot be empty');
        expect(result.localizedErrorKey, 'presetLabelEmpty');
      });

      test('should return error for too short label', () {
        final result = validationService.validatePresetLabel('a');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Preset label must be at least 2 characters');
        expect(result.localizedErrorKey, 'presetLabelTooShort');
      });

      test('should return error for too long label', () {
        final result = validationService.validatePresetLabel('A' * 51);
        expect(result.isValid, false);
        expect(result.errorMessage, 'Preset label cannot be longer than 50 characters');
        expect(result.localizedErrorKey, 'presetLabelTooLong');
      });

      test('should handle whitespace in label', () {
        final result = validationService.validatePresetLabel('  Valid Label  ');
        expect(result.isValid, true);
      });
    });

    group('validateProductName', () {
      test('should return success for valid product names', () {
        final result1 = validationService.validateProductName('Product Name');
        expect(result1.isValid, true);

        final result2 = validationService.validateProductName('ab');
        expect(result2.isValid, true);

        final result3 = validationService.validateProductName('A' * 100);
        expect(result3.isValid, true);
      });

      test('should return error for empty product name', () {
        final result = validationService.validateProductName('');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Product name is required');
        expect(result.localizedErrorKey, 'productNameRequired');
      });

      test('should return error for too short product name', () {
        final result = validationService.validateProductName('a');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Product name must be at least 2 characters');
        expect(result.localizedErrorKey, 'productNameTooShort');
      });

      test('should return error for too long product name', () {
        final result = validationService.validateProductName('A' * 101);
        expect(result.isValid, false);
        expect(result.errorMessage, 'Product name cannot be longer than 100 characters');
        expect(result.localizedErrorKey, 'productNameTooLong');
      });

      test('should handle whitespace in product name', () {
        final result = validationService.validateProductName('  Valid Product  ');
        expect(result.isValid, true);
      });
    });

    group('validatePinCode', () {
      test('should return success for valid PIN codes', () {
        final result1 = validationService.validatePinCode('1234');
        expect(result1.isValid, true);

        final result2 = validationService.validatePinCode('123456');
        expect(result2.isValid, true);

        final result3 = validationService.validatePinCode('12345678');
        expect(result3.isValid, true);
      });

      test('should return error for empty PIN code', () {
        final result = validationService.validatePinCode('');
        expect(result.isValid, false);
        expect(result.errorMessage, 'PIN code cannot be empty');
        expect(result.localizedErrorKey, 'pinCodeEmpty');
      });

      test('should return error for too short PIN code', () {
        final result = validationService.validatePinCode('123');
        expect(result.isValid, false);
        expect(result.errorMessage, 'PIN code must be at least 4 characters');
        expect(result.localizedErrorKey, 'pinCodeTooShort');
      });

      test('should return error for too long PIN code', () {
        final result = validationService.validatePinCode('123456789');
        expect(result.isValid, false);
        expect(result.errorMessage, 'PIN code cannot be longer than 8 characters');
        expect(result.localizedErrorKey, 'pinCodeTooLong');
      });

      test('should return error for non-numeric PIN code', () {
        final result = validationService.validatePinCode('12ab');
        expect(result.isValid, false);
        expect(result.errorMessage, 'PIN code must contain only numbers');
        expect(result.localizedErrorKey, 'pinCodeOnlyNumbers');
      });

      test('should handle whitespace in PIN code', () {
        final result = validationService.validatePinCode('  1234  ');
        expect(result.isValid, true);
      });
    });
  });

  group('ValidationResult', () {
    test('should create success result', () {
      final result = ValidationResult.success();
      expect(result.isValid, true);
      expect(result.errorMessage, null);
      expect(result.localizedErrorKey, null);
    });

    test('should create error result', () {
      final result = ValidationResult.error('Error message', 'errorKey');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Error message');
      expect(result.localizedErrorKey, 'errorKey');
    });

    test('should create error result without localized key', () {
      final result = ValidationResult.error('Error message');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Error message');
      expect(result.localizedErrorKey, null);
    });
  });
}
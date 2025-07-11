import 'package:flutter_test/flutter_test.dart';
import 'package:price_list/core/utils/formatting_utils.dart';

void main() {
  group('FormattingUtils', () {
    group('formatCurrency', () {
      test('should format currency with default settings', () {
        final result = FormattingUtils.formatCurrency(1234.56);
        expect(result, contains('1,234.56'));
        expect(result, contains('₺'));
      });

      test('should format currency with USD', () {
        final result = FormattingUtils.formatCurrency(1234.56, currencyCode: 'USD');
        expect(result, contains('1,234.56'));
        expect(result, contains('\$'));
      });

      test('should format currency without symbol', () {
        final result = FormattingUtils.formatCurrency(1234.56, showSymbol: false);
        expect(result, contains('1,234.56'));
        expect(result, isNot(contains('₺')));
      });

      test('should format currency with different locale', () {
        final result = FormattingUtils.formatCurrency(1234.56, locale: 'en_US');
        expect(result, contains('1,234.56'));
      });
    });

    group('formatPercentage', () {
      test('should format percentage with default settings', () {
        final result = FormattingUtils.formatPercentage(50.0);
        expect(result, contains('50'));
        expect(result, contains('%'));
      });

      test('should format percentage with decimal places', () {
        final result = FormattingUtils.formatPercentage(50.567, decimalPlaces: 2);
        expect(result, contains('50.57'));
        expect(result, contains('%'));
      });

      test('should format percentage without symbol', () {
        final result = FormattingUtils.formatPercentage(50.0, showSymbol: false);
        expect(result, contains('50'));
        expect(result, isNot(contains('%')));
      });
    });

    group('formatNumber', () {
      test('should format number with thousand separators', () {
        final result = FormattingUtils.formatNumber(1234567.89);
        expect(result, contains('1,234,567.89'));
      });

      test('should format small numbers', () {
        final result = FormattingUtils.formatNumber(123.45);
        expect(result, '123.45');
      });

      test('should format with custom decimal places', () {
        final result = FormattingUtils.formatNumber(1234.5, decimalPlaces: 3);
        expect(result, contains('1,234.500'));
      });
    });

    group('formatDate', () {
      test('should format date with default pattern', () {
        final date = DateTime(2023, 12, 25);
        final result = FormattingUtils.formatDate(date);
        expect(result, '25/12/2023');
      });

      test('should format date with custom pattern', () {
        final date = DateTime(2023, 12, 25);
        final result = FormattingUtils.formatDate(date, pattern: 'yyyy-MM-dd');
        expect(result, '2023-12-25');
      });
    });

    group('formatDateTime', () {
      test('should format datetime with default pattern', () {
        final dateTime = DateTime(2023, 12, 25, 14, 30);
        final result = FormattingUtils.formatDateTime(dateTime);
        expect(result, '25/12/2023 14:30');
      });

      test('should format datetime with custom pattern', () {
        final dateTime = DateTime(2023, 12, 25, 14, 30);
        final result = FormattingUtils.formatDateTime(dateTime, pattern: 'yyyy-MM-dd HH:mm:ss');
        expect(result, '2023-12-25 14:30:00');
      });
    });

    group('formatTime', () {
      test('should format time with default pattern', () {
        final time = DateTime(2023, 12, 25, 14, 30);
        final result = FormattingUtils.formatTime(time);
        expect(result, '14:30');
      });

      test('should format time with custom pattern', () {
        final time = DateTime(2023, 12, 25, 14, 30, 45);
        final result = FormattingUtils.formatTime(time, pattern: 'HH:mm:ss');
        expect(result, '14:30:45');
      });
    });

    group('formatFileSize', () {
      test('should format bytes', () {
        expect(FormattingUtils.formatFileSize(500), '500 B');
      });

      test('should format kilobytes', () {
        expect(FormattingUtils.formatFileSize(1536), '1.5 KB');
      });

      test('should format megabytes', () {
        expect(FormattingUtils.formatFileSize(1572864), '1.5 MB');
      });

      test('should format gigabytes', () {
        expect(FormattingUtils.formatFileSize(1610612736), '1.5 GB');
      });
    });

    group('formatDuration', () {
      test('should format seconds only', () {
        const duration =  Duration(seconds: 30);
        expect(FormattingUtils.formatDuration(duration), '30s');
      });

      test('should format minutes and seconds', () {
        const duration = Duration(minutes: 5, seconds: 30);
        expect(FormattingUtils.formatDuration(duration), '5m 30s');
      });

      test('should format hours and minutes', () {
        const duration = Duration(hours: 2, minutes: 30);
        expect(FormattingUtils.formatDuration(duration), '2h 30m');
      });

      test('should format days, hours and minutes', () {
        const duration = Duration(days: 1, hours: 2, minutes: 30);
        expect(FormattingUtils.formatDuration(duration), '1d 2h 30m');
      });
    });

    group('formatTurkishId', () {
      test('should format Turkish ID without masking', () {
        final result = FormattingUtils.formatTurkishId('12345678901', mask: false);
        expect(result, '12345678901');
      });

      test('should format Turkish ID with masking', () {
        final result = FormattingUtils.formatTurkishId('12345678901', mask: true);
        expect(result, '123***8901');
      });

      test('should return original for invalid length', () {
        final result = FormattingUtils.formatTurkishId('123456789');
        expect(result, '123456789');
      });
    });

    group('formatPhoneNumber', () {
      test('should format Turkish phone number', () {
        final result = FormattingUtils.formatPhoneNumber('05551234567');
        expect(result, '0555 123 45 67');
      });

      test('should format international phone number', () {
        final result = FormattingUtils.formatPhoneNumber('905551234567');
        expect(result, '+90 555 123 45 67');
      });

      test('should return original for unrecognized format', () {
        final result = FormattingUtils.formatPhoneNumber('123456');
        expect(result, '123456');
      });
    });

    group('formatCreditCard', () {
      test('should format credit card number', () {
        final result = FormattingUtils.formatCreditCard('1234567812345678');
        expect(result, '1234 5678 1234 5678');
      });

      test('should handle partial credit card number', () {
        final result = FormattingUtils.formatCreditCard('123456');
        expect(result, '1234 56');
      });

      test('should handle non-digit characters', () {
        final result = FormattingUtils.formatCreditCard('1234-5678-1234-5678');
        expect(result, '1234 5678 1234 5678');
      });
    });

    group('formatIban', () {
      test('should format IBAN', () {
        final result = FormattingUtils.formatIban('TR330006100519786457841326');
        expect(result, 'TR33 0006 1005 1978 6457 8413 26');
      });

      test('should handle lowercase IBAN', () {
        final result = FormattingUtils.formatIban('tr330006100519786457841326');
        expect(result, 'TR33 0006 1005 1978 6457 8413 26');
      });

      test('should handle IBAN with spaces', () {
        final result = FormattingUtils.formatIban('TR33 0006 1005 1978 6457 8413 26');
        expect(result, 'TR33 0006 1005 1978 6457 8413 26');
      });
    });

    group('formatExchangeRate', () {
      test('should format high exchange rate', () {
        expect(FormattingUtils.formatExchangeRate(30.12), '30.12');
      });

      test('should format medium exchange rate', () {
        expect(FormattingUtils.formatExchangeRate(5.123), '5.123');
      });

      test('should format low exchange rate', () {
        expect(FormattingUtils.formatExchangeRate(0.1234), '0.1234');
      });
    });

    group('formatCalculationStep', () {
      test('should format calculation step', () {
        final result = FormattingUtils.formatCalculationStep('Original price', 1000.0, 'base');
        expect(result, contains('Original price'));
        expect(result, contains('1,000.00'));
      });
    });

    group('formatDiscountBreakdown', () {
      test('should format discount breakdown', () {
        final result = FormattingUtils.formatDiscountBreakdown([10.0, 5.0, 0.0]);
        expect(result, contains('Discount 1: 10'));
        expect(result, contains('Discount 2: 5'));
        expect(result, isNot(contains('Discount 3')));
      });

      test('should handle no discounts', () {
        final result = FormattingUtils.formatDiscountBreakdown([0.0, 0.0, 0.0]);
        expect(result, 'No discounts applied');
      });

      test('should handle empty discount list', () {
        final result = FormattingUtils.formatDiscountBreakdown([]);
        expect(result, 'No discounts applied');
      });
    });

    group('formatPriceComparison', () {
      test('should format price increase', () {
        final result = FormattingUtils.formatPriceComparison(100.0, 120.0);
        expect(result, contains('+'));
        expect(result, contains('20'));
      });

      test('should format price decrease', () {
        final result = FormattingUtils.formatPriceComparison(120.0, 100.0);
        expect(result, contains('-'));
        expect(result, contains('20'));
      });

      test('should format no change', () {
        final result = FormattingUtils.formatPriceComparison(100.0, 100.0);
        expect(result, contains('+'));
        expect(result, contains('0'));
      });
    });

    group('formatValidationError', () {
      test('should format required error', () {
        final result = FormattingUtils.formatValidationError('Price', 'required');
        expect(result, 'Price is required');
      });

      test('should format invalid error', () {
        final result = FormattingUtils.formatValidationError('Email', 'invalid');
        expect(result, 'Email is invalid');
      });

      test('should format unknown error', () {
        final result = FormattingUtils.formatValidationError('Field', 'unknown');
        expect(result, 'Invalid Field');
      });
    });

    group('formatApiStatus', () {
      test('should format success status', () {
        expect(FormattingUtils.formatApiStatus(200), 'Success');
      });

      test('should format error status', () {
        expect(FormattingUtils.formatApiStatus(404), 'Not Found');
      });

      test('should format unknown status', () {
        expect(FormattingUtils.formatApiStatus(999), 'Status Code: 999');
      });
    });

    group('formatCalculationSummary', () {
      test('should format calculation summary', () {
        final result = FormattingUtils.formatCalculationSummary(
          originalPrice: 100.0,
          finalPrice: 120.0,
          currency: 'USD',
          discounts: [10.0, 5.0, 0.0],
          profitMargin: 40.0,
        );

        expect(result, contains('Original Price'));
        expect(result, contains('100'));
        expect(result, contains('Discounts'));
        expect(result, contains('Profit Margin'));
        expect(result, contains('40'));
        expect(result, contains('Final Price'));
        expect(result, contains('120'));
      });
    });

    group('formatExportFilename', () {
      test('should format export filename with timestamp', () {
        final result = FormattingUtils.formatExportFilename('report', 'pdf');
        expect(result, startsWith('report_'));
        expect(result, endsWith('.pdf'));
        expect(result.length, greaterThan(10));
      });
    });

    group('formatBackupFilename', () {
      test('should format backup filename with timestamp', () {
        final result = FormattingUtils.formatBackupFilename();
        expect(result, startsWith('price_list_backup_'));
        expect(result, endsWith('.db'));
        expect(result.length, greaterThan(20));
      });
    });
  });

  group('NumberFormatUtils', () {
    group('parseDouble', () {
      test('should parse valid double', () {
        expect(NumberFormatUtils.parseDouble('123.45'), 123.45);
        expect(NumberFormatUtils.parseDouble('  123.45  '), 123.45);
      });

      test('should return fallback for invalid double', () {
        expect(NumberFormatUtils.parseDouble('invalid'), 0.0);
        expect(NumberFormatUtils.parseDouble('invalid', fallback: 99.0), 99.0);
      });
    });

    group('parseInt', () {
      test('should parse valid int', () {
        expect(NumberFormatUtils.parseInt('123'), 123);
        expect(NumberFormatUtils.parseInt('  123  '), 123);
      });

      test('should return fallback for invalid int', () {
        expect(NumberFormatUtils.parseInt('invalid'), 0);
        expect(NumberFormatUtils.parseInt('invalid', fallback: 99), 99);
      });
    });

    group('formatPercentageInput', () {
      test('should format valid percentage', () {
        expect(NumberFormatUtils.formatPercentageInput('50'), '50.0');
        expect(NumberFormatUtils.formatPercentageInput('75.5'), '75.5');
      });

      test('should clamp percentage to 0-100 range', () {
        expect(NumberFormatUtils.formatPercentageInput('150'), '100');
        expect(NumberFormatUtils.formatPercentageInput('-10'), '0');
      });

      test('should return original for invalid input', () {
        expect(NumberFormatUtils.formatPercentageInput('invalid'), 'invalid');
      });
    });

    group('formatPriceInput', () {
      test('should format valid price', () {
        expect(NumberFormatUtils.formatPriceInput('100'), '100.0');
        expect(NumberFormatUtils.formatPriceInput('123.45'), '123.45');
      });

      test('should clamp price to valid range', () {
        expect(NumberFormatUtils.formatPriceInput('1000001'), '1000000.0');
        expect(NumberFormatUtils.formatPriceInput('-10'), '0');
      });

      test('should return original for invalid input', () {
        expect(NumberFormatUtils.formatPriceInput('invalid'), 'invalid');
      });
    });

    group('formatForDisplay', () {
      test('should format whole numbers without decimals', () {
        expect(NumberFormatUtils.formatForDisplay(100.0), '100');
        expect(NumberFormatUtils.formatForDisplay(0.0), '0');
      });

      test('should format decimal numbers with decimals', () {
        expect(NumberFormatUtils.formatForDisplay(100.5), '100.5');
        expect(NumberFormatUtils.formatForDisplay(123.456), '123.456');
      });
    });
  });
}
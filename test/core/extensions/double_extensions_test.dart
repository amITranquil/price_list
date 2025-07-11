import 'package:flutter_test/flutter_test.dart';
import 'package:price_list/core/extensions/double_extensions.dart';

void main() {
  group('DoubleExtensions', () {
    group('formatAsCurrency', () {
      test('should format double as currency', () {
        expect(123.45.formatAsCurrency(), '₺123.45');
        expect(100.0.formatAsCurrency(symbol: '\$'), '\$100.00');
        expect(50.123.formatAsCurrency(decimalPlaces: 3), '₺50.123');
        expect(200.0.formatAsCurrency(showSymbol: false), '200.00');
      });
    });

    group('formatAsPercentage', () {
      test('should format double as percentage', () {
        expect(50.0.formatAsPercentage(), '50.0%');
        expect(75.567.formatAsPercentage(decimalPlaces: 2), '75.57%');
        expect(100.0.formatAsPercentage(showSymbol: false), '100.0');
      });
    });

    group('roundToDecimalPlaces', () {
      test('should round to specified decimal places', () {
        expect(123.456.roundToDecimalPlaces(2), 123.46);
        expect(123.454.roundToDecimalPlaces(2), 123.45);
        expect(123.0.roundToDecimalPlaces(2), 123.0);
      });
    });

    group('isBetween', () {
      test('should check if value is between min and max', () {
        expect(5.0.isBetween(1.0, 10.0), true);
        expect(1.0.isBetween(1.0, 10.0), true);
        expect(10.0.isBetween(1.0, 10.0), true);
        expect(0.0.isBetween(1.0, 10.0), false);
        expect(11.0.isBetween(1.0, 10.0), false);
      });
    });

    group('clampBetween', () {
      test('should clamp value between min and max', () {
        expect(5.0.clampBetween(1.0, 10.0), 5.0);
        expect(0.0.clampBetween(1.0, 10.0), 1.0);
        expect(15.0.clampBetween(1.0, 10.0), 10.0);
      });
    });

    group('Percentage operations', () {
      test('toPercentage should multiply by 100', () {
        expect(0.5.toPercentage(), 50.0);
        expect(0.75.toPercentage(), 75.0);
        expect(1.0.toPercentage(), 100.0);
      });

      test('fromPercentage should divide by 100', () {
        expect(50.0.fromPercentage(), 0.5);
        expect(75.0.fromPercentage(), 0.75);
        expect(100.0.fromPercentage(), 1.0);
      });

      test('percentageOf should calculate percentage of value', () {
        expect(25.0.percentageOf(100.0), 25.0);
        expect(50.0.percentageOf(200.0), 25.0);
      });

      test('asPercentageOf should calculate what percentage this is of total', () {
        expect(25.0.asPercentageOf(100.0), 25.0);
        expect(50.0.asPercentageOf(200.0), 25.0);
        expect(100.0.asPercentageOf(0.0), 0.0);
      });
    });

    group('Percentage adjustments', () {
      test('increaseByPercentage should increase value by percentage', () {
        expect(100.0.increaseByPercentage(50.0), 150.0);
        expect(200.0.increaseByPercentage(25.0), 250.0);
      });

      test('decreaseByPercentage should decrease value by percentage', () {
        expect(100.0.decreaseByPercentage(50.0), 50.0);
        expect(200.0.decreaseByPercentage(25.0), 150.0);
      });

      test('percentageDifference should calculate percentage difference', () {
        expect(150.0.percentageDifference(100.0), 50.0);
        expect(75.0.percentageDifference(100.0), -25.0);
        expect(100.0.percentageDifference(0.0), 0.0);
      });
    });

    group('isApproximatelyEqual', () {
      test('should check if values are approximately equal', () {
        expect(1.0.isApproximatelyEqual(1.0001), true);
        expect(1.0.isApproximatelyEqual(1.1), false);
        expect(1.0.isApproximatelyEqual(1.01, tolerance: 0.1), true);
      });
    });

    group('formatWithSeparators', () {
      test('should format number with thousand separators', () {
        expect(1234.56.formatWithSeparators(), '1,234.56');
        expect(1234567.89.formatWithSeparators(), '1,234,567.89');
        expect(123.45.formatWithSeparators(separator: ' '), '123.45');
      });
    });

    group('toHumanReadable', () {
      test('should convert to human readable format', () {
        expect(1234.0.toHumanReadable(), '1.2K');
        expect(1234567.0.toHumanReadable(), '1.2M');
        expect(1234567890.0.toHumanReadable(), '1.2B');
        expect(123.0.toHumanReadable(), '123.0');
      });
    });

    group('Interest calculations', () {
      test('calculateCompoundInterest should calculate compound interest', () {
        final result = 1000.0.calculateCompoundInterest(
          rate: 5.0,
          periods: 2,
          compoundingFrequency: 1,
        );
        expect(result, closeTo(1102.5, 0.1));
      });

      test('calculateSimpleInterest should calculate simple interest', () {
        final result = 1000.0.calculateSimpleInterest(
          rate: 5.0,
          periods: 2,
        );
        expect(result, 1100.0);
      });
    });

    group('VAT calculations', () {
      test('calculateVat should calculate VAT amount', () {
        expect(100.0.calculateVat(), 20.0);
        expect(100.0.calculateVat(vatRate: 0.25), 25.0);
      });

      test('withVat should add VAT to price', () {
        expect(100.0.withVat(), 120.0);
        expect(100.0.withVat(vatRate: 0.25), 125.0);
      });

      test('withoutVat should remove VAT from price', () {
        expect(120.0.withoutVat(), 100.0);
        expect(125.0.withoutVat(vatRate: 0.25), 100.0);
      });
    });

    group('Discount calculations', () {
      test('calculateDiscount should calculate discount amount', () {
        expect(100.0.calculateDiscount(discountRate: 20.0), 20.0);
        expect(200.0.calculateDiscount(discountRate: 15.0), 30.0);
      });

      test('applyDiscount should apply discount to price', () {
        expect(100.0.applyDiscount(discountRate: 20.0), 80.0);
        expect(200.0.applyDiscount(discountRate: 15.0), 170.0);
      });
    });

    group('Margin calculations', () {
      test('calculateMargin should calculate margin amount', () {
        expect(100.0.calculateMargin(marginRate: 20.0), 20.0);
        expect(200.0.calculateMargin(marginRate: 15.0), 30.0);
      });

      test('applyMargin should apply margin to price', () {
        expect(100.0.applyMargin(marginRate: 20.0), 120.0);
        expect(200.0.applyMargin(marginRate: 15.0), 230.0);
      });
    });

    group('Currency conversions', () {
      test('toTurkishLira should convert to TL', () {
        expect(1.0.toTurkishLira(exchangeRate: 30.0), 30.0);
        expect(10.0.toTurkishLira(exchangeRate: 25.5), 255.0);
      });

      test('toUsd should convert to USD', () {
        expect(30.0.toUsd(exchangeRate: 30.0), 1.0);
        expect(255.0.toUsd(exchangeRate: 25.5), 10.0);
      });
    });

    group('Number properties', () {
      test('isPositive should check if number is positive', () {
        expect(5.0.isPositive, true);
        expect(0.0.isPositive, false);
        expect((-5.0).isPositive, false);
      });

      test('isNegative should check if number is negative', () {
        expect((-5.0).isNegative, true);
        expect(0.0.isNegative, false);
        expect(5.0.isNegative, false);
      });

      test('isZero should check if number is zero', () {
        expect(0.0.isZero, true);
        expect(5.0.isZero, false);
        expect((-5.0).isZero, false);
      });

      test('isWhole should check if number is whole', () {
        expect(5.0.isWhole, true);
        expect(5.5.isWhole, false);
        expect((-5.0).isWhole, true);
      });

      test('fractionalPart should get fractional part', () {
        expect(5.25.fractionalPart, 0.25);
        expect((-5.75).fractionalPart, -0.75);
        expect(5.0.fractionalPart, 0.0);
      });
    });

    group('Currency formatting', () {
      test('toTurkishLiraFormat should format as Turkish Lira', () {
        expect(123.45.toTurkishLiraFormat(), '₺123.45');
        expect(100.0.toTurkishLiraFormat(showSymbol: false), '100.00');
      });

      test('toUsdFormat should format as USD', () {
        expect(123.45.toUsdFormat(), '\$123.45');
        expect(100.0.toUsdFormat(showSymbol: false), '100.00');
      });

      test('toEurFormat should format as EUR', () {
        expect(123.45.toEurFormat(), '€123.45');
        expect(100.0.toEurFormat(showSymbol: false), '100.00');
      });
    });
  });

  group('NullableDoubleExtensions', () {
    group('orZero', () {
      test('should return value or zero', () {
        expect((null as double?).orZero, 0.0);
        expect(123.45.orZero, 123.45);
      });
    });

    group('orDefault', () {
      test('should return value or default', () {
        expect((null as double?).orDefault(), 0.0);
        expect((null as double?).orDefault(99.0), 99.0);
        expect(123.45.orDefault(99.0), 123.45);
      });
    });

    group('formatAsCurrencyOrEmpty', () {
      test('should format as currency or return empty string', () {
        expect((null as double?).formatAsCurrencyOrEmpty(), '');
        expect(123.45.formatAsCurrencyOrEmpty(), '₺123.45');
      });
    });

    group('formatAsPercentageOrEmpty', () {
      test('should format as percentage or return empty string', () {
        expect((null as double?).formatAsPercentageOrEmpty(), '');
        expect(50.0.formatAsPercentageOrEmpty(), '50.0%');
      });
    });

    group('isNullOrZero', () {
      test('should check if value is null or zero', () {
        expect((null as double?).isNullOrZero, true);
        expect(0.0.isNullOrZero, true);
        expect(5.0.isNullOrZero, false);
      });
    });

    group('isNotNullOrZero', () {
      test('should check if value is not null and not zero', () {
        expect((null as double?).isNotNullOrZero, false);
        expect(0.0.isNotNullOrZero, false);
        expect(5.0.isNotNullOrZero, true);
      });
    });
  });
}
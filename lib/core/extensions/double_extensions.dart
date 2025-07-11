// Import required for pow function
import 'dart:math';

// Double Extensions for improved number handling
extension DoubleExtensions on double {
  /// Formats the double as currency
  String formatAsCurrency({
    String symbol = '₺',
    int decimalPlaces = 2,
    bool showSymbol = true,
  }) {
    final formatted = toStringAsFixed(decimalPlaces);
    return showSymbol ? '$symbol$formatted' : formatted;
  }

  /// Formats the double as percentage
  String formatAsPercentage({
    int decimalPlaces = 1,
    bool showSymbol = true,
  }) {
    final formatted = toStringAsFixed(decimalPlaces);
    return showSymbol ? '$formatted%' : formatted;
  }

  /// Rounds to specified decimal places
  double roundToDecimalPlaces(int decimalPlaces) {
    final factor = pow(10, decimalPlaces).toDouble();
    return (this * factor).round() / factor;
  }

  /// Checks if the number is between min and max (inclusive)
  bool isBetween(double min, double max) {
    return this >= min && this <= max;
  }

  /// Clamps the value between min and max
  double clampBetween(double min, double max) {
    return clamp(min, max).toDouble();
  }

  /// Converts to percentage (multiply by 100)
  double toPercentage() {
    return this * 100;
  }

  /// Converts from percentage (divide by 100)
  double fromPercentage() {
    return this / 100;
  }

  /// Calculates percentage of a value
  double percentageOf(double value) {
    return (this / value) * 100;
  }

  /// Calculates what percentage this number is of another number
  double asPercentageOf(double total) {
    if (total == 0) return 0;
    return (this / total) * 100;
  }

  /// Applies a percentage increase
  double increaseByPercentage(double percentage) {
    return this * (1 + percentage / 100);
  }

  /// Applies a percentage decrease
  double decreaseByPercentage(double percentage) {
    return this * (1 - percentage / 100);
  }

  /// Calculates the difference as a percentage
  double percentageDifference(double other) {
    if (other == 0) return 0;
    return ((this - other) / other) * 100;
  }

  /// Checks if the number is approximately equal to another
  bool isApproximatelyEqual(double other, {double tolerance = 0.001}) {
    return (this - other).abs() < tolerance;
  }

  /// Formats with thousand separators
  String formatWithSeparators({
    String separator = ',',
    int decimalPlaces = 2,
  }) {
    final formatted = toStringAsFixed(decimalPlaces);
    final parts = formatted.split('.');
    final wholePart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    final withSeparators = wholePart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}$separator',
    );
    
    return withSeparators + decimalPart;
  }

  /// Converts to a human-readable string (e.g., 1.2K, 3.4M)
  String toHumanReadable({int decimalPlaces = 1}) {
    if (abs() < 1000) return toStringAsFixed(decimalPlaces);
    if (abs() < 1000000) return '${(this / 1000).toStringAsFixed(decimalPlaces)}K';
    if (abs() < 1000000000) return '${(this / 1000000).toStringAsFixed(decimalPlaces)}M';
    return '${(this / 1000000000).toStringAsFixed(decimalPlaces)}B';
  }

  /// Calculates compound interest
  double calculateCompoundInterest({
    required double rate,
    required int periods,
    required int compoundingFrequency,
  }) {
    final r = rate / 100;
    final n = compoundingFrequency.toDouble();
    final t = periods.toDouble();
    return this * pow(1 + r / n, n * t);
  }

  /// Calculates simple interest
  double calculateSimpleInterest({
    required double rate,
    required int periods,
  }) {
    final r = rate / 100;
    final t = periods.toDouble();
    return this * (1 + r * t);
  }

  /// Calculates VAT amount
  double calculateVat({double vatRate = 0.20}) {
    return this * vatRate;
  }

  /// Calculates price with VAT
  double withVat({double vatRate = 0.20}) {
    return this * (1 + vatRate);
  }

  /// Calculates price without VAT
  double withoutVat({double vatRate = 0.20}) {
    return this / (1 + vatRate);
  }

  /// Calculates discount amount
  double calculateDiscount({required double discountRate}) {
    return this * (discountRate / 100);
  }

  /// Applies discount
  double applyDiscount({required double discountRate}) {
    return this * (1 - discountRate / 100);
  }

  /// Calculates margin amount
  double calculateMargin({required double marginRate}) {
    return this * (marginRate / 100);
  }

  /// Applies margin
  double applyMargin({required double marginRate}) {
    return this * (1 + marginRate / 100);
  }

  /// Converts to TL from USD
  double toTurkishLira({required double exchangeRate}) {
    return this * exchangeRate;
  }

  /// Converts to USD from TL
  double toUsd({required double exchangeRate}) {
    return this / exchangeRate;
  }

  /// Checks if the number is positive
  bool get isPositive => this > 0;

  /// Checks if the number is negative
  bool get isNegative => this < 0;

  /// Checks if the number is zero
  bool get isZero => this == 0;

  /// Gets the absolute value
  double get absolute => abs();

  /// Checks if the number is a whole number
  bool get isWhole => this == roundToDouble();

  /// Gets the fractional part
  double get fractionalPart => this - truncateToDouble();

  /// Converts to Turkish Lira format
  String toTurkishLiraFormat({bool showSymbol = true}) {
    return formatAsCurrency(
      symbol: showSymbol ? '₺' : '',
      decimalPlaces: 2,
      showSymbol: showSymbol,
    );
  }

  /// Converts to USD format
  String toUsdFormat({bool showSymbol = true}) {
    return formatAsCurrency(
      symbol: showSymbol ? '\$' : '',
      decimalPlaces: 2,
      showSymbol: showSymbol,
    );
  }

  /// Converts to EUR format
  String toEurFormat({bool showSymbol = true}) {
    return formatAsCurrency(
      symbol: showSymbol ? '€' : '',
      decimalPlaces: 2,
      showSymbol: showSymbol,
    );
  }
}

// Nullable double extensions
extension NullableDoubleExtensions on double? {
  /// Returns the value or zero if null
  double get orZero => this ?? 0.0;

  /// Returns the value or a default if null
  double orDefault([double defaultValue = 0.0]) {
    return this ?? defaultValue;
  }

  /// Safely formats as currency
  String formatAsCurrencyOrEmpty({
    String symbol = '₺',
    int decimalPlaces = 2,
    bool showSymbol = true,
  }) {
    return this?.formatAsCurrency(
      symbol: symbol,
      decimalPlaces: decimalPlaces,
      showSymbol: showSymbol,
    ) ?? '';
  }

  /// Safely formats as percentage
  String formatAsPercentageOrEmpty({
    int decimalPlaces = 1,
    bool showSymbol = true,
  }) {
    return this?.formatAsPercentage(
      decimalPlaces: decimalPlaces,
      showSymbol: showSymbol,
    ) ?? '';
  }

  /// Checks if the value is null or zero
  bool get isNullOrZero => this == null || this == 0.0;

  /// Checks if the value is not null and not zero
  bool get isNotNullOrZero => this != null && this != 0.0;
}
// String Extensions for improved code readability
extension StringExtensions on String {
  /// Capitalizes the first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalizes the first letter of each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Checks if the string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Checks if the string is a valid phone number
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');
    return phoneRegex.hasMatch(this);
  }

  /// Checks if the string is a valid PIN code
  bool get isValidPin {
    final pinRegex = RegExp(r'^[0-9]{4,8}$');
    return pinRegex.hasMatch(this);
  }

  /// Checks if the string is a valid number
  bool get isValidNumber {
    return double.tryParse(this) != null;
  }

  /// Checks if the string is a valid percentage
  bool get isValidPercentage {
    final value = double.tryParse(this);
    return value != null && value >= 0 && value <= 100;
  }

  /// Removes all whitespace from the string
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Truncates the string to a maximum length
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength - suffix.length) + suffix;
  }

  /// Checks if the string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Checks if the string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Converts string to double with default value
  double toDoubleOrDefault([double defaultValue = 0.0]) {
    return double.tryParse(this) ?? defaultValue;
  }

  /// Converts string to int with default value
  int toIntOrDefault([int defaultValue = 0]) {
    return int.tryParse(this) ?? defaultValue;
  }

  /// Formats currency string
  String formatAsCurrency({String symbol = '₺', int decimalPlaces = 2}) {
    final value = double.tryParse(this);
    if (value == null) return this;
    return '$symbol${value.toStringAsFixed(decimalPlaces)}';
  }

  /// Formats percentage string
  String formatAsPercentage({int decimalPlaces = 1}) {
    final value = double.tryParse(this);
    if (value == null) return this;
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  /// Masks the string (useful for sensitive data)
  String mask({String maskChar = '*', int visibleChars = 4}) {
    if (length <= visibleChars) return this;
    final visible = substring(0, visibleChars);
    final masked = maskChar * (length - visibleChars);
    return visible + masked;
  }

  /// Checks if string contains only digits
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Checks if string contains only letters
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Checks if string contains only letters and numbers
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Reverses the string
  String reverse() {
    return split('').reversed.join('');
  }

  /// Counts the number of words in the string
  int get wordCount {
    return trim().split(RegExp(r'\s+')).length;
  }

  /// Extracts numbers from the string
  List<double> extractNumbers() {
    final numbers = <double>[];
    final matches = RegExp(r'\d+\.?\d*').allMatches(this);
    for (final match in matches) {
      final number = double.tryParse(match.group(0)!);
      if (number != null) numbers.add(number);
    }
    return numbers;
  }

  /// Converts to kebab-case
  String toKebabCase() {
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) => '-${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Converts to snake_case
  String toSnakeCase() {
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Converts to camelCase
  String toCamelCase() {
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    return words.first.toLowerCase() + 
           words.skip(1).map((word) => word.capitalize()).join('');
  }
}

// Nullable string extensions
extension NullableStringExtensions on String? {
  /// Checks if the string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Checks if the string is not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns the string or a default value if null
  String orDefault([String defaultValue = '']) {
    return this ?? defaultValue;
  }

  /// Returns the string or 'N/A' if null or empty
  String get orNA {
    return isNullOrEmpty ? 'N/A' : this!;
  }

  /// Safely converts to double
  double? toDoubleOrNull() {
    return this == null ? null : double.tryParse(this!);
  }

  /// Safely converts to int
  int? toIntOrNull() {
    return this == null ? null : int.tryParse(this!);
  }
}
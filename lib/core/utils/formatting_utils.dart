// Formatting utilities for consistent data presentation
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class FormattingUtils {
  // Prevent instantiation
  FormattingUtils._();

  /// Formats currency with proper locale
  static String formatCurrency(
    double amount, {
    String currencyCode = 'TRY',
    String locale = 'tr_TR',
    bool showSymbol = true,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: showSymbol ? _getCurrencySymbol(currencyCode) : '',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formats percentage with proper locale
  static String formatPercentage(
    double value, {
    String locale = 'tr_TR',
    int decimalPlaces = 1,
    bool showSymbol = true,
  }) {
    final formatter = NumberFormat.percentPattern(locale);
    formatter.maximumFractionDigits = decimalPlaces;
    formatter.minimumFractionDigits = decimalPlaces;
    
    final formatted = formatter.format(value / 100);
    return showSymbol ? formatted : formatted.replaceAll('%', '');
  }

  /// Formats number with thousand separators
  static String formatNumber(
    double number, {
    String locale = 'tr_TR',
    int decimalPlaces = 2,
  }) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}', locale);
    return formatter.format(number);
  }

  /// Formats date with proper locale
  static String formatDate(
    DateTime date, {
    String locale = 'tr_TR',
    String pattern = 'dd/MM/yyyy',
  }) {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(date);
  }

  /// Formats datetime with proper locale
  static String formatDateTime(
    DateTime dateTime, {
    String locale = 'tr_TR',
    String pattern = 'dd/MM/yyyy HH:mm',
  }) {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(dateTime);
  }

  /// Formats time with proper locale
  static String formatTime(
    DateTime time, {
    String locale = 'tr_TR',
    String pattern = 'HH:mm',
  }) {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(time);
  }

  /// Formats file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Formats duration in human readable format
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Formats Turkish ID number with proper masking
  static String formatTurkishId(String id, {bool mask = true}) {
    if (id.length != 11) return id;
    
    if (mask) {
      return '${id.substring(0, 3)}***${id.substring(8)}';
    } else {
      return id;
    }
  }

  /// Formats phone number with proper formatting
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Turkish phone number format
    if (digitsOnly.length == 11 && digitsOnly.startsWith('0')) {
      return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7, 9)} ${digitsOnly.substring(9)}';
    }
    
    // International format
    if (digitsOnly.length == 13 && digitsOnly.startsWith('90')) {
      return '+90 ${digitsOnly.substring(2, 5)} ${digitsOnly.substring(5, 8)} ${digitsOnly.substring(8, 10)} ${digitsOnly.substring(10)}';
    }
    
    return phone; // Return original if no format matches
  }

  /// Formats credit card number with proper spacing
  static String formatCreditCard(String cardNumber) {
    final digitsOnly = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    final formatted = StringBuffer();
    
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(digitsOnly[i]);
    }
    
    return formatted.toString();
  }

  /// Formats IBAN with proper spacing
  static String formatIban(String iban) {
    final upperCase = iban.toUpperCase().replaceAll(RegExp(r'[^\w]'), '');
    final formatted = StringBuffer();
    
    for (int i = 0; i < upperCase.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(upperCase[i]);
    }
    
    return formatted.toString();
  }

  /// Formats exchange rate with proper precision
  static String formatExchangeRate(double rate) {
    if (rate >= 10) {
      return rate.toStringAsFixed(2);
    } else if (rate >= 1) {
      return rate.toStringAsFixed(3);
    } else {
      return rate.toStringAsFixed(4);
    }
  }

  /// Formats calculation steps for display
  static String formatCalculationStep(String description, double value, String type) {
    final formattedValue = formatCurrency(value);
    return '$description: $formattedValue';
  }

  /// Formats discount breakdown
  static String formatDiscountBreakdown(List<double> discounts) {
    if (discounts.isEmpty) return 'No discounts applied';
    
    final formatted = discounts
        .asMap()
        .entries
        .where((entry) => entry.value > 0)
        .map((entry) => 'Discount ${entry.key + 1}: ${formatPercentage(entry.value)}')
        .join(', ');
    
    return formatted.isEmpty ? 'No discounts applied' : formatted;
  }

  /// Formats price comparison
  static String formatPriceComparison(double originalPrice, double finalPrice) {
    final difference = finalPrice - originalPrice;
    final percentageChange = (difference / originalPrice) * 100;
    
    final sign = difference >= 0 ? '+' : '';
    final changeText = '$sign${formatCurrency(difference)} ($sign${formatPercentage(percentageChange)})';
    
    return changeText;
  }

  /// Formats validation error messages
  static String formatValidationError(String fieldName, String errorType) {
    switch (errorType) {
      case 'required':
        return '$fieldName is required';
      case 'invalid':
        return '$fieldName is invalid';
      case 'tooShort':
        return '$fieldName is too short';
      case 'tooLong':
        return '$fieldName is too long';
      case 'outOfRange':
        return '$fieldName is out of range';
      default:
        return 'Invalid $fieldName';
    }
  }

  /// Formats API response status
  static String formatApiStatus(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'Success';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      default:
        return 'Status Code: $statusCode';
    }
  }

  /// Helper method to get currency symbol
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'TRY':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currencyCode;
    }
  }

  /// Formats calculation summary
  static String formatCalculationSummary({
    required double originalPrice,
    required double finalPrice,
    required String currency,
    required List<double> discounts,
    required double profitMargin,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Original Price: ${formatCurrency(originalPrice)}');
    
    if (discounts.any((d) => d > 0)) {
      buffer.writeln('Discounts: ${formatDiscountBreakdown(discounts)}');
    }
    
    if (profitMargin > 0) {
      buffer.writeln('Profit Margin: ${formatPercentage(profitMargin)}');
    }
    
    buffer.writeln('Final Price: ${formatCurrency(finalPrice)}');
    
    return buffer.toString();
  }

  /// Formats export filename with timestamp
  static String formatExportFilename(String baseName, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${baseName}_$timestamp.$extension';
  }

  /// Formats database backup filename
  static String formatBackupFilename() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'price_list_backup_$timestamp.db';
  }
}

// Utility class for number formatting
class NumberFormatUtils {
  // Prevent instantiation
  NumberFormatUtils._();

  /// Safely parses double with fallback
  static double parseDouble(String value, {double fallback = 0.0}) {
    return double.tryParse(value.trim()) ?? fallback;
  }

  /// Safely parses int with fallback
  static int parseInt(String value, {int fallback = 0}) {
    return int.tryParse(value.trim()) ?? fallback;
  }

  /// Validates and formats percentage input
  static String formatPercentageInput(String input) {
    final value = double.tryParse(input);
    if (value == null) return input;
    
    if (value > 100) return '100';
    if (value < 0) return '0';
    
    return value.toString();
  }

  /// Validates and formats price input
  static String formatPriceInput(String input) {
    final value = double.tryParse(input);
    if (value == null) return input;
    
    if (value > AppConstants.maxPriceValue) {
      return AppConstants.maxPriceValue.toString();
    }
    if (value < 0) return '0';
    
    return value.toString();
  }

  /// Formats input for display (removes trailing zeros)
  static String formatForDisplay(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toString();
  }
}
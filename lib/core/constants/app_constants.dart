// Application Constants
class AppConstants {
  // API URLs
  static const String exchangeRateUrl = 'https://www.isbank.com.tr/doviz-kurlari';
  static const String exchangeRateApiUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
  
  // Default Values
  static const double defaultProfitMargin = 40.0;
  static const double defaultVatRate = 0.20; // 20% VAT
  static const int maxDiscountLevels = 3;
  static const double maxDiscountPercentage = 100.0;
  static const double maxPriceValue = 1000000.0;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultButtonPadding = 12.0;
  static const double defaultCardElevation = 2.0;
  
  // Validation Constants
  static const int minPresetLabelLength = 2;
  static const int maxPresetLabelLength = 50;
  static const int minProductNameLength = 2;
  static const int maxProductNameLength = 100;
  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  
  // Database Constants
  static const String databaseName = 'price_list_db';
  static const String discountPresetsBox = 'discount_presets';
  static const String calculationRecordsBox = 'calculation_records';
  static const String settingsBox = 'settings';
  
  // Settings Keys
  static const String languageKey = 'language';
  static const String pinCodeKey = 'pin_code';
  static const String themeKey = 'theme';
  
  // Supported Currencies
  static const List<String> supportedCurrencies = ['USD', 'EUR'];
  
  // Network Constants
  static const int defaultTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // File Constants
  static const String exportFileName = 'price_calculations';
  static const List<String> supportedExportFormats = ['CSV', 'PDF', 'XLSX'];
  
  // Error Messages
  static const String genericErrorMessage = 'An unexpected error occurred';
  static const String networkErrorMessage = 'Network connection failed';
  static const String validationErrorMessage = 'Please check your input';
  
  // Privacy and Security
  static const String privacyPolicyUrl = 'https://example.com/privacy-policy';
  static const String termsOfServiceUrl = 'https://example.com/terms-of-service';
  
  // App Information
  static const String appName = 'Price List Calculator';
  static const String appVersion = '2.0.0';
  static const String appDescription = 'Professional price calculation tool';
  
  // Prevent instantiation
  AppConstants._();
}

// Enum for calculation types
enum CalculationType {
  basic,
  withDiscount,
  withProfitMargin,
  withVat,
  complete,
}

// Enum for export formats
enum ExportFormat {
  csv,
  pdf,
  xlsx,
}

// Enum for themes
enum AppTheme {
  light,
  dark,
  system,
}

// Enum for languages
enum AppLanguage {
  turkish,
  english,
}

// Extension methods for enums
extension CalculationTypeExtension on CalculationType {
  String get displayName {
    switch (this) {
      case CalculationType.basic:
        return 'Basic';
      case CalculationType.withDiscount:
        return 'With Discount';
      case CalculationType.withProfitMargin:
        return 'With Profit Margin';
      case CalculationType.withVat:
        return 'With VAT';
      case CalculationType.complete:
        return 'Complete Calculation';
    }
  }
}

extension ExportFormatExtension on ExportFormat {
  String get extension {
    switch (this) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.xlsx:
        return 'xlsx';
    }
  }
  
  String get displayName {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.xlsx:
        return 'Excel';
    }
  }
}

extension AppThemeExtension on AppTheme {
  String get displayName {
    switch (this) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }
}

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.turkish:
        return 'tr';
      case AppLanguage.english:
        return 'en';
    }
  }
  
  String get displayName {
    switch (this) {
      case AppLanguage.turkish:
        return 'Türkçe';
      case AppLanguage.english:
        return 'English';
    }
  }
}
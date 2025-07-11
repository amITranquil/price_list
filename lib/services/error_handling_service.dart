import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ErrorType {
  network,
  validation,
  storage,
  authentication,
  calculation,
  fileOperation,
  unknown,
}

class AppError {
  final ErrorType type;
  final String message;
  final String? localizedKey;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.localizedKey,
    this.originalError,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, timestamp: $timestamp)';
  }
}

abstract class ErrorHandlingService {
  void handleError(AppError error);
  void showErrorSnackBar(BuildContext context, AppError error);
  void showErrorDialog(BuildContext context, AppError error);
  String getLocalizedErrorMessage(BuildContext context, AppError error);
  void logError(AppError error);
}

class StandardErrorHandlingService implements ErrorHandlingService {
  @override
  void handleError(AppError error) {
    // Log the error
    logError(error);
    
    // You can add additional error handling logic here
    // such as reporting to crash analytics, etc.
  }

  @override
  void showErrorSnackBar(BuildContext context, AppError error) {
    if (!context.mounted) return;
    
    final message = getLocalizedErrorMessage(context, error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'OK',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void showErrorDialog(BuildContext context, AppError error) {
    if (!context.mounted) return;
    
    final l10n = AppLocalizations.of(context)!;
    final message = getLocalizedErrorMessage(context, error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getErrorTitle(l10n, error.type)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  String getLocalizedErrorMessage(BuildContext context, AppError error) {
    final l10n = AppLocalizations.of(context)!;
    
    // If we have a localized key, try to use it
    if (error.localizedKey != null) {
      try {
        return _getLocalizedMessage(l10n, error.localizedKey!);
      } catch (e) {
        // If localized key doesn't exist, fall back to default message
      }
    }
    
    // Default error messages based on type
    switch (error.type) {
      case ErrorType.network:
        return l10n.dataUnavailable;
      case ErrorType.validation:
        return error.message;
      case ErrorType.storage:
        return l10n.storageErrorOccurred;
      case ErrorType.authentication:
        return l10n.incorrectPin;
      case ErrorType.calculation:
        return l10n.errorCalculation;
      case ErrorType.fileOperation:
        return l10n.fileOperationFailed;
      case ErrorType.unknown:
        return l10n.unexpectedError;
    }
  }

  @override
  void logError(AppError error) {
    // Simple console logging for now
    // In a production app, you would use a proper logging service
    debugPrint('ERROR [${error.type}] ${error.message}');
    if (error.stackTrace != null) {
      debugPrint('Stack trace: ${error.stackTrace}');
    }
  }

  String _getErrorTitle(AppLocalizations l10n, ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return l10n.networkError;
      case ErrorType.validation:
        return l10n.validationError;
      case ErrorType.storage:
        return l10n.storageError;
      case ErrorType.authentication:
        return l10n.authenticationError;
      case ErrorType.calculation:
        return l10n.calculationError;
      case ErrorType.fileOperation:
        return l10n.fileError;
      case ErrorType.unknown:
        return l10n.error;
    }
  }

  String _getLocalizedMessage(AppLocalizations l10n, String key) {
    // This is a simplified approach - in a real app you might use reflection
    // or a more sophisticated localization key lookup system
    switch (key) {
      case 'originalPriceEmpty':
        return l10n.originalPriceEmpty;
      case 'incorrectPin':
        return l10n.incorrectPin;
      case 'presetLabelEmpty':
        return l10n.presetLabelEmpty;
      case 'productNameRequired':
        return l10n.productNameRequired;
      case 'calculationRequired':
        return l10n.calculationRequired;
      case 'errorCalculation':
        return l10n.errorCalculation;
      case 'dataUnavailable':
        return l10n.dataUnavailable;
      case 'invalidPriceFormat':
        return l10n.invalidPriceFormat;
      case 'priceGreaterThanZero':
        return l10n.priceGreaterThanZero;
      case 'priceTooLarge':
        return l10n.priceTooLarge;
      case 'invalidPercentageFormat':
        return l10n.invalidPercentageFormat;
      case 'percentageCannotBeNegative':
        return l10n.percentageCannotBeNegative;
      case 'percentageCannotBeGreaterThan100':
        return l10n.percentageCannotBeGreaterThan100;
      case 'presetLabelTooShort':
        return l10n.presetLabelTooShort;
      case 'presetLabelTooLong':
        return l10n.presetLabelTooLong;
      case 'productNameTooShort':
        return l10n.productNameTooShort;
      case 'productNameTooLong':
        return l10n.productNameTooLong;
      case 'pinCodeEmpty':
        return l10n.pinCodeEmpty;
      case 'pinCodeTooShort':
        return l10n.pinCodeTooShort;
      case 'pinCodeTooLong':
        return l10n.pinCodeTooLong;
      case 'pinCodeOnlyNumbers':
        return l10n.pinCodeOnlyNumbers;
      default:
        throw ArgumentError('Unknown localization key: $key');
    }
  }
}

// Extension methods for easier error creation
extension ErrorTypeExtensions on ErrorType {
  AppError createError(String message, [String? localizedKey, dynamic originalError, StackTrace? stackTrace]) {
    return AppError(
      type: this,
      message: message,
      localizedKey: localizedKey,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}

// Common error factory methods
class ErrorFactory {
  static AppError networkError(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return ErrorType.network.createError(message, 'dataUnavailable', originalError, stackTrace);
  }

  static AppError validationError(String message, [String? localizedKey]) {
    return ErrorType.validation.createError(message, localizedKey);
  }

  static AppError storageError(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return ErrorType.storage.createError(message, null, originalError, stackTrace);
  }

  static AppError authenticationError(String message, [String? localizedKey]) {
    return ErrorType.authentication.createError(message, localizedKey ?? 'incorrectPin');
  }

  static AppError calculationError(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return ErrorType.calculation.createError(message, 'errorCalculation', originalError, stackTrace);
  }

  static AppError fileOperationError(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return ErrorType.fileOperation.createError(message, null, originalError, stackTrace);
  }

  static AppError unknownError(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return ErrorType.unknown.createError(message, null, originalError, stackTrace);
  }
}
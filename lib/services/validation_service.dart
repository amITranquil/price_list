import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../repositories/calculation_record_repository.dart';
import '../di/injection.dart';

abstract class ValidationService {
  ValidationResult validatePrice(String price, {AppLocalizations? l10n});
  ValidationResult validatePercentage(String percentage, {AppLocalizations? l10n});
  ValidationResult validatePresetLabel(String label, {AppLocalizations? l10n});
  ValidationResult validateProductName(String name, {AppLocalizations? l10n});
  ValidationResult validatePinCode(String pin, {AppLocalizations? l10n});
  Future<ValidationResult> validateUniqueProductName(String name, {AppLocalizations? l10n});
  
  // Deprecated - use main methods with l10n parameter
  @Deprecated('Use validatePrice with l10n parameter instead')
  ValidationResult validatePriceLocalized(String price, AppLocalizations l10n);
  @Deprecated('Use validatePercentage with l10n parameter instead')
  ValidationResult validatePercentageLocalized(String percentage, AppLocalizations l10n);
  @Deprecated('Use validatePresetLabel with l10n parameter instead')
  ValidationResult validatePresetLabelLocalized(String label, AppLocalizations l10n);
  @Deprecated('Use validateProductName with l10n parameter instead')
  ValidationResult validateProductNameLocalized(String name, AppLocalizations l10n);
  @Deprecated('Use validatePinCode with l10n parameter instead')
  ValidationResult validatePinCodeLocalized(String pin, AppLocalizations l10n);
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? localizedErrorKey;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.localizedErrorKey,
  });

  ValidationResult.success() : this(isValid: true);
  
  ValidationResult.error(String message, [String? localizedKey]) 
    : this(isValid: false, errorMessage: message, localizedErrorKey: localizedKey);
}

class StandardValidationService implements ValidationService {
  @override
  ValidationResult validatePrice(String price, {AppLocalizations? l10n}) {
    if (price.trim().isEmpty) {
      return ValidationResult.error(l10n!.originalPriceEmpty, 'originalPriceEmpty');
    }
    
    final parsedPrice = double.tryParse(price.trim());
    if (parsedPrice == null) {
      return ValidationResult.error(l10n!.invalidPriceFormat, 'invalidPriceFormat');
    }
    
    if (parsedPrice <= 0) {
      return ValidationResult.error(l10n!.priceGreaterThanZero, 'priceGreaterThanZero');
    }
    
    if (parsedPrice > 1000000) {
      return ValidationResult.error(l10n!.priceTooLarge, 'priceTooLarge');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePriceLocalized(String price, AppLocalizations l10n) {
    return validatePrice(price, l10n: l10n);
  }

  @override
  ValidationResult validatePercentage(String percentage, {AppLocalizations? l10n}) {
    if (percentage.trim().isEmpty) {
      return ValidationResult.success(); // Percentage fields can be empty
    }
    
    final parsedPercentage = double.tryParse(percentage.trim());
    if (parsedPercentage == null) {
      return ValidationResult.error(l10n!.invalidPercentageFormat, 'invalidPercentageFormat');
    }
    
    if (parsedPercentage < 0) {
      return ValidationResult.error(l10n!.percentageCannotBeNegative, 'percentageCannotBeNegative');
    }
    
    if (parsedPercentage > 100) {
      return ValidationResult.error(l10n!.percentageCannotBeGreaterThan100, 'percentageCannotBeGreaterThan100');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePercentageLocalized(String percentage, AppLocalizations l10n) {
    return validatePercentage(percentage, l10n: l10n);
  }

  @override
  ValidationResult validatePresetLabel(String label, {AppLocalizations? l10n}) {
    if (label.trim().isEmpty) {
      return ValidationResult.error(l10n!.presetLabelEmpty, 'presetLabelEmpty');
    }
    
    if (label.trim().length < 2) {
      return ValidationResult.error(l10n!.presetLabelTooShort, 'presetLabelTooShort');
    }
    
    if (label.trim().length > 50) {
      return ValidationResult.error(l10n!.presetLabelTooLong, 'presetLabelTooLong');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePresetLabelLocalized(String label, AppLocalizations l10n) {
    return validatePresetLabel(label, l10n: l10n);
  }

  @override
  ValidationResult validateProductName(String name, {AppLocalizations? l10n}) {
    if (name.trim().isEmpty) {
      return ValidationResult.error(l10n!.productNameRequired, 'productNameRequired');
    }
    
    if (name.trim().length < 2) {
      return ValidationResult.error(l10n!.productNameTooShort, 'productNameTooShort');
    }
    
    if (name.trim().length > 100) {
      return ValidationResult.error(l10n!.productNameTooLong, 'productNameTooLong');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validateProductNameLocalized(String name, AppLocalizations l10n) {
    return validateProductName(name, l10n: l10n);
  }

  @override
  ValidationResult validatePinCode(String pin, {AppLocalizations? l10n}) {
    if (pin.trim().isEmpty) {
      return ValidationResult.error(l10n!.pinCodeEmpty, 'pinCodeEmpty');
    }
    
    if (pin.trim().length < 4) {
      return ValidationResult.error(l10n!.pinCodeTooShort, 'pinCodeTooShort');
    }
    
    if (pin.trim().length > 8) {
      return ValidationResult.error(l10n!.pinCodeTooLong, 'pinCodeTooLong');
    }
    
    // Check if PIN contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(pin.trim())) {
      return ValidationResult.error(l10n!.pinCodeOnlyNumbers, 'pinCodeOnlyNumbers');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePinCodeLocalized(String pin, AppLocalizations l10n) {
    return validatePinCode(pin, l10n: l10n);
  }

  @override
  Future<ValidationResult> validateUniqueProductName(String name, {AppLocalizations? l10n}) async {
    // First check basic validation
    final basicValidation = validateProductName(name, l10n: l10n);
    if (!basicValidation.isValid) {
      return basicValidation;
    }
    
    // Then check if product name already exists
    try {
      final repository = getIt<CalculationRecordRepository>();
      final exists = await repository.productNameExists(name);
      
      if (exists) {
        return ValidationResult.error(
          l10n?.productNameAlreadyExists ?? 'Product name already exists',
          'productNameAlreadyExists'
        );
      }
      
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error(
        l10n?.validationCheckFailed ?? 'Validation check failed',
        'validationCheckFailed'
      );
    }
  }
}
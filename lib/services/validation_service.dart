abstract class ValidationService {
  ValidationResult validatePrice(String price);
  ValidationResult validatePercentage(String percentage);
  ValidationResult validatePresetLabel(String label);
  ValidationResult validateProductName(String name);
  ValidationResult validatePinCode(String pin);
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
  ValidationResult validatePrice(String price) {
    if (price.trim().isEmpty) {
      return ValidationResult.error('originalPriceEmpty', 'originalPriceEmpty');
    }
    
    final parsedPrice = double.tryParse(price.trim());
    if (parsedPrice == null) {
      return ValidationResult.error('invalidPriceFormat', 'invalidPriceFormat');
    }
    
    if (parsedPrice <= 0) {
      return ValidationResult.error('priceGreaterThanZero', 'priceGreaterThanZero');
    }
    
    if (parsedPrice > 1000000) {
      return ValidationResult.error('priceTooLarge', 'priceTooLarge');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePercentage(String percentage) {
    if (percentage.trim().isEmpty) {
      return ValidationResult.success(); // Percentage fields can be empty
    }
    
    final parsedPercentage = double.tryParse(percentage.trim());
    if (parsedPercentage == null) {
      return ValidationResult.error('invalidPercentageFormat', 'invalidPercentageFormat');
    }
    
    if (parsedPercentage < 0) {
      return ValidationResult.error('percentageCannotBeNegative', 'percentageCannotBeNegative');
    }
    
    if (parsedPercentage > 100) {
      return ValidationResult.error('percentageCannotBeGreaterThan100', 'percentageCannotBeGreaterThan100');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePresetLabel(String label) {
    if (label.trim().isEmpty) {
      return ValidationResult.error('presetLabelEmpty', 'presetLabelEmpty');
    }
    
    if (label.trim().length < 2) {
      return ValidationResult.error('presetLabelTooShort', 'presetLabelTooShort');
    }
    
    if (label.trim().length > 50) {
      return ValidationResult.error('presetLabelTooLong', 'presetLabelTooLong');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validateProductName(String name) {
    if (name.trim().isEmpty) {
      return ValidationResult.error('productNameRequired', 'productNameRequired');
    }
    
    if (name.trim().length < 2) {
      return ValidationResult.error('productNameTooShort', 'productNameTooShort');
    }
    
    if (name.trim().length > 100) {
      return ValidationResult.error('productNameTooLong', 'productNameTooLong');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePinCode(String pin) {
    if (pin.trim().isEmpty) {
      return ValidationResult.error('pinCodeEmpty', 'pinCodeEmpty');
    }
    
    if (pin.trim().length < 4) {
      return ValidationResult.error('pinCodeTooShort', 'pinCodeTooShort');
    }
    
    if (pin.trim().length > 8) {
      return ValidationResult.error('pinCodeTooLong', 'pinCodeTooLong');
    }
    
    // Check if PIN contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(pin.trim())) {
      return ValidationResult.error('pinCodeOnlyNumbers', 'pinCodeOnlyNumbers');
    }
    
    return ValidationResult.success();
  }
}
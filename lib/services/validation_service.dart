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
      return ValidationResult.error('Price cannot be empty', 'originalPriceEmpty');
    }
    
    final parsedPrice = double.tryParse(price.trim());
    if (parsedPrice == null) {
      return ValidationResult.error('Invalid price format', 'invalidPriceFormat');
    }
    
    if (parsedPrice <= 0) {
      return ValidationResult.error('Price must be greater than zero', 'priceGreaterThanZero');
    }
    
    if (parsedPrice > 1000000) {
      return ValidationResult.error('Price is too large', 'priceTooLarge');
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
      return ValidationResult.error('Invalid percentage format', 'invalidPercentageFormat');
    }
    
    if (parsedPercentage < 0) {
      return ValidationResult.error('Percentage cannot be negative', 'percentageCannotBeNegative');
    }
    
    if (parsedPercentage > 100) {
      return ValidationResult.error('Percentage cannot be greater than 100', 'percentageCannotBeGreaterThan100');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePresetLabel(String label) {
    if (label.trim().isEmpty) {
      return ValidationResult.error('Preset label cannot be empty', 'presetLabelEmpty');
    }
    
    if (label.trim().length < 2) {
      return ValidationResult.error('Preset label must be at least 2 characters', 'presetLabelTooShort');
    }
    
    if (label.trim().length > 50) {
      return ValidationResult.error('Preset label cannot be longer than 50 characters', 'presetLabelTooLong');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validateProductName(String name) {
    if (name.trim().isEmpty) {
      return ValidationResult.error('Product name is required', 'productNameRequired');
    }
    
    if (name.trim().length < 2) {
      return ValidationResult.error('Product name must be at least 2 characters', 'productNameTooShort');
    }
    
    if (name.trim().length > 100) {
      return ValidationResult.error('Product name cannot be longer than 100 characters', 'productNameTooLong');
    }
    
    return ValidationResult.success();
  }

  @override
  ValidationResult validatePinCode(String pin) {
    if (pin.trim().isEmpty) {
      return ValidationResult.error('PIN code cannot be empty', 'pinCodeEmpty');
    }
    
    if (pin.trim().length < 4) {
      return ValidationResult.error('PIN code must be at least 4 characters', 'pinCodeTooShort');
    }
    
    if (pin.trim().length > 8) {
      return ValidationResult.error('PIN code cannot be longer than 8 characters', 'pinCodeTooLong');
    }
    
    // Check if PIN contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(pin.trim())) {
      return ValidationResult.error('PIN code must contain only numbers', 'pinCodeOnlyNumbers');
    }
    
    return ValidationResult.success();
  }
}
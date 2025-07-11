import 'package:flutter/material.dart';
import '../services/exchange_rate_service.dart';
import '../services/price_calculation_service.dart';
import '../services/authentication_service.dart';
import '../services/validation_service.dart';
import '../services/error_handling_service.dart';
import '../repositories/discount_preset_repository.dart';
import '../repositories/calculation_record_repository.dart';
import '../models/discount_preset.dart';
import '../models/calculation_record.dart';
import '../di/injection.dart';

class PriceCalculatorController extends ChangeNotifier {
  // Services
  final ExchangeRateService _exchangeRateService = getIt<ExchangeRateService>();
  final PriceCalculationService _priceCalculationService = getIt<PriceCalculationService>();
  final AuthenticationService _authService = getIt<AuthenticationService>();
  final ValidationService _validationService = getIt<ValidationService>();
  final ErrorHandlingService _errorHandlingService = getIt<ErrorHandlingService>();
  final DiscountPresetRepository _presetRepository = getIt<DiscountPresetRepository>();
  final CalculationRecordRepository _recordRepository = getIt<CalculationRecordRepository>();

  // Controllers
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discount1Controller = TextEditingController();
  final TextEditingController discount2Controller = TextEditingController();
  final TextEditingController discount3Controller = TextEditingController();
  final TextEditingController profitController = TextEditingController();
  final TextEditingController presetLabelController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // State
  ExchangeRates? _exchangeRates;
  PriceCalculationResult? _calculationResult;
  List<DiscountPreset> _presets = [];
  DiscountPreset? _selectedPreset;
  String _selectedCurrency = 'USD';
  bool _isLoadingRates = false;
  bool _isAdvancedExpanded = false;
  bool _showPrices = false;
  String? _pinCode;

  // Getters
  ExchangeRates? get exchangeRates => _exchangeRates;
  PriceCalculationResult? get calculationResult => _calculationResult;
  List<DiscountPreset> get presets => _presets;
  DiscountPreset? get selectedPreset => _selectedPreset;
  String get selectedCurrency => _selectedCurrency;
  bool get isLoadingRates => _isLoadingRates;
  bool get isAdvancedExpanded => _isAdvancedExpanded;
  bool get showPrices => _showPrices;
  String? get pinCode => _pinCode;

  @override
  void dispose() {
    priceController.dispose();
    discount1Controller.dispose();
    discount2Controller.dispose();
    discount3Controller.dispose();
    profitController.dispose();
    presetLabelController.dispose();
    productNameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    // Load PIN code
    _pinCode = await _authService.hasPinCode() ? 'exists' : null;
    
    // Load presets
    await _loadPresets();
    
    // Load exchange rates
    await fetchExchangeRates();
    
    // Set default values
    profitController.text = '40';
    
    notifyListeners();
  }

  Future<void> fetchExchangeRates({bool useDirectScraping = true}) async {
    _isLoadingRates = true;
    notifyListeners();

    try {
      _exchangeRates = await _exchangeRateService.fetchRates(
        useDirectScraping: useDirectScraping,
      );
    } catch (e) {
      // Handle error
      _exchangeRates = null;
    }

    _isLoadingRates = false;
    notifyListeners();
  }

  Future<void> _loadPresets() async {
    try {
      _presets = await _presetRepository.getDiscountPresets();
      notifyListeners();
    } catch (e) {
      // Handle error
      _presets = [];
    }
  }

  void selectCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void selectPreset(DiscountPreset? preset) {
    _selectedPreset = preset;
    if (preset != null) {
      discount1Controller.text = preset.discounts.isNotEmpty ? preset.discounts[0].toString() : '';
      discount2Controller.text = preset.discounts.length > 1 ? preset.discounts[1].toString() : '';
      discount3Controller.text = preset.discounts.length > 2 ? preset.discounts[2].toString() : '';
      profitController.text = preset.profitMargin.toString();
    }
    notifyListeners();
  }

  void toggleAdvancedExpanded() {
    _isAdvancedExpanded = !_isAdvancedExpanded;
    notifyListeners();
  }

  Future<void> calculatePrice() async {
    try {
      // Validate price input
      final priceValidation = _validationService.validatePrice(priceController.text);
      if (!priceValidation.isValid) {
        _errorHandlingService.handleError(ErrorFactory.validationError(
          priceValidation.errorMessage!, 
          priceValidation.localizedErrorKey
        ));
        return;
      }

      // Validate exchange rates are available
      if (_exchangeRates == null) {
        _errorHandlingService.handleError(ErrorFactory.networkError('Exchange rates not available'));
        return;
      }

      final originalPrice = double.parse(priceController.text);
      final exchangeRate = _selectedCurrency == 'USD' 
          ? _exchangeRates!.usdRate 
          : _exchangeRates!.eurRate;
      
      if (exchangeRate == null) {
        _errorHandlingService.handleError(ErrorFactory.networkError('Selected currency rate not available'));
        return;
      }

      // Validate discount percentages
      final discountRates = <double>[];
      for (final controller in [discount1Controller, discount2Controller, discount3Controller]) {
        if (controller.text.isNotEmpty) {
          final validation = _validationService.validatePercentage(controller.text);
          if (!validation.isValid) {
            _errorHandlingService.handleError(ErrorFactory.validationError(
              validation.errorMessage!, 
              validation.localizedErrorKey
            ));
            return;
          }
          discountRates.add(double.parse(controller.text));
        } else {
          discountRates.add(0.0);
        }
      }

      // Validate profit margin
      final profitValidation = _validationService.validatePercentage(profitController.text);
      if (!profitValidation.isValid) {
        _errorHandlingService.handleError(ErrorFactory.validationError(
          profitValidation.errorMessage!, 
          profitValidation.localizedErrorKey
        ));
        return;
      }

      final profitMargin = double.parse(profitController.text);

      final request = PriceCalculationRequest(
        originalPrice: originalPrice,
        exchangeRate: exchangeRate,
        currency: _selectedCurrency,
        discountRates: discountRates,
        profitMargin: profitMargin,
      );

      _calculationResult = _priceCalculationService.calculatePrice(request);
      notifyListeners();
    } catch (e, stackTrace) {
      _errorHandlingService.handleError(ErrorFactory.calculationError(
        'Failed to calculate price: ${e.toString()}',
        e,
        stackTrace
      ));
    }
  }

  Future<void> togglePriceVisibility() async {
    if (_pinCode == null) return;

    if (!_showPrices) {
      // Show PIN dialog and validate
      _showPrices = true; // For now, simplified
    } else {
      _showPrices = false;
    }
    notifyListeners();
  }

  Future<void> savePreset() async {
    try {
      // Validate preset label
      final labelValidation = _validationService.validatePresetLabel(presetLabelController.text);
      if (!labelValidation.isValid) {
        _errorHandlingService.handleError(ErrorFactory.validationError(
          labelValidation.errorMessage!, 
          labelValidation.localizedErrorKey
        ));
        return;
      }

      final preset = DiscountPreset(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: presetLabelController.text,
        discounts: [
          double.tryParse(discount1Controller.text) ?? 0.0,
          double.tryParse(discount2Controller.text) ?? 0.0,
          double.tryParse(discount3Controller.text) ?? 0.0,
        ],
        profitMargin: double.tryParse(profitController.text) ?? 40.0,
      );

      await _presetRepository.saveDiscountPreset(preset);
      await _loadPresets();
      presetLabelController.clear();
    } catch (e, stackTrace) {
      _errorHandlingService.handleError(ErrorFactory.storageError(
        'Failed to save preset: ${e.toString()}',
        e,
        stackTrace
      ));
    }
  }

  Future<void> deletePreset() async {
    if (_selectedPreset == null) return;

    await _presetRepository.deleteDiscountPreset(_selectedPreset!.id);
    _selectedPreset = null;
    await _loadPresets();
  }

  Future<void> saveCalculationRecord() async {
    try {
      // Validate calculation result exists
      if (_calculationResult == null) {
        _errorHandlingService.handleError(ErrorFactory.validationError(
          'No calculation result available',
          'calculationRequired'
        ));
        return;
      }

      // Validate product name
      final nameValidation = _validationService.validateProductName(productNameController.text);
      if (!nameValidation.isValid) {
        _errorHandlingService.handleError(ErrorFactory.validationError(
          nameValidation.errorMessage!, 
          nameValidation.localizedErrorKey
        ));
        return;
      }

      final record = CalculationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: productNameController.text,
        originalPrice: double.tryParse(priceController.text) ?? 0.0,
        exchangeRate: _selectedCurrency == 'USD' 
            ? (_exchangeRates?.usdRate ?? 0.0)
            : (_exchangeRates?.eurRate ?? 0.0),
        discountRate: _calculationResult!.totalDiscountRate,
        finalPrice: _calculationResult!.finalPriceWithVat,
        createdAt: DateTime.now(),
        notes: notesController.text.isEmpty ? null : notesController.text,
      );

      await _recordRepository.saveCalculationRecord(record);
      productNameController.clear();
      notesController.clear();
    } catch (e, stackTrace) {
      _errorHandlingService.handleError(ErrorFactory.storageError(
        'Failed to save calculation record: ${e.toString()}',
        e,
        stackTrace
      ));
    }
  }
}
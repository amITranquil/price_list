import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'app_state_provider.dart';

// Comprehensive state management provider following SOLID principles
class PriceCalculatorProvider extends ChangeNotifier {
  // Services
  final ExchangeRateService _exchangeRateService = getIt<ExchangeRateService>();
  final PriceCalculationService _priceCalculationService = getIt<PriceCalculationService>();
  final AuthenticationService _authService = getIt<AuthenticationService>();
  final ValidationService _validationService = getIt<ValidationService>();
  final ErrorHandlingService _errorHandlingService = getIt<ErrorHandlingService>();
  final DiscountPresetRepository _presetRepository = getIt<DiscountPresetRepository>();
  final CalculationRecordRepository _recordRepository = getIt<CalculationRecordRepository>();

  // State providers
  final ExchangeRateStateProvider _exchangeRateState = ExchangeRateStateProvider();
  final DiscountPresetStateProvider _presetState = DiscountPresetStateProvider();
  final CalculationResultStateProvider _calculationState = CalculationResultStateProvider();
  final UIStateProvider _uiState = UIStateProvider();
  final AuthenticationStateProvider _authState = AuthenticationStateProvider();

  // Controllers
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discount1Controller = TextEditingController();
  final TextEditingController discount2Controller = TextEditingController();
  final TextEditingController discount3Controller = TextEditingController();
  final TextEditingController profitController = TextEditingController();
  final TextEditingController presetLabelController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Getters for state providers
  ExchangeRateStateProvider get exchangeRateState => _exchangeRateState;
  DiscountPresetStateProvider get presetState => _presetState;
  CalculationResultStateProvider get calculationState => _calculationState;
  UIStateProvider get uiState => _uiState;
  AuthenticationStateProvider get authState => _authState;

  // Convenience getters
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;

  PriceCalculatorProvider() {
    // Set up listeners to propagate state changes
    _exchangeRateState.addListener(() => notifyListeners());
    _presetState.addListener(() => notifyListeners());
    _calculationState.addListener(() => notifyListeners());
    _uiState.addListener(() => notifyListeners());
    _authState.addListener(() => notifyListeners());
  }

  @override
  void dispose() {
    // Dispose controllers
    priceController.dispose();
    discount1Controller.dispose();
    discount2Controller.dispose();
    discount3Controller.dispose();
    profitController.dispose();
    presetLabelController.dispose();
    productNameController.dispose();
    notesController.dispose();
    
    // Dispose state providers
    _exchangeRateState.dispose();
    _presetState.dispose();
    _calculationState.dispose();
    _uiState.dispose();
    _authState.dispose();
    
    super.dispose();
  }

  // Initialization
  Future<void> initialize() async {
    try {
      // Initialize authentication state
      final hasPinCode = await _authService.hasPinCode();
      _authState.setPinCodeExists(hasPinCode);
      
      // Load presets
      await _loadPresets();
      
      // Load exchange rates
      await fetchExchangeRates();
      
      // Set default values
      profitController.text = '40';
      
      _isInitialized = true;
      notifyListeners();
    } catch (e, stackTrace) {
      _errorHandlingService.handleError(ErrorFactory.unknownError(
        'Failed to initialize application: ${e.toString()}',
        e,
        stackTrace
      ));
    }
  }

  // Exchange rate operations
  Future<void> fetchExchangeRates({bool useDirectScraping = true}) async {
    _exchangeRateState.setLoading();

    try {
      final rates = await _exchangeRateService.fetchRates();
      _exchangeRateState.setSuccess(rates);
    } catch (e, stackTrace) {
      _exchangeRateState.setError('Failed to fetch exchange rates');
      _errorHandlingService.handleError(ErrorFactory.networkError(
        'Failed to fetch exchange rates: ${e.toString()}',
        e,
        stackTrace
      ));
    }
  }

  // Preset operations
  Future<void> _loadPresets() async {
    _presetState.setLoading();

    try {
      final presets = await _presetRepository.getDiscountPresets();
      _presetState.setSuccess(presets);
    } catch (e, stackTrace) {
      _presetState.setError('Failed to load presets');
      _errorHandlingService.handleError(ErrorFactory.storageError(
        'Failed to load presets: ${e.toString()}',
        e,
        stackTrace
      ));
    }
  }

  Future<void> savePreset(BuildContext context) async {
    try {
      // Validate preset label
      final labelValidation = _validationService.validatePresetLabel(presetLabelController.text, l10n: AppLocalizations.of(context)!);
      if (!labelValidation.isValid) {
        if (context.mounted) {
          _errorHandlingService.showErrorSnackBar(
            context,
            ErrorFactory.validationError(
              labelValidation.errorMessage!,
              labelValidation.localizedErrorKey
            )
          );
        }
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
      _presetState.addPreset(preset);
      presetLabelController.clear();
    } catch (e, stackTrace) {
      if (context.mounted) {
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.storageError(
            'Failed to save preset: ${e.toString()}',
            e,
            stackTrace
          )
        );
      }
    }
  }

  Future<void> deletePreset(BuildContext context) async {
    final selectedPreset = _presetState.selectedPreset;
    if (selectedPreset == null) return;

    try {
      await _presetRepository.deleteDiscountPreset(selectedPreset.id);
      _presetState.removePreset(selectedPreset.id);
    } catch (e, stackTrace) {
      if (context.mounted) {
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.storageError(
            'Failed to delete preset: ${e.toString()}',
            e,
            stackTrace
          )
        );
      }
    }
  }

  void selectPreset(DiscountPreset? preset) {
    _presetState.selectPreset(preset);
    if (preset != null) {
      discount1Controller.text = preset.discounts.isNotEmpty ? preset.discounts[0].toString() : '';
      discount2Controller.text = preset.discounts.length > 1 ? preset.discounts[1].toString() : '';
      discount3Controller.text = preset.discounts.length > 2 ? preset.discounts[2].toString() : '';
      profitController.text = preset.profitMargin.toString();
    }
  }

  // Calculation operations
  Future<void> calculatePrice(BuildContext context) async {
    _calculationState.setLoading();

    try {
      // Validate price input
      final priceValidation = _validationService.validatePrice(priceController.text, l10n: AppLocalizations.of(context)!);
      if (!priceValidation.isValid) {
        _calculationState.setError(priceValidation.errorMessage!);
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.validationError(
            priceValidation.errorMessage!,
            priceValidation.localizedErrorKey
          )
        );
        return;
      }

      // Validate exchange rates are available
      if (!_exchangeRateState.hasData) {
        _calculationState.setError('Exchange rates not available');
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.networkError('Exchange rates not available')
        );
        return;
      }

      final originalPrice = double.parse(priceController.text);
      final exchangeRate = _uiState.selectedCurrency == 'USD' 
          ? _exchangeRateState.exchangeRates!.usdRate 
          : _exchangeRateState.exchangeRates!.eurRate;
      
      if (exchangeRate == null) {
        _calculationState.setError('Selected currency rate not available');
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.networkError('Selected currency rate not available')
        );
        return;
      }

      // Validate discount percentages
      final discountRates = <double>[];
      for (final controller in [discount1Controller, discount2Controller, discount3Controller]) {
        if (controller.text.isNotEmpty) {
          final validation = _validationService.validatePercentage(controller.text, l10n: AppLocalizations.of(context)!);
          if (!validation.isValid) {
            _calculationState.setError(validation.errorMessage!);
            _errorHandlingService.showErrorSnackBar(
              context,
              ErrorFactory.validationError(
                validation.errorMessage!,
                validation.localizedErrorKey
              )
            );
            return;
          }
          discountRates.add(double.parse(controller.text));
        } else {
          discountRates.add(0.0);
        }
      }

      // Validate profit margin
      final profitValidation = _validationService.validatePercentage(profitController.text, l10n: AppLocalizations.of(context)!);
      if (!profitValidation.isValid) {
        _calculationState.setError(profitValidation.errorMessage!);
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.validationError(
            profitValidation.errorMessage!,
            profitValidation.localizedErrorKey
          )
        );
        return;
      }

      final profitMargin = double.parse(profitController.text);

      final request = PriceCalculationRequest(
        originalPrice: originalPrice,
        exchangeRate: exchangeRate,
        currency: _uiState.selectedCurrency,
        discountRates: discountRates,
        profitMargin: profitMargin,
      );

      final result = _priceCalculationService.calculatePrice(request);
      _calculationState.setSuccess(result);
    } catch (e, stackTrace) {
      _calculationState.setError('Calculation failed');
      _errorHandlingService.showErrorSnackBar(
        context,
        ErrorFactory.calculationError(
          'Failed to calculate price: ${e.toString()}',
          e,
          stackTrace
        )
      );
    }
  }

  // Record operations
  Future<void> saveCalculationRecord(BuildContext context) async {
    try {
      // Validate calculation result exists
      if (!_calculationState.hasResult) {
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.validationError(
            'No calculation result available',
            'calculationRequired'
          )
        );
        return;
      }

      // Validate product name
      final nameValidation = await _validationService.validateUniqueProductName(productNameController.text, l10n: AppLocalizations.of(context)!);
      if (!nameValidation.isValid) {
        if (context.mounted) {
          _errorHandlingService.showErrorSnackBar(
            context,
            ErrorFactory.validationError(
              nameValidation.errorMessage!,
              nameValidation.localizedErrorKey
            )
          );
        }
        return;
      }

      final record = CalculationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: productNameController.text,
        originalPrice: double.tryParse(priceController.text) ?? 0.0,
        exchangeRate: _uiState.selectedCurrency == 'USD' 
            ? (_exchangeRateState.exchangeRates?.usdRate ?? 0.0)
            : _uiState.selectedCurrency == 'EUR'
                ? (_exchangeRateState.exchangeRates?.eurRate ?? 0.0)
                : 1.0,
        discount1: double.tryParse(discount1Controller.text) ?? 0.0,
        discount2: double.tryParse(discount2Controller.text) ?? 0.0,
        discount3: double.tryParse(discount3Controller.text) ?? 0.0,
        profitMargin: double.tryParse(profitController.text) ?? 40.0,
        finalPrice: _calculationState.result!.finalPriceWithVat,
        createdAt: DateTime.now(),
        notes: notesController.text.isEmpty ? null : notesController.text,
        currency: _uiState.selectedCurrency,
      );

      await _recordRepository.saveCalculationRecord(record);
      productNameController.clear();
      notesController.clear();
    } catch (e, stackTrace) {
      if (context.mounted) {
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.storageError(
            'Failed to save calculation record: ${e.toString()}',
            e,
            stackTrace
          )
        );
      }
    }
  }

  // UI operations
  void selectCurrency(String currency) {
    _uiState.selectCurrency(currency);
  }

  void toggleAdvancedExpanded() {
    _uiState.toggleAdvancedExpanded();
  }

  Future<void> togglePriceVisibility() async {
    if (!_authState.hasPinCode) return;

    if (!_uiState.showPrices) {
      // For now, simplified authentication check
      // In real implementation, this would show PIN dialog
      _uiState.setPriceVisibility(true);
    } else {
      _uiState.setPriceVisibility(false);
    }
  }
}
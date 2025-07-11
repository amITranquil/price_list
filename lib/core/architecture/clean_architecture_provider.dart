// Clean Architecture Provider for Price Calculator
import 'package:flutter/material.dart';
import '../../services/price_calculation_service.dart';
import '../../services/exchange_rate_service.dart';
import '../../services/validation_service.dart';
import '../../services/error_handling_service.dart';
import '../../repositories/discount_preset_repository.dart';
import '../../repositories/calculation_record_repository.dart';
import '../../models/discount_preset.dart';
import '../../models/calculation_record.dart';
import '../../di/injection.dart';
import '../usecases/usecase.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../extensions/string_extensions.dart';

// Clean Architecture Provider with proper separation of concerns
class CleanArchitectureProvider extends ChangeNotifier {
  // Core services (infrastructure layer)
  final PriceCalculationService _priceCalculationService = getIt<PriceCalculationService>();
  final ExchangeRateService _exchangeRateService = getIt<ExchangeRateService>();
  final ValidationService _validationService = getIt<ValidationService>();
  final ErrorHandlingService _errorHandlingService = getIt<ErrorHandlingService>();
  final DiscountPresetRepository _presetRepository = getIt<DiscountPresetRepository>();
  final CalculationRecordRepository _recordRepository = getIt<CalculationRecordRepository>();

  // Domain entities (business logic state)
  PriceCalculationResult? _calculationResult;
  ExchangeRates? _exchangeRates;
  List<DiscountPreset> _presets = [];
  DiscountPreset? _selectedPreset;
  final List<CalculationRecord> _records = [];
  
  // Application state (UI concerns)
  String _selectedCurrency = 'USD';
  bool _isAdvancedExpanded = false;
  bool _showPrices = false;
  bool _isLoading = false;
  final bool _hasPinCode = false;
  String? _errorMessage;

  // Infrastructure (controllers for UI layer)
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discount1Controller = TextEditingController();
  final TextEditingController discount2Controller = TextEditingController();
  final TextEditingController discount3Controller = TextEditingController();
  final TextEditingController profitController = TextEditingController();
  final TextEditingController presetLabelController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Getters (presentation layer interface)
  PriceCalculationResult? get calculationResult => _calculationResult;
  ExchangeRates? get exchangeRates => _exchangeRates;
  List<DiscountPreset> get presets => _presets;
  DiscountPreset? get selectedPreset => _selectedPreset;
  List<CalculationRecord> get records => _records;
  String get selectedCurrency => _selectedCurrency;
  bool get isAdvancedExpanded => _isAdvancedExpanded;
  bool get showPrices => _showPrices;
  bool get isLoading => _isLoading;
  bool get hasPinCode => _hasPinCode;
  String? get errorMessage => _errorMessage;

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

  // Use Cases (Application Layer)
  Future<Result<PriceCalculationResult>> calculatePriceUseCase(BuildContext context) async {
    return LoggingUtils.timeFunctionAsync('Price Calculation Use Case', () async {
      try {
        Logger.business('Starting price calculation', data: {
          'originalPrice': priceController.text,
          'currency': _selectedCurrency,
          'discounts': [discount1Controller.text, discount2Controller.text, discount3Controller.text],
          'profitMargin': profitController.text,
        });

        // Domain layer validation
        final priceValidation = _validationService.validatePrice(priceController.text);
        if (!priceValidation.isValid) {
          Logger.validation('originalPrice', 'invalid', value: priceController.text);
          return Result.error(priceValidation.errorMessage!);
        }

        if (_exchangeRates == null) {
          logError('Exchange rates not available for calculation');
          return Result.error('Exchange rates not available');
        }

        final originalPrice = priceController.text.toDoubleOrDefault();
        final exchangeRate = _selectedCurrency == 'USD' 
            ? _exchangeRates!.usdRate 
            : _exchangeRates!.eurRate;
        
        if (exchangeRate == null) {
          logError('Selected currency rate not available: $_selectedCurrency');
          return Result.error('Selected currency rate not available');
        }

        // Validate discount percentages
        final discountRates = <double>[];
        for (int i = 0; i < 3; i++) {
          final controller = [discount1Controller, discount2Controller, discount3Controller][i];
          if (controller.text.isNotNullOrEmpty) {
            final validation = _validationService.validatePercentage(controller.text);
            if (!validation.isValid) {
              Logger.validation('discount${i + 1}', 'invalid', value: controller.text);
              return Result.error(validation.errorMessage!);
            }
            discountRates.add(controller.text.toDoubleOrDefault());
          } else {
            discountRates.add(0.0);
          }
        }

        // Validate profit margin
        final profitValidation = _validationService.validatePercentage(profitController.text);
        if (!profitValidation.isValid) {
          Logger.validation('profitMargin', 'invalid', value: profitController.text);
          return Result.error(profitValidation.errorMessage!);
        }

        final profitMargin = profitController.text.toDoubleOrDefault(AppConstants.defaultProfitMargin);

        // Domain layer business logic
        final request = PriceCalculationRequest(
          originalPrice: originalPrice,
          exchangeRate: exchangeRate,
          currency: _selectedCurrency,
          discountRates: discountRates,
          profitMargin: profitMargin,
        );

        final result = _priceCalculationService.calculatePrice(request);
        
        Logger.business('Price calculation completed successfully', data: {
          'finalPriceWithVat': result.finalPriceWithVat,
          'totalDiscountRate': result.totalDiscountRate,
          'salePriceWithProfit': result.salePriceWithProfit,
        });

        return Result.success(result);
      } catch (e, stackTrace) {
        logError('Price calculation failed', error: e, stackTrace: stackTrace);
        return Result.error('Failed to calculate price: ${e.toString()}');
      }
    });
  }

  Future<Result<ExchangeRates>> fetchExchangeRatesUseCase({bool useDirectScraping = true}) async {
    try {
      final rates = await _exchangeRateService.fetchRates(useDirectScraping: useDirectScraping);
      return Result.success(rates);
    } catch (e) {
      return Result.error('Failed to fetch exchange rates: ${e.toString()}');
    }
  }

  Future<Result<List<DiscountPreset>>> loadPresetsUseCase() async {
    try {
      final presets = await _presetRepository.getDiscountPresets();
      return Result.success(presets);
    } catch (e) {
      return Result.error('Failed to load presets: ${e.toString()}');
    }
  }

  Future<Result<void>> savePresetUseCase(BuildContext context) async {
    try {
      // Domain validation
      final labelValidation = _validationService.validatePresetLabel(presetLabelController.text);
      if (!labelValidation.isValid) {
        return Result.error(labelValidation.errorMessage!);
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
      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to save preset: ${e.toString()}');
    }
  }

  Future<Result<void>> saveCalculationRecordUseCase(BuildContext context) async {
    try {
      // Domain validation
      if (_calculationResult == null) {
        return Result.error('No calculation result available');
      }

      final nameValidation = _validationService.validateProductName(productNameController.text);
      if (!nameValidation.isValid) {
        return Result.error(nameValidation.errorMessage!);
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
      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to save calculation record: ${e.toString()}');
    }
  }

  // Presentation Layer Operations
  Future<void> calculatePrice(BuildContext context) async {
    _setLoading(true);
    _clearError();

    final result = await calculatePriceUseCase(context);
    
    if (result.isSuccess) {
      _calculationResult = result.data;
    } else {
      if (context.mounted) {
        _showError(context, result.error!);
      } else {
        _showErrorSafe(result.error!);
      }
    }
    
    _setLoading(false);
  }

  Future<void> fetchExchangeRates({bool useDirectScraping = true}) async {
    _setLoading(true);
    _clearError();

    final result = await fetchExchangeRatesUseCase(useDirectScraping: useDirectScraping);
    
    if (result.isSuccess) {
      _exchangeRates = result.data;
    } else {
      _errorHandlingService.handleError(ErrorFactory.networkError(result.error!));
    }
    
    _setLoading(false);
  }

  Future<void> loadPresets() async {
    _setLoading(true);
    _clearError();

    final result = await loadPresetsUseCase();
    
    if (result.isSuccess) {
      _presets = result.data!;
    } else {
      _errorHandlingService.handleError(ErrorFactory.storageError(result.error!));
    }
    
    _setLoading(false);
  }

  Future<void> savePreset(BuildContext context) async {
    _setLoading(true);
    _clearError();

    final result = await savePresetUseCase(context);
    
    if (result.isSuccess) {
      await loadPresets(); // Refresh presets
      presetLabelController.clear();
    } else {
      if (context.mounted) {
        _showError(context, result.error!);
      } else {
        _showErrorSafe(result.error!);
      }
    }
    
    _setLoading(false);
  }

  Future<void> deletePreset(BuildContext context) async {
    if (_selectedPreset == null) return;

    _setLoading(true);
    _clearError();

    try {
      await _presetRepository.deleteDiscountPreset(_selectedPreset!.id);
      _presets.removeWhere((preset) => preset.id == _selectedPreset!.id);
      _selectedPreset = null;
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to delete preset: ${e.toString()}');
      } else {
        _showErrorSafe('Failed to delete preset: ${e.toString()}');
      }
    }
    
    _setLoading(false);
  }

  Future<void> saveCalculationRecord(BuildContext context) async {
    _setLoading(true);
    _clearError();

    final result = await saveCalculationRecordUseCase(context);
    
    if (result.isSuccess) {
      productNameController.clear();
      notesController.clear();
    } else {
      if (context.mounted) {
        _showError(context, result.error!);
      } else {
        _showErrorSafe(result.error!);
      }
    }
    
    _setLoading(false);
  }

  // UI State Management
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

  void togglePriceVisibility() {
    _showPrices = !_showPrices;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    _errorMessage = message;
    if (context.mounted) {
      _errorHandlingService.showErrorSnackBar(
        context,
        ErrorFactory.validationError(message)
      );
    }
    notifyListeners();
  }

  void _showErrorSafe(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Initialization
  Future<void> initialize() async {
    logInfo('Initializing Clean Architecture Provider');
    
    await LoggingUtils.timeFunctionAsync('Provider Initialization', () async {
      await Future.wait([
        loadPresets(),
        fetchExchangeRates(),
      ]);
      
      profitController.text = AppConstants.defaultProfitMargin.toString();
      notifyListeners();
    });
    
    logInfo('Clean Architecture Provider initialized successfully');
  }
}
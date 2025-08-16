// Clean Architecture Provider for Price Calculator
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/price_calculation_service.dart';
import '../../services/exchange_rate_service.dart';
import '../../services/validation_service.dart';
import '../../services/error_handling_service.dart';
import '../../repositories/discount_preset_repository.dart';
import '../../repositories/calculation_record_repository.dart';
import '../../repositories/pin_repository.dart';
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
  bool _showPrices = false; // Kar marjı başlangıçta gizli
  bool _showProfitMargin = false; // Kar marjı görünürlüğü
  bool _isLoading = false;
  bool _hasPinCode = false;
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
  final TextEditingController usdRateController = TextEditingController();
  final TextEditingController eurRateController = TextEditingController();
  final TextEditingController tlRateController = TextEditingController();

  // Getters (presentation layer interface)
  PriceCalculationResult? get calculationResult => _calculationResult;
  ExchangeRates? get exchangeRates => _exchangeRates;
  List<DiscountPreset> get presets => _presets;
  DiscountPreset? get selectedPreset => _selectedPreset;
  List<CalculationRecord> get records => _records;
  String get selectedCurrency => _selectedCurrency;
  bool get isAdvancedExpanded => _isAdvancedExpanded;
  bool get showPrices => _showPrices;
  bool get showProfitMargin => _showProfitMargin;
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
        double? exchangeRate;
        
        // Get exchange rate based on selected currency (prefer manual input)
        if (_selectedCurrency == 'USD') {
          final manualRate = double.tryParse(usdRateController.text);
          exchangeRate = manualRate != null && manualRate > 0 ? manualRate : _exchangeRates!.usdRate;
        } else if (_selectedCurrency == 'EUR') {
          final manualRate = double.tryParse(eurRateController.text);
          exchangeRate = manualRate != null && manualRate > 0 ? manualRate : _exchangeRates!.eurRate;
        } else if (_selectedCurrency == 'TRY') {
          final manualRate = double.tryParse(tlRateController.text);
          exchangeRate = manualRate != null && manualRate > 0 ? manualRate : 1.0; // TL base currency
        }
        
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

  Future<Result<ExchangeRates>> fetchExchangeRatesUseCase() async {
    try {
      final rates = await _exchangeRateService.fetchRates();
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
      final labelValidation = _validationService.validatePresetLabel(presetLabelController.text, l10n: AppLocalizations.of(context)!);
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

      final nameValidation = await _validationService.validateUniqueProductName(productNameController.text, l10n: AppLocalizations.of(context)!);
      if (!nameValidation.isValid) {
        return Result.error(nameValidation.errorMessage!);
      }


      final record = CalculationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: productNameController.text,
        originalPrice: double.tryParse(priceController.text) ?? 0.0,
        exchangeRate: _selectedCurrency == 'USD' 
            ? (double.tryParse(usdRateController.text) ?? _exchangeRates?.usdRate ?? 0.0)
            : _selectedCurrency == 'EUR'
                ? (double.tryParse(eurRateController.text) ?? _exchangeRates?.eurRate ?? 0.0)
                : (double.tryParse(tlRateController.text) ?? 1.0),
        discount1: double.tryParse(discount1Controller.text) ?? 0.0,
        discount2: double.tryParse(discount2Controller.text) ?? 0.0,
        discount3: double.tryParse(discount3Controller.text) ?? 0.0,
        profitMargin: double.tryParse(profitController.text) ?? 40.0,
        finalPrice: _calculationResult!.finalPriceWithVat,
        createdAt: DateTime.now(),
        notes: notesController.text.isEmpty ? null : notesController.text,
        currency: _selectedCurrency,
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

  Future<void> fetchExchangeRates() async {
    _setLoading(true);
    _clearError();

    final result = await fetchExchangeRatesUseCase();
    
    if (result.isSuccess) {
      _exchangeRates = result.data;
      // Update manual rate controllers with fetched rates
      if (result.data!.usdRate != null) {
        usdRateController.text = result.data!.usdRate.toString();
      }
      if (result.data!.eurRate != null) {
        eurRateController.text = result.data!.eurRate.toString();
      }
      // TL always 1.00 (base currency)
      tlRateController.text = '1.00';
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

  Future<void> updatePreset(BuildContext context, DiscountPreset preset) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate inputs
      final labelValidation = _validationService.validatePresetLabel(presetLabelController.text, l10n: AppLocalizations.of(context)!);
      if (!labelValidation.isValid) {
        if (context.mounted) {
          _showError(context, labelValidation.errorMessage!);
        }
        _setLoading(false);
        return;
      }
      
      final updatedPreset = DiscountPreset(
        id: preset.id,
        label: presetLabelController.text.trim(),
        discounts: [
          discount1Controller.text.toDoubleOrDefault(),
          discount2Controller.text.toDoubleOrDefault(),
          discount3Controller.text.toDoubleOrDefault(),
        ],
        profitMargin: profitController.text.toDoubleOrDefault(AppConstants.defaultProfitMargin),
      );
      
      await _presetRepository.updateDiscountPreset(updatedPreset);
      
      // Update local list
      final index = _presets.indexWhere((p) => p.id == preset.id);
      if (index != -1) {
        _presets[index] = updatedPreset;
        _selectedPreset = updatedPreset;
      }
      
      presetLabelController.clear();
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.presetUpdatedSuccessfully ?? 'Preset başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to update preset: ${e.toString()}');
      } else {
        _showErrorSafe('Failed to update preset: ${e.toString()}');
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
        _checkPinCode(),
      ]);
      
      profitController.text = AppConstants.defaultProfitMargin.toString();
      // TL always 1.00 (base currency)
      tlRateController.text = '1.00';
      notifyListeners();
    });
    
    logInfo('Clean Architecture Provider initialized successfully');
  }

  // PIN kodu kontrol ve yönetimi
  
  Future<void> _checkPinCode() async {
    try {
      // PIN kodu kontrolü - hardcoded değer kaldırıldı
      final pinRepository = getIt<PinRepository>();
      _hasPinCode = await pinRepository.hasPinCode();
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to check PIN code');
    }
  }

  Future<void> setPinCode(String pinCode) async {
    try {
      final pinRepository = getIt<PinRepository>();
      await pinRepository.setPinCode(pinCode);
      _hasPinCode = true;
      notifyListeners();
      Logger.info('PIN code set successfully');
    } catch (e) {
      Logger.error('Failed to set PIN code');
    }
  }

  Future<bool> validatePinCode(String inputPin) async {
    try {
      final pinRepository = getIt<PinRepository>();
      return await pinRepository.verifyPin(inputPin);
    } catch (e) {
      Logger.error('Failed to validate PIN code');
      return false;
    }
  }

  Future<void> promptPinAndToggleVisibility(BuildContext context) async {
    if (!_hasPinCode) {
      // PIN kodu yoksa doğrudan göster
      _showPrices = !_showPrices;
      notifyListeners();
      return;
    }
    
    if (_showPrices) {
      // Zaten görünüyorsa gizle
      _showPrices = false;
      notifyListeners();
      return;
    }
    
    // PIN kodu iste
    final pinController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.enterPinCode ?? 'PIN Kodu Girin'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 8,
          autofocus: true,
          onSubmitted: (value) async {
            final isValid = await validatePinCode(value);
            if (context.mounted) {
              if (isValid) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)?.invalidPinCode ?? 'Hatalı PIN kodu'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)?.pinCode ?? 'PIN Kodu',
            hintText: AppLocalizations.of(context)?.pinCodeHint ?? '4-8 haneli PIN kodu',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'İptal'),
          ),
          TextButton(
            onPressed: () async {
              final isValid = await validatePinCode(pinController.text);
              if (context.mounted) {
                if (isValid) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)?.invalidPinCode ?? 'Hatalı PIN kodu'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)?.ok ?? 'Tamam'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      _showPrices = true;
      notifyListeners();
    }
  }

  void toggleProfitMarginVisibility() {
    _showProfitMargin = !_showProfitMargin;
    notifyListeners();
  }
}
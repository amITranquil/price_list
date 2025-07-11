import 'package:flutter/foundation.dart';
import '../services/exchange_rate_service.dart';
import '../models/discount_preset.dart';
import '../services/price_calculation_service.dart';

// Base state class for type-safe state management
abstract class AppState {
  const AppState();
}

// Loading state
class LoadingState extends AppState {
  const LoadingState();
}

// Error state
class ErrorState extends AppState {
  final String message;
  final String? localizedKey;
  
  const ErrorState(this.message, [this.localizedKey]);
}

// Success state
class SuccessState extends AppState {
  const SuccessState();
}

// Data state for specific data types
class DataState<T> extends AppState {
  final T data;
  
  const DataState(this.data);
}

// Exchange rate state provider
class ExchangeRateStateProvider extends ChangeNotifier {
  AppState _state = const LoadingState();
  ExchangeRates? _exchangeRates;
  
  AppState get state => _state;
  ExchangeRates? get exchangeRates => _exchangeRates;
  
  void setLoading() {
    _state = const LoadingState();
    notifyListeners();
  }
  
  void setError(String message, [String? localizedKey]) {
    _state = ErrorState(message, localizedKey);
    notifyListeners();
  }
  
  void setSuccess(ExchangeRates rates) {
    _exchangeRates = rates;
    _state = DataState(rates);
    notifyListeners();
  }
  
  bool get isLoading => _state is LoadingState;
  bool get hasError => _state is ErrorState;
  bool get hasData => _state is DataState<ExchangeRates>;
}

// Discount preset state provider
class DiscountPresetStateProvider extends ChangeNotifier {
  AppState _state = const LoadingState();
  List<DiscountPreset> _presets = [];
  DiscountPreset? _selectedPreset;
  
  AppState get state => _state;
  List<DiscountPreset> get presets => _presets;
  DiscountPreset? get selectedPreset => _selectedPreset;
  
  void setLoading() {
    _state = const LoadingState();
    notifyListeners();
  }
  
  void setError(String message, [String? localizedKey]) {
    _state = ErrorState(message, localizedKey);
    notifyListeners();
  }
  
  void setSuccess(List<DiscountPreset> presets) {
    _presets = presets;
    _state = DataState(presets);
    notifyListeners();
  }
  
  void selectPreset(DiscountPreset? preset) {
    _selectedPreset = preset;
    notifyListeners();
  }
  
  void addPreset(DiscountPreset preset) {
    _presets.add(preset);
    _state = DataState(_presets);
    notifyListeners();
  }
  
  void removePreset(String presetId) {
    _presets.removeWhere((preset) => preset.id == presetId);
    if (_selectedPreset?.id == presetId) {
      _selectedPreset = null;
    }
    _state = DataState(_presets);
    notifyListeners();
  }
  
  bool get isLoading => _state is LoadingState;
  bool get hasError => _state is ErrorState;
  bool get hasData => _state is DataState<List<DiscountPreset>>;
}

// Calculation result state provider
class CalculationResultStateProvider extends ChangeNotifier {
  AppState _state = const SuccessState();
  PriceCalculationResult? _result;
  
  AppState get state => _state;
  PriceCalculationResult? get result => _result;
  
  void setLoading() {
    _state = const LoadingState();
    notifyListeners();
  }
  
  void setError(String message, [String? localizedKey]) {
    _state = ErrorState(message, localizedKey);
    notifyListeners();
  }
  
  void setSuccess(PriceCalculationResult result) {
    _result = result;
    _state = DataState(result);
    notifyListeners();
  }
  
  void clearResult() {
    _result = null;
    _state = const SuccessState();
    notifyListeners();
  }
  
  bool get isLoading => _state is LoadingState;
  bool get hasError => _state is ErrorState;
  bool get hasData => _state is DataState<PriceCalculationResult>;
  bool get hasResult => _result != null;
}

// UI state provider for managing UI-specific state
class UIStateProvider extends ChangeNotifier {
  String _selectedCurrency = 'USD';
  bool _isAdvancedExpanded = false;
  bool _showPrices = false;
  
  String get selectedCurrency => _selectedCurrency;
  bool get isAdvancedExpanded => _isAdvancedExpanded;
  bool get showPrices => _showPrices;
  
  void selectCurrency(String currency) {
    _selectedCurrency = currency;
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
  
  void setPriceVisibility(bool visible) {
    _showPrices = visible;
    notifyListeners();
  }
}

// Authentication state provider
class AuthenticationStateProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _hasPinCode = false;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get hasPinCode => _hasPinCode;
  
  void setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }
  
  void setPinCodeExists(bool exists) {
    _hasPinCode = exists;
    notifyListeners();
  }
  
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
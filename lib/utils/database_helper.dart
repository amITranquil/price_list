import '../models/discount_preset.dart';
import '../models/calculation_record.dart';
import '../repositories/discount_preset_repository.dart';
import '../repositories/pin_repository.dart';
import '../repositories/language_repository.dart';
import '../repositories/calculation_record_repository.dart';
import '../services/database_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  late final DatabaseService _databaseService;
  late final DiscountPresetRepository _discountPresetRepository;
  late final PinRepository _pinRepository;
  late final LanguageRepository _languageRepository;
  late final CalculationRecordRepository _calculationRecordRepository;

  bool _initialized = false;

  Future<void> initDatabase() async {
    if (_initialized) return;
    
    _databaseService = HiveDatabaseService();
    await _databaseService.initDatabase();
    
    _discountPresetRepository = HiveDiscountPresetRepository(_databaseService);
    _pinRepository = HivePinRepository(_databaseService);
    _languageRepository = HiveLanguageRepository(_databaseService);
    _calculationRecordRepository = HiveCalculationRecordRepository(_databaseService);
    
    _initialized = true;
  }

  Future<String?> getPinCode() async {
    if (!_initialized) await initDatabase();
    return await _pinRepository.getPinCode();
  }

  Future<void> setPinCode(String pin) async {
    if (!_initialized) await initDatabase();
    await _pinRepository.setPinCode(pin);
  }

  Future<void> saveDiscountPreset(DiscountPreset preset) async {
    if (!_initialized) await initDatabase();
    await _discountPresetRepository.saveDiscountPreset(preset);
  }

  Future<List<DiscountPreset>> getDiscountPresets() async {
    if (!_initialized) await initDatabase();
    return await _discountPresetRepository.getDiscountPresets();
  }

  Future<void> deleteDiscountPreset(String id) async {
    if (!_initialized) await initDatabase();
    await _discountPresetRepository.deleteDiscountPreset(id);
  }

  Future<String?> getLanguageCode() async {
    if (!_initialized) await initDatabase();
    return await _languageRepository.getLanguageCode();
  }

  Future<void> setLanguageCode(String languageCode) async {
    if (!_initialized) await initDatabase();
    await _languageRepository.setLanguageCode(languageCode);
  }

  Future<void> saveCalculationRecord(CalculationRecord record) async {
    if (!_initialized) await initDatabase();
    await _calculationRecordRepository.saveCalculationRecord(record);
  }

  Future<List<CalculationRecord>> getCalculationRecords() async {
    if (!_initialized) await initDatabase();
    return await _calculationRecordRepository.getCalculationRecords();
  }

  Future<void> deleteCalculationRecord(String id) async {
    if (!_initialized) await initDatabase();
    await _calculationRecordRepository.deleteCalculationRecord(id);
  }

  Future<List<CalculationRecord>> searchCalculationRecords(String query) async {
    if (!_initialized) await initDatabase();
    return await _calculationRecordRepository.searchCalculationRecords(query);
  }
}

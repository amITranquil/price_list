import '../models/calculation_record.dart';
import '../services/database_service.dart';
import 'dart:convert';

abstract class CalculationRecordRepository {
  Future<void> saveCalculationRecord(CalculationRecord record);
  Future<List<CalculationRecord>> getCalculationRecords();
  Future<void> deleteCalculationRecord(String id);
  Future<void> updateCalculationRecord(CalculationRecord record);
  Future<List<CalculationRecord>> searchCalculationRecords(String query);
  Future<bool> productNameExists(String productName);
}

class HiveCalculationRecordRepository implements CalculationRecordRepository {
  final DatabaseService _databaseService;
  static const String _boxName = 'calculation_records';

  HiveCalculationRecordRepository(this._databaseService);

  @override
  Future<void> saveCalculationRecord(CalculationRecord record) async {
    final box = await _databaseService.getBox(_boxName);
    final recordJson = jsonEncode({
      'id': record.id,
      'productName': record.productName,
      'originalPrice': record.originalPrice,
      'exchangeRate': record.exchangeRate,
      'discountRate': record.discountRate, // backward compatibility
      'discount1': record.discount1,
      'discount2': record.discount2,
      'discount3': record.discount3,
      'profitMargin': record.profitMargin,
      'finalPrice': record.finalPrice,
      'createdAt': record.createdAt.toIso8601String(),
      'notes': record.notes,
      'currency': record.currency,
    });
    await box.put(record.id, recordJson);
  }

  @override
  Future<List<CalculationRecord>> getCalculationRecords() async {
    final box = await _databaseService.getBox(_boxName);
    final records = <CalculationRecord>[];
    
    for (final key in box.keys) {
      final recordJson = box.get(key);
      if (recordJson != null) {
        try {
          final data = jsonDecode(recordJson);
          final record = CalculationRecord(
            id: data['id'],
            productName: data['productName'],
            originalPrice: data['originalPrice'].toDouble(),
            exchangeRate: data['exchangeRate'].toDouble(),
            discount1: data['discount1']?.toDouble() ?? data['discountRate']?.toDouble() ?? 0.0,
            discount2: data['discount2']?.toDouble() ?? 0.0,
            discount3: data['discount3']?.toDouble() ?? 0.0,
            profitMargin: data['profitMargin']?.toDouble() ?? 40.0,
            finalPrice: data['finalPrice'].toDouble(),
            createdAt: DateTime.parse(data['createdAt']),
            notes: data['notes'],
            currency: data['currency'] ?? 'USD',
          );
          records.add(record);
        } catch (e) {
          // Hatalı kayıt varsa atla
          continue;
        }
      }
    }
    
    // Tarihe göre tersten sırala (en yeni önce)
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  @override
  Future<void> deleteCalculationRecord(String id) async {
    final box = await _databaseService.getBox(_boxName);
    await box.delete(id);
  }

  @override
  Future<void> updateCalculationRecord(CalculationRecord record) async {
    // Update is same as save for this simple implementation
    await saveCalculationRecord(record);
  }

  @override
  Future<List<CalculationRecord>> searchCalculationRecords(String query) async {
    final allRecords = await getCalculationRecords();
    
    if (query.isEmpty) {
      return allRecords;
    }
    
    final lowerQuery = query.toLowerCase();
    return allRecords.where((record) {
      return record.productName.toLowerCase().contains(lowerQuery) ||
             (record.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<bool> productNameExists(String productName) async {
    final allRecords = await getCalculationRecords();
    return allRecords.any((record) => 
      record.productName.toLowerCase() == productName.toLowerCase());
  }
}
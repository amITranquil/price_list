import '../models/calculation_record.dart';
import '../services/database_service.dart';
import 'dart:convert';

abstract class CalculationRecordRepository {
  Future<void> saveCalculationRecord(CalculationRecord record);
  Future<List<CalculationRecord>> getCalculationRecords();
  Future<void> deleteCalculationRecord(String id);
  Future<List<CalculationRecord>> searchCalculationRecords(String query);
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
      'discountRate': record.discountRate,
      'finalPrice': record.finalPrice,
      'createdAt': record.createdAt.toIso8601String(),
      'notes': record.notes,
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
            discountRate: data['discountRate'].toDouble(),
            finalPrice: data['finalPrice'].toDouble(),
            createdAt: DateTime.parse(data['createdAt']),
            notes: data['notes'],
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
}
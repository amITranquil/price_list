import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/calculation_record.dart';
import '../models/discount_preset.dart';
import '../repositories/calculation_record_repository.dart';
import '../repositories/discount_preset_repository.dart';
import '../core/utils/logger.dart';
import 'platform_file_service.dart';

class ImportExportService {
  final CalculationRecordRepository _calculationRecordRepository;
  final DiscountPresetRepository _discountPresetRepository;
  final PlatformFileService _platformFileService;

  ImportExportService(
    this._calculationRecordRepository,
    this._discountPresetRepository,
  ) : _platformFileService = kIsWeb ? 
        throw UnsupportedError('Web platform not supported') : 
        PlatformFileServiceFactory.create();

  Future<String> exportData({
    bool includeCalculationRecords = true,
    bool includeDiscountPresets = true,
  }) async {
    final exportData = <String, dynamic>{};
    
    if (includeCalculationRecords) {
      final records = await _calculationRecordRepository.getCalculationRecords();
      exportData['calculation_records'] = records.map((record) => record.toJson()).toList();
    }
    
    if (includeDiscountPresets) {
      final presets = await _discountPresetRepository.getDiscountPresets();
      exportData['discount_presets'] = presets.map((preset) => preset.toJson()).toList();
    }
    
    exportData['export_version'] = '2.5.0';
    exportData['export_date'] = DateTime.now().toIso8601String();
    
    return jsonEncode(exportData);
  }

  Future<String> saveExportToFile({
    bool includeCalculationRecords = true,
    bool includeDiscountPresets = true,
  }) async {
    final exportJson = await exportData(
      includeCalculationRecords: includeCalculationRecords,
      includeDiscountPresets: includeDiscountPresets,
    );
    
    final fileName = 'price_list_export_${DateTime.now().millisecondsSinceEpoch}.json';
    
    // Platform-specific file dialog kullan
    final savedPath = await _platformFileService.saveFileWithDialog(exportJson, fileName);
    
    if (savedPath != null) {
      return savedPath;
    } else {
      throw ImportExportException('Dosya kaydedilemedi - kullanıcı iptal etti');
    }
  }

  Future<bool> importFromFile() async {
    try {
      // Platform-specific file picker kullan
      final jsonContent = await _platformFileService.pickFileForImport();
      
      if (jsonContent != null) {
        return await importFromJson(jsonContent);
      }
      return false;
    } catch (e) {
      throw ImportExportException('Dosya seçme hatası: ${e.toString()}');
    }
  }

  Future<bool> importFromJson(String jsonString) async {
    try {
      Logger.info('JSON import başlatılıyor...');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      int recordCount = 0;
      int presetCount = 0;
      
      if (data['calculation_records'] != null) {
        final recordsList = data['calculation_records'] as List;
        Logger.info('${recordsList.length} hesap kaydı bulundu');
        
        for (final recordData in recordsList) {
          try {
            final record = CalculationRecord.fromJson(recordData);
            await _calculationRecordRepository.saveCalculationRecord(record);
            recordCount++;
            Logger.info('Hesap kaydı kaydedildi: ${record.productName}');
          } catch (e) {
            Logger.error('Hesap kaydı işlenirken hata: $e - Data: $recordData');
            // Continue with next record
          }
        }
      }
      
      if (data['discount_presets'] != null) {
        final presetsList = data['discount_presets'] as List;
        Logger.info('${presetsList.length} indirim preset\'i bulundu');
        
        for (final presetData in presetsList) {
          try {
            final preset = DiscountPreset.fromJson(presetData);
            await _discountPresetRepository.saveDiscountPreset(preset);
            presetCount++;
            Logger.info('İndirim preset\'i kaydedildi: ${preset.label}');
          } catch (e) {
            Logger.error('İndirim preset\'i işlenirken hata: $e');
            // Continue with next preset
          }
        }
      }
      
      Logger.info('Import tamamlandı: $recordCount kayıt, $presetCount preset');
      return recordCount > 0 || presetCount > 0;
    } catch (e) {
      Logger.error('JSON parse hatası: $e');
      throw ImportExportException('İçe aktarma hatası: ${e.toString()}');
    }
  }

  Future<ImportExportStats> getExportStats() async {
    final records = await _calculationRecordRepository.getCalculationRecords();
    final presets = await _discountPresetRepository.getDiscountPresets();
    
    return ImportExportStats(
      calculationRecordCount: records.length,
      discountPresetCount: presets.length,
    );
  }

  // Debug için basit test metodu
  Future<void> testImportExport() async {
    Logger.info('Import/Export test başlatılıyor...');
    
    // Önce mevcut kayıtları kontrol et
    final existingRecords = await _calculationRecordRepository.getCalculationRecords();
    Logger.info('Mevcut kayıt sayısı: ${existingRecords.length}');
    
    if (existingRecords.isNotEmpty) {
      // Export yap
      final exported = await exportData(includeCalculationRecords: true, includeDiscountPresets: false);
      Logger.info('Export tamamlandı: ${exported.length} karakter');
      
      // Hemen import yap
      final importResult = await importFromJson(exported);
      Logger.info('Import sonucu: $importResult');
      
      // Tekrar kontrol et
      final afterImport = await _calculationRecordRepository.getCalculationRecords();
      Logger.info('Import sonrası kayıt sayısı: ${afterImport.length}');
    }
  }

  Future<bool> clearAllData() async {
    try {
      final records = await _calculationRecordRepository.getCalculationRecords();
      for (final record in records) {
        await _calculationRecordRepository.deleteCalculationRecord(record.id);
      }
      
      final presets = await _discountPresetRepository.getDiscountPresets();
      for (final preset in presets) {
        await _discountPresetRepository.deleteDiscountPreset(preset.id);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

class ImportExportStats {
  final int calculationRecordCount;
  final int discountPresetCount;

  ImportExportStats({
    required this.calculationRecordCount,
    required this.discountPresetCount,
  });
}

class ImportExportException implements Exception {
  final String message;
  ImportExportException(this.message);

  @override
  String toString() => 'ImportExportException: $message';
}
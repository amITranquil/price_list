import 'package:flutter/foundation.dart';
import '../models/discount_preset.dart';
import '../services/database_service.dart';

abstract class DiscountPresetRepository {
  Future<List<DiscountPreset>> getDiscountPresets();
  Future<void> saveDiscountPreset(DiscountPreset preset);
  Future<void> deleteDiscountPreset(String id);
  Future<DiscountPreset?> getDiscountPresetById(String id);
}

class HiveDiscountPresetRepository implements DiscountPresetRepository {
  static const String _boxName = 'discount_presets';
  final DatabaseService _databaseService;

  HiveDiscountPresetRepository(this._databaseService);

  @override
  Future<List<DiscountPreset>> getDiscountPresets() async {
    try {
      final box = await _databaseService.getBox(_boxName);
      final presets = <DiscountPreset>[];
      
      for (final key in box.keys) {
        final dataString = box.get(key);
        if (dataString != null) {
          try {
            presets.add(DiscountPreset.fromStorageString(dataString));
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing preset with key $key: $e');
            }
          }
        }
      }
      
      return presets;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting discount presets: $e');
      }
      return [];
    }
  }

  @override
  Future<void> saveDiscountPreset(DiscountPreset preset) async {
    try {
      final box = await _databaseService.getBox(_boxName);
      await box.put(preset.id, preset.toStorageString());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving discount preset: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteDiscountPreset(String id) async {
    try {
      final box = await _databaseService.getBox(_boxName);
      await box.delete(id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting discount preset: $e');
      }
      rethrow;
    }
  }

  @override
  Future<DiscountPreset?> getDiscountPresetById(String id) async {
    try {
      final box = await _databaseService.getBox(_boxName);
      final dataString = box.get(id);
      
      if (dataString != null) {
        return DiscountPreset.fromStorageString(dataString);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting discount preset by id: $e');
      }
      return null;
    }
  }
}
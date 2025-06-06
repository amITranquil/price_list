import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

abstract class PinRepository {
  Future<String?> getPinCode();
  Future<void> setPinCode(String pin);
  Future<bool> hasPinCode();
  Future<bool> verifyPin(String pin);
}

class HivePinRepository implements PinRepository {
  static const String _boxName = 'settings';
  static const String _pinKey = 'pin';
  final DatabaseService _databaseService;

  HivePinRepository(this._databaseService);

  @override
  Future<String?> getPinCode() async {
    try {
      final box = await _databaseService.getBox(_boxName);
      return box.get(_pinKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting PIN code: $e');
      }
      return null;
    }
  }

  @override
  Future<void> setPinCode(String pin) async {
    try {
      final box = await _databaseService.getBox(_boxName);
      await box.put(_pinKey, pin);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting PIN code: $e');
      }
      rethrow;
    }
  }

  @override
  Future<bool> hasPinCode() async {
    try {
      final pin = await getPinCode();
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if PIN exists: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await getPinCode();
      return storedPin == pin;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying PIN: $e');
      }
      return false;
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

abstract class LanguageRepository {
  Future<String?> getLanguageCode();
  Future<void> setLanguageCode(String languageCode);
  Future<Locale> getLocale();
  Future<void> setLocale(Locale locale);
}

class HiveLanguageRepository implements LanguageRepository {
  static const String _boxName = 'settings';
  static const String _languageKey = 'language_code';
  static const String _defaultLanguageCode = 'tr';
  final DatabaseService _databaseService;

  HiveLanguageRepository(this._databaseService);

  @override
  Future<String?> getLanguageCode() async {
    try {
      final box = await _databaseService.getBox(_boxName);
      return box.get(_languageKey) ?? _defaultLanguageCode;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting language code: $e');
      }
      return _defaultLanguageCode;
    }
  }

  @override
  Future<void> setLanguageCode(String languageCode) async {
    try {
      final box = await _databaseService.getBox(_boxName);
      await box.put(_languageKey, languageCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting language code: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Locale> getLocale() async {
    try {
      final languageCode = await getLanguageCode();
      return Locale(languageCode ?? _defaultLanguageCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting locale: $e');
      }
      return const Locale(_defaultLanguageCode);
    }
  }

  @override
  Future<void> setLocale(Locale locale) async {
    try {
      await setLanguageCode(locale.languageCode);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting locale: $e');
      }
      rethrow;
    }
  }
}
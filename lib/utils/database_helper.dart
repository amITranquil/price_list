import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Box<String>? _box;

  Future<void> initDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    if (kDebugMode) {
      print(appDir);
    }
    Hive.init(appDir.path); // Hive'ı başlat
    _box =
        await Hive.openBox<String>('settings'); // 'settings' isimli kutuyu aç
  }

  Future<String?> getPinCode() async {
    if (_box == null) await initDatabase(); // Eğer kutu null ise başlat
    return _box?.get('pin'); // 'pin' anahtarını getir
  }

  Future<void> setPinCode(String pin) async {
    if (_box == null) await initDatabase(); // Eğer kutu null ise başlat
    await _box?.put('pin', pin); // 'pin' anahtarına değeri koy
  }
}

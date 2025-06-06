import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

abstract class DatabaseService {
  Future<void> initDatabase();
  Future<Box<String>> getBox(String boxName);
}

class HiveDatabaseService implements DatabaseService {
  static final HiveDatabaseService _instance = HiveDatabaseService._internal();
  factory HiveDatabaseService() => _instance;
  HiveDatabaseService._internal();

  final Map<String, Box<String>> _boxes = {};

  @override
  Future<void> initDatabase() async {
    if (!Hive.isAdapterRegistered(0)) {
      final appDir = await getApplicationDocumentsDirectory();
      if (kDebugMode) {
        print('Hive database path: ${appDir.path}');
      }
      Hive.init(appDir.path);
    }
  }

  @override
  Future<Box<String>> getBox(String boxName) async {
    if (_boxes[boxName] == null || !_boxes[boxName]!.isOpen) {
      await initDatabase();
      _boxes[boxName] = await Hive.openBox<String>(boxName);
    }
    return _boxes[boxName]!;
  }

  Future<void> closeAllBoxes() async {
    for (final box in _boxes.values) {
      if (box.isOpen) {
        await box.close();
      }
    }
    _boxes.clear();
  }
}
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

abstract class PlatformFileService {
  Future<String?> saveFileWithDialog(String content, String fileName);
  Future<String?> pickFileForImport();
  Future<String> getDefaultExportPath();
}

class NativePlatformFileService implements PlatformFileService {
  @override
  Future<String?> saveFileWithDialog(String content, String fileName) async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Web platform not supported');
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Dosyayı Kaydet',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(content);
        return outputFile;
      }
      return null;
    } catch (e) {
      throw PlatformFileException('Dosya kaydetme hatası: ${e.toString()}');
    }
  }

  @override
  Future<String?> pickFileForImport() async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Web platform not supported');
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'İçe Aktarılacak Dosyayı Seçin',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      throw PlatformFileException('Dosya okuma hatası: ${e.toString()}');
    }
  }

  @override
  Future<String> getDefaultExportPath() async {
    try {
      if (Platform.isAndroid) {
        // Android için Documents dizini
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          return path.join(directory.path, 'Documents');
        }
        // Fallback
        final appDir = await getApplicationDocumentsDirectory();
        return appDir.path;
      } else if (Platform.isIOS) {
        // iOS için Documents dizini
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      } else if (Platform.isWindows) {
        // Windows için Documents dizini
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      } else if (Platform.isMacOS) {
        // macOS için Documents dizini
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      } else if (Platform.isLinux) {
        // Linux için home/Documents dizini
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      } else {
        // Diğer platformlar için fallback
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      }
    } catch (e) {
      // En son fallback
      final directory = await getTemporaryDirectory();
      return directory.path;
    }
  }

}

class MockPlatformFileService implements PlatformFileService {
  @override
  Future<String?> saveFileWithDialog(String content, String fileName) async {
    // Test için mock implementasyon
    final directory = await getTemporaryDirectory();
    final file = File(path.join(directory.path, fileName));
    await file.writeAsString(content);
    return file.path;
  }

  @override
  Future<String?> pickFileForImport() async {
    // Test için mock implementasyon
    return '{"test": "data"}';
  }

  @override
  Future<String> getDefaultExportPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
}

class PlatformFileException implements Exception {
  final String message;
  PlatformFileException(this.message);

  @override
  String toString() => 'PlatformFileException: $message';
}

// Platform-specific factory
class PlatformFileServiceFactory {
  static PlatformFileService create() {
    if (kIsWeb) {
      throw UnsupportedError('Web platform should use different implementation');
    }
    
    // Test ortamında mock service kullan
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
      return MockPlatformFileService();
    }
    
    return NativePlatformFileService();
  }
  
  static bool get isWebPlatform => kIsWeb;
  static bool get isDesktopPlatform => 
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isMobilePlatform => 
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
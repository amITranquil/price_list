import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:price_list/screens/price_calculator_screen.dart';
import 'package:price_list/screens/create_pin_page.dart';
import 'package:price_list/utils/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanını başlat
  await DatabaseHelper().initDatabase();

  if (kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    runApp(const MyApp());
  } else if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiyat Hesaplayıcı',
      theme: ThemeData.dark(),
      home: FutureBuilder<bool>(
        future: _checkPinStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return const PriceCalculatorScreen();
          } else {
            return const CreatePinPage();
          }
        },
      ),
    );
  }

  Future<bool> _checkPinStatus() async {
    final storedPin = await DatabaseHelper().getPinCode();
    return storedPin != null;
  }
}

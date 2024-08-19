import 'package:flutter/material.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Window manager'ı başlat
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiyat Hesaplayıcı',
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: const PriceCalculatorScreen(),
    );
  }
}

class PriceCalculatorScreen extends StatefulWidget {
  const PriceCalculatorScreen({super.key});

  @override
  PriceCalculatorScreenState createState() => PriceCalculatorScreenState();
}

class PriceCalculatorScreenState extends State<PriceCalculatorScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController1 = TextEditingController();
  final TextEditingController _discountController2 = TextEditingController();
  final TextEditingController _profitMarginController = TextEditingController();
  final TextEditingController _usdExchangeRateController =
      TextEditingController();
  final TextEditingController _eurExchangeRateController =
      TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String _finalPrice = '';
  String _priceBought = '';
  String _kdvPrice = '';
  String _usdRate = 'Yükleniyor...';
  String _eurRate = 'Yükleniyor...';

  bool _isPriceBoughtVisible = false;
  final String _pinCode = '9598'; // PIN kodu

  @override
  void initState() {
    super.initState();
    _fetchRates();

    _discountController1.text = '45';
    _discountController2.text = '0';
    _profitMarginController.text = '30';
  }

  Future<void> _fetchRates() async {
    const url = 'https://urlateknik.com/kresmak/isbank.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // HTML içeriğini parse et
        Document document = parse(response.body);

        // USD ve EUR satış kurlarını çıkar
        String usdRate = '';
        String eurRate = '';

        // USD ve EUR kurlarını bulmak için doğru elementleri seç
        var textContent = document.body?.text;
        if (textContent != null) {
          var usdIndex = textContent.indexOf('USD Satış Kuru:');
          if (usdIndex != -1) {
            var usdStart = textContent.substring(usdIndex);
            var usdEndIndex = usdStart.indexOf('EUR Satış Kuru:');
            if (usdEndIndex != -1) {
              usdRate =
                  usdStart.substring(0, usdEndIndex).split(': ')[1].trim();
            } else {
              usdRate = usdStart.split(': ')[1].split('<br>')[0].trim();
            }
          }

          var eurIndex = textContent.indexOf('EUR Satış Kuru:');
          if (eurIndex != -1) {
            var eurStart = textContent.substring(eurIndex);
            eurRate = eurStart.split(': ')[1].trim();
          }
        }

        setState(() {
          _usdRate = usdRate.isNotEmpty ? usdRate : 'Veri alınamadı';
          _eurRate = eurRate.isNotEmpty ? eurRate : 'Veri alınamadı';

          _usdExchangeRateController.text = _usdRate.replaceAll(',', '.');
          _eurExchangeRateController.text = _eurRate.replaceAll(',', '.');
        });
      } else {
        setState(() {
          _usdRate = 'Veri alınamadı';
          _eurRate = 'Veri alınamadı';
        });
      }
    } catch (e) {
      setState(() {
        _usdRate = 'Veri alınamadı';
        _eurRate = 'Veri alınamadı';
      });
    }
  }

  void _calculateFinalPrice(double exchangeRate) {
    final double originalPrice = double.parse(_priceController.text);
    final double discount1 = double.parse(_discountController1.text) / 100;
    final double discount2 = double.parse(_discountController2.text) / 100;
    final double profitMargin =
        double.parse(_profitMarginController.text) / 100;

    final double discountedPrice1 = originalPrice * (1 - discount1);
    final double discountedPrice2 = discountedPrice1 * (1 - discount2);
    final double priceBought = discountedPrice2 * exchangeRate;
    final double priceWithProfit = discountedPrice2 * (1 + profitMargin);
    final double finalPrice = priceWithProfit * exchangeRate;
    final double kdvPrice = finalPrice + ((finalPrice * 20) / 100);

    setState(() {
      _priceBought = NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
          .format(priceBought);
      _finalPrice = NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
          .format(finalPrice);
      _kdvPrice =
          NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(kdvPrice);
    });
  }

  void _togglePriceBoughtVisibility() {
    if (_pinController.text == _pinCode) {
      setState(() {
        _isPriceBoughtVisible = !_isPriceBoughtVisible;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yanlış PIN!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KRESMAK LİSTEDEN FİYAT HESAPLA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Orijinal Fiyat (USD veya EUR)',
              ),
            ),
            TextField(
              controller: _discountController1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'İndirim1 (%)',
              ),
            ),
            TextField(
              controller: _discountController2,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'İndirim2 (%)',
              ),
            ),
            TextField(
              controller: _profitMarginController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kar Marjı (%)',
              ),
            ),
            TextField(
              controller: _usdExchangeRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'USD Döviz Kuru (Banka Satış Fiyatı)',
              ),
            ),
            TextField(
              controller: _eurExchangeRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'EUR Döviz Kuru (Banka Satış Fiyatı)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final double usdExchangeRate =
                    double.parse(_usdExchangeRateController.text);
                _calculateFinalPrice(usdExchangeRate);
              },
              child: const Text('USD ile Hesapla'),
            ), const SizedBox(height: 7),
            ElevatedButton(
              onPressed: () {
                final double eurExchangeRate =
                    double.parse(_eurExchangeRateController.text);
                _calculateFinalPrice(eurExchangeRate);
              },
              child: const Text('EUR ile Hesapla'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PIN Kodu',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _togglePriceBoughtVisibility,
              child: Text(
                _isPriceBoughtVisible
                    ? 'Alış Fiyatını Gizle'
                    : 'Alış Fiyatını Göster',
              ),
            ), const SizedBox(height: 7),
            ElevatedButton(onPressed: _fetchRates, child: const Text('Kurları Güncelle')),
            const SizedBox(height: 20),
            if (_isPriceBoughtVisible && _priceBought.isNotEmpty)
              Text(
                'Alış Fiyatı: $_priceBought',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            if (_finalPrice.isNotEmpty)
              Text(
                'Son Fiyat: $_finalPrice',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            if (_kdvPrice.isNotEmpty)
              Text(
                'KDV : $_kdvPrice',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiyat Hesaplayıcı',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  String _finalPrice = '';
  String _usdRate = 'Yükleniyor...';
  String _eurRate = 'Yükleniyor...';

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
   //final url ='https://cors-anywhere.herokuapp.com/https://www.isbank.com.tr/doviz-kurlari';
   final url ='https://www.isbank.com.tr/doviz-kurlari';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final rowUsd = document.querySelector(
          'tr#ctl00_ctl18_g_1e38731d_affa_44fc_85c6_ae10fda79f73_ctl00_FxRatesRepeater_ctl00_fxItem');
      if (rowUsd != null) {

        final columns = rowUsd.querySelectorAll('td');
        if (columns.length >= 3) {
          setState(() {
            _usdRate = columns[2].text.trim();
            _usdExchangeRateController.text = _usdRate.replaceAll(',', '.');
          });
        }
      }

      final rowEur = document.querySelector(
          'tr#ctl00_ctl18_g_1e38731d_affa_44fc_85c6_ae10fda79f73_ctl00_FxRatesRepeater_ctl01_fxItem');
      if (rowEur != null) {
        final columns = rowEur.querySelectorAll('td');
        if (columns.length >= 3) {
          setState(() {
            _eurRate = columns[2].text.trim();
            _eurExchangeRateController.text = _eurRate.replaceAll(',', '.');
          });
        }
      }
    } else {
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
    final double priceWithProfit = discountedPrice2 * (1 + profitMargin);
    final double finalPrice = priceWithProfit * exchangeRate;

    setState(() {
      _finalPrice = NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
          .format(finalPrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiyat Hesaplayıcı'),
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
            ),
            ElevatedButton(
              onPressed: () {
                final double eurExchangeRate =
                    double.parse(_eurExchangeRateController.text);
                _calculateFinalPrice(eurExchangeRate);
              },
              child: const Text('EUR ile Hesapla'),
            ),
            const SizedBox(height: 20),
            if (_finalPrice.isNotEmpty)
              Text(
                'Son Fiyat: $_finalPrice',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

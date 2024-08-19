import 'package:flutter/material.dart';
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
  _PriceCalculatorScreenState createState() => _PriceCalculatorScreenState();
}

class _PriceCalculatorScreenState extends State<PriceCalculatorScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _profitMarginController = TextEditingController();
  final TextEditingController _usdExchangeRateController = TextEditingController();
  final TextEditingController _eurExchangeRateController = TextEditingController();
  String _finalPrice = '';

  void _calculateFinalPrice(double exchangeRate) {
    final double originalPrice = double.parse(_priceController.text);
    final double discount = double.parse(_discountController.text) / 100;
    final double profitMargin = double.parse(_profitMarginController.text) / 100;

    final double discountedPrice = originalPrice * (1 - discount);
    final double priceWithProfit = discountedPrice * (1 + profitMargin);
    final double finalPrice = priceWithProfit * exchangeRate;

    setState(() {
      _finalPrice = NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(finalPrice);
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
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'İndirim (%)',
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
                final double usdExchangeRate = double.parse(_usdExchangeRateController.text);
                _calculateFinalPrice(usdExchangeRate);
              },
              child: const Text('USD ile Hesapla'),
            ),
            ElevatedButton(
              onPressed: () {
                final double eurExchangeRate = double.parse(_eurExchangeRateController.text);
                _calculateFinalPrice(eurExchangeRate);
              },
              child: const Text('EUR ile Hesapla'),
            ),
            const SizedBox(height: 20),
            if (_finalPrice.isNotEmpty)
              Text(
                'Son Fiyat: $_finalPrice',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

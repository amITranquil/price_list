import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'dart:convert';

class ExchangeRates {
  final double? usdRate;
  final double? eurRate;
  final String dataSource;
  final DateTime fetchTime;

  ExchangeRates({
    required this.usdRate,
    required this.eurRate,
    required this.dataSource,
    required this.fetchTime,
  });
}

abstract class ExchangeRateService {
  Future<ExchangeRates> fetchRates({bool useDirectScraping = true});
}

class WebExchangeRateService implements ExchangeRateService {
  @override
  Future<ExchangeRates> fetchRates({bool useDirectScraping = true}) async {
    if (useDirectScraping) {
      return await _fetchRatesDirectly();
    } else {
      return await _fetchRatesFromPHP();
    }
  }

  Future<ExchangeRates> _fetchRatesDirectly() async {
    double? usdRate;
    double? eurRate;
    
    try {
      final response = await http.get(
        Uri.parse('https://www.isbank.com.tr/doviz-kurlari'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'tr-TR,tr;q=0.9,en;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );

      if (response.statusCode == 200) {
        final document = parse(response.body);
        
        // USD için arama
        final usdRows = document.querySelectorAll('tr');
        for (final row in usdRows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 3) {
            final currency = cells[0].text.trim();
            if (currency.contains('USD') || currency.contains('Amerikan Doları')) {
              final sellingRate = cells[2].text.trim().replaceAll(',', '.');
              usdRate = double.tryParse(sellingRate);
              break;
            }
          }
        }

        // EUR için arama
        final eurRows = document.querySelectorAll('tr');
        for (final row in eurRows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 3) {
            final currency = cells[0].text.trim();
            if (currency.contains('EUR') || currency.contains('Euro')) {
              final sellingRate = cells[2].text.trim().replaceAll(',', '.');
              eurRate = double.tryParse(sellingRate);
              break;
            }
          }
        }
      }
    } catch (e) {
      // Hata durumunda null değerler döndürülür
    }

    return ExchangeRates(
      usdRate: usdRate,
      eurRate: eurRate,
      dataSource: 'Direct (İş Bankası)',
      fetchTime: DateTime.now(),
    );
  }

  Future<ExchangeRates> _fetchRatesFromPHP() async {
    double? usdRate;
    double? eurRate;
    
    try {
      final response = await http.get(
        Uri.parse('https://finans.truncgil.com/today.json'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['USD'] != null && data['USD']['Satış'] != null) {
          final usdSelling = data['USD']['Satış'].toString().replaceAll(',', '.');
          usdRate = double.tryParse(usdSelling);
        }
        
        if (data['EUR'] != null && data['EUR']['Satış'] != null) {
          final eurSelling = data['EUR']['Satış'].toString().replaceAll(',', '.');
          eurRate = double.tryParse(eurSelling);
        }
      }
    } catch (e) {
      // Hata durumunda null değerler döndürülür
    }

    return ExchangeRates(
      usdRate: usdRate,
      eurRate: eurRate,
      dataSource: 'PHP (JSON API)',
      fetchTime: DateTime.now(),
    );
  }
}
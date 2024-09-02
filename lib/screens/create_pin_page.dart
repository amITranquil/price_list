import 'package:flutter/material.dart';
import '/utils/database_helper.dart';
import 'price_calculator_screen.dart'; // PriceCalculatorScreen import edin

class CreatePinPage extends StatefulWidget {
  const CreatePinPage({super.key});

  @override
  CreatePinPageState createState() => CreatePinPageState();
}

class CreatePinPageState extends State<CreatePinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  void _createPin() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    if (pin == confirmPin) {
      await DatabaseHelper().setPinCode(pin);
      if (!mounted) return;

      // PIN kodu başarıyla oluşturulduktan sonra PriceCalculatorScreen'e geç
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PriceCalculatorScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN kodları uyuşmuyor!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIN Kodu Oluştur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni PIN Kodu',
              ),
            ),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PIN Kodunu Onayla',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createPin,
              child: const Text('PIN Kodu Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}

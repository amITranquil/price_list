import 'package:flutter/material.dart';
import '/utils/database_helper.dart';

class UpdatePinPage extends StatefulWidget {
  const UpdatePinPage({super.key});

  @override
  UpdatePinPageState createState() => UpdatePinPageState();
}

class UpdatePinPageState extends State<UpdatePinPage> {
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmNewPinController = TextEditingController();

  void _updatePin() async {
    final oldPin = _oldPinController.text;
    final newPin = _newPinController.text;
    final confirmNewPin = _confirmNewPinController.text;

    final storedPin = await DatabaseHelper().getPinCode();

    // Eski PIN'in doğruluğunu kontrol et
    if (oldPin != storedPin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eski PIN kodu yanlış!')),
      );
      return;
    }

    // Yeni PIN'in eski PIN ile aynı olmaması gerektiğini kontrol et
    if (newPin == oldPin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni PIN kodu eski PIN kodu ile aynı olamaz!')),
      );
      return;
    }

    // Yeni PIN kodlarının eşleşmesini kontrol et
    if (newPin == confirmNewPin) {
      await DatabaseHelper().setPinCode(newPin);
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni PIN kodları uyuşmuyor!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIN Kodu Güncelle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _oldPinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Eski PIN Kodu',
              ),
            ),
            TextField(
              controller: _newPinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni PIN Kodu',
              ),
            ),
            TextField(
              controller: _confirmNewPinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni PIN Kodunu Onayla',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePin,
              child: const Text('PIN Kodu Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}

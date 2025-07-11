import 'package:flutter/material.dart';
import '/utils/database_helper.dart';
import 'price_calculator_screen.dart'; // PriceCalculatorScreen import edin
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatePinPage extends StatefulWidget {
  final Function(Locale)? onLanguageChange;
  
  const CreatePinPage({super.key, this.onLanguageChange});

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
        MaterialPageRoute(builder: (context) => PriceCalculatorScreen(onLanguageChange: widget.onLanguageChange)),
      );
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pinMismatch)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createPinTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.newPinLabel,
              ),
            ),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.confirmPinLabel,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createPin,
              child: Text(l10n.createPinButton),
            ),
          ],
        ),
      ),
    );
  }
}

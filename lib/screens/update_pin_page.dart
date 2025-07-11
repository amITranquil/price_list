import 'package:flutter/material.dart';
import '/utils/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final storedPin = await DatabaseHelper().getPinCode();

    // Eski PIN'in doğruluğunu kontrol et
    if (oldPin != storedPin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wrongOldPin)),
      );
      return;
    }

    // Yeni PIN'in eski PIN ile aynı olmaması gerektiğini kontrol et
    if (newPin == oldPin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.samePinError)),
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
        SnackBar(content: Text(l10n.newPinMismatch)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.updatePinTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _oldPinController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.oldPinLabel,
              ),
            ),
            TextField(
              controller: _newPinController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.newPinLabel,
              ),
            ),
            TextField(
              controller: _confirmNewPinController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.confirmNewPinLabel,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePin,
              child: Text(l10n.updatePinButton),
            ),
          ],
        ),
      ),
    );
  }
}

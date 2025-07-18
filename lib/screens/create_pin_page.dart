import 'package:flutter/material.dart';
import 'price_calculator_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/validation_service.dart';
import '../services/error_handling_service.dart';
import '../repositories/pin_repository.dart';
import '../di/injection.dart';

class CreatePinPage extends StatefulWidget {
  final Function(Locale)? onLanguageChange;
  
  const CreatePinPage({super.key, this.onLanguageChange});

  @override
  CreatePinPageState createState() => CreatePinPageState();
}

class CreatePinPageState extends State<CreatePinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final ValidationService _validationService = getIt<ValidationService>();
  final ErrorHandlingService _errorHandlingService = getIt<ErrorHandlingService>();
  final PinRepository _pinRepository = getIt<PinRepository>();

  void _createPin() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    // Validate PIN
    final pinValidation = _validationService.validatePinCode(pin, l10n: AppLocalizations.of(context)!);
    if (!pinValidation.isValid) {
      _errorHandlingService.showErrorSnackBar(
        context,
        ErrorFactory.validationError(
          pinValidation.errorMessage!,
          pinValidation.localizedErrorKey
        )
      );
      return;
    }

    // Validate confirmation PIN
    final confirmPinValidation = _validationService.validatePinCode(confirmPin, l10n: AppLocalizations.of(context)!);
    if (!confirmPinValidation.isValid) {
      _errorHandlingService.showErrorSnackBar(
        context,
        ErrorFactory.validationError(
          confirmPinValidation.errorMessage!,
          confirmPinValidation.localizedErrorKey
        )
      );
      return;
    }

    if (pin == confirmPin) {
      try {
        await _pinRepository.setPinCode(pin);
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PriceCalculatorScreen(onLanguageChange: widget.onLanguageChange)),
        );
      } catch (e, stackTrace) {
        _errorHandlingService.showErrorSnackBar(
          context,
          ErrorFactory.storageError('Failed to save PIN: ${e.toString()}', e, stackTrace)
        );
      }
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

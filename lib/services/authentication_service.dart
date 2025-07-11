import 'package:flutter/material.dart';
import '../repositories/pin_repository.dart';
import '../screens/create_pin_page.dart';
import '../screens/update_pin_page.dart';

abstract class AuthenticationService {
  Future<bool> validatePin(String pin);
  Future<void> navigateToCreatePin(BuildContext context, Function(Locale)? onLanguageChange);
  Future<void> navigateToUpdatePin(BuildContext context);
  Future<bool> hasPinCode();
}

class PinAuthenticationService implements AuthenticationService {
  final PinRepository _pinRepository;

  PinAuthenticationService(this._pinRepository);

  @override
  Future<bool> validatePin(String pin) async {
    final storedPin = await _pinRepository.getPinCode();
    return storedPin == pin;
  }

  @override
  Future<void> navigateToCreatePin(BuildContext context, Function(Locale)? onLanguageChange) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePinPage(onLanguageChange: onLanguageChange),
      ),
    );
  }

  @override
  Future<void> navigateToUpdatePin(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpdatePinPage(),
      ),
    );
  }

  @override
  Future<bool> hasPinCode() async {
    final pinCode = await _pinRepository.getPinCode();
    return pinCode != null;
  }
}
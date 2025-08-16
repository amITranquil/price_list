import 'package:flutter/material.dart';

class TextInputHelpers {
  /// Converts commas to dots in text input and updates the controller
  static void handleCommaToDecimal(String value, TextEditingController controller) {
    if (value.contains(',')) {
      final newValue = value.replaceAll(',', '.');
      controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }
}
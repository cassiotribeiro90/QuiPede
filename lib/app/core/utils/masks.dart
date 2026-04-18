import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 11) return oldValue;

    String formatted = '';
    if (text.isNotEmpty) {
      formatted += '(';
      if (text.length <= 2) {
        formatted += text;
      } else {
        formatted += '${text.substring(0, 2)}) ';
        if (text.length <= 7) {
          formatted += text.substring(2);
        } else if (text.length <= 10) {
          // Fixo: (11) 4444-4444
          formatted += '${text.substring(2, 6)}-${text.substring(6)}';
        } else {
          // Celular: (11) 99999-9999
          formatted += '${text.substring(2, 7)}-${text.substring(7)}';
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) return oldValue;

    String formatted = '';
    if (text.isNotEmpty) {
      if (text.length <= 5) {
        formatted = text;
      } else {
        formatted = '${text.substring(0, 5)}-${text.substring(5)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

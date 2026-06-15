import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('/', '');
    if (text.isEmpty) return const TextEditingValue(text: '');

    // Limitar a máximo 8 números
    if (text.length > 8) return oldValue;

    String buffer = "";
    for (int i = 0; i < text.length; i++) {
      // 1. Validar Día (posiciones 0 y 1)
      if (i == 0 && int.parse(text[i]) > 3) return oldValue; 
      if (i == 1 && text[0] == '3' && int.parse(text[i]) > 1) return oldValue;

      // 2. Validar Mes (posiciones 2 y 3)
      if (i == 2 && int.parse(text[i]) > 1) return oldValue;
      if (i == 3 && text[2] == '1' && int.parse(text[i]) > 2) return oldValue;

      // 3. Validar Año (posiciones 4, 5, 6, 7)
      if (i == 4) {
        // Solo permite empezar con 1 o 2 (para 19xx, 20xx, 21xx)
        if (text[i] != '1' && text[i] != '2') return oldValue;
      }
      if (i == 5) {
        // Si empezó con 2, solo permite 0 o 1 (para 20xx o 21xx)
        if (text[4] == '2' && text[i] != '0' && text[i] != '1') return oldValue;
        // Si empezó con 1, debe seguir con 9 (para 19xx)
        if (text[4] == '1' && text[i] != '9') return oldValue;
      }

      // Agregar '/' automáticamente
      if (i == 2 || i == 4) buffer += '/';
      buffer += text[i];
    }

    return TextEditingValue(
      text: buffer,
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
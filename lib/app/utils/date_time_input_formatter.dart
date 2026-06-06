import 'package:flutter/services.dart';

class DateTimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < text.length && i < 12; i++) {
      buffer.write(text[i]);
      if (i == 3) buffer.write('-'); // después de año
      if (i == 5) buffer.write('-'); // después de mes
      if (i == 7) buffer.write('/'); // después de día
      if (i == 9) buffer.write(':'); // después de hora
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

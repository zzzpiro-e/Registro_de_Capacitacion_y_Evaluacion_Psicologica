class TextUtils {
  // 🔹 Quitar tildes y pasar a minúsculas
  static String quitarTildes(String input) {
    const acentos = {
      'á': 'a', 'Á': 'A',
      'é': 'e', 'É': 'E',
      'í': 'i', 'Í': 'I',
      'ó': 'o', 'Ó': 'O',
      'ú': 'u', 'Ú': 'U',
      'ñ': 'n', 'Ñ': 'N',
    };

    String salida = input;
    acentos.forEach((conAcento, sinAcento) {
      salida = salida.replaceAll(conAcento, sinAcento);
    });
    return salida.toLowerCase();
  }
}


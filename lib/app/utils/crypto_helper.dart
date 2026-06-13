import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class CryptoHelper {
  // ⚠️ IMPORTANTE: La llave debe tener EXACTAMENTE 32 caracteres (32 bytes)
  static const String _llaveSecreta = "ClaveSecretaPsicologia32Chr20267"; 
  
  // ⚠️ IMPORTANTE: El IV debe tener EXACTAMENTE 16 caracteres (16 bytes)
  static const String _ivSecreta = "Vector16BytesSec"; 

  /// Encripta los bytes del PDF antes de mandarlo a Supabase
  static Uint8List encriptarBytes(Uint8List bytesOriginales) {
    final key = encrypt.Key.fromUtf8(_llaveSecreta);
    final iv = encrypt.IV.fromUtf8(_ivSecreta);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encriptado = encrypter.encryptBytes(bytesOriginales, iv: iv);
    return Uint8List.fromList(encriptado.bytes);
  }

  /// Desencripta los bytes del PDF cuando lo descargues para poder leerlo
  static Uint8List desencriptarBytes(Uint8List bytesEncriptados) {
    final key = encrypt.Key.fromUtf8(_llaveSecreta);
    final iv = encrypt.IV.fromUtf8(_ivSecreta);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encriptadoFormato = encrypt.Encrypted(bytesEncriptados);
    final desencriptado = encrypter.decryptBytes(encriptadoFormato, iv: iv);
    return Uint8List.fromList(desencriptado);
  }
}
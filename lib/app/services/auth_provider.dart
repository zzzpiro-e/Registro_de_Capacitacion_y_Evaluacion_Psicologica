import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _emailError;
  String? get emailError => _emailError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  int _attempts = 0;
  final int _maxAttempts = 5;

  DateTime? _blockedUntil;
  DateTime? get blockedUntil => _blockedUntil;

  bool get isBlocked {
    if (_blockedUntil == null) return false;
    return DateTime.now().isBefore(_blockedUntil!);
  }

  Future<String?> login(
    String email,
    String password,
  ) async {
    if (_isLoading) return null;

    if (isBlocked) {
      _passwordError =
          "Cuenta bloqueada hasta ${_blockedUntil!.hour}:${_blockedUntil!.minute.toString().padLeft(2, '0')}";
      notifyListeners();
      return null;
    }

    _emailError = null;
    _passwordError = null;
    _isLoading = true;
    notifyListeners();

    email = email.trim();
    password = password.trim();

    if (email.isEmpty) {
      _emailError = "El correo es obligatorio";
      _isLoading = false;
      notifyListeners();
      return null;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _emailError = "Formato de correo inválido";
      _isLoading = false;
      notifyListeners();
      return null;
    }

    if (password.isEmpty) {
      _passwordError = "La contraseña es obligatoria";
      _isLoading = false;
      notifyListeners();
      return null;
    }

    if (password.length < 6) {
      _passwordError = "Debe tener al menos 6 caracteres";
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final Map<String, dynamic> resultado = await _authService.login(
      email,
      password,
    );

    _isLoading = false;

    final bool success = resultado['success'] == true;

    if (success) {
      _attempts = 0;
      _blockedUntil = null;
      notifyListeners();

      final String rol = (resultado['rol'] ?? '')
          .toString()
          .toLowerCase();

      if (rol == 'psicologo') {
        return 'psicologo_main';
      }

      if (rol == 'admin') {
        return 'admin_main';
      }

      return 'main';
    }

    _attempts++;

    if (_attempts >= _maxAttempts) {
      _blockedUntil = DateTime.now().add(const Duration(minutes: 10));
      _passwordError =
          "Has alcanzado el máximo de $_maxAttempts intentos. Cuenta bloqueada por 10 minutos.";
      _attempts = 0;
      notifyListeners();
      return null;
    }

    final String errorCode = (resultado['errorCode'] ?? '').toString();

    switch (errorCode) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        _passwordError = 'Credenciales incorrectas o no existen';
        break;

      case 'invalid-email':
        _emailError = 'Formato de correo inválido';
        break;

      case 'user-disabled':
        _emailError = 'La cuenta está deshabilitada';
        break;

      default:
        _passwordError = (resultado['message'] ?? 'Error al iniciar sesión').toString();
    }

    notifyListeners();
    return null;
  }

  void limpiarErrores() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }
}
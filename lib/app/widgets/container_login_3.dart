import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_flutter/app/widgets/auth_text_field.dart';

class ContainerTresLogin extends StatefulWidget {
  const ContainerTresLogin({super.key});

  @override
  State<ContainerTresLogin> createState() => _ContainerTresLoginState();
}

class _ContainerTresLoginState extends State<ContainerTresLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;
  bool _isLoading = false; 
  int _attempts = 0; // 🔹 contador de intentos fallidos
  final int _maxAttempts = 5; // 🔹 límite máximo
  DateTime? _blockedUntil; // 🔹 tiempo hasta el cual está bloqueado

  Future<void> loginUser() async {
    if (_isLoading) return;

    // --- Verificar bloqueo temporal ---
    if (_blockedUntil != null) {
      if (DateTime.now().isBefore(_blockedUntil!)) {
        setState(() {
          passwordError = "Cuenta bloqueada hasta ${_blockedUntil!.hour}:${_blockedUntil!.minute.toString().padLeft(2, '0')}. Intenta más tarde.";
        });
        return;
      } else {
        // 🔹 Ya pasaron los 10 minutos, reseteamos
        _blockedUntil = null;
        _attempts = 0;
      }
    }

    if (_attempts >= _maxAttempts) {
      // 🔹 Bloqueamos por 10 minutos
      _blockedUntil = DateTime.now().add(const Duration(minutes: 10));
      setState(() {
        passwordError = "Has alcanzado el máximo de $_maxAttempts intentos. La cuenta está bloqueada por 10 minutos.";
      });
      return;
    }

    setState(() {
      emailError = null;
      passwordError = null;
      _isLoading = true;
    });

    // --- Validaciones locales ---
    if (emailController.text.trim().isEmpty) {
      setState(() {
        emailError = "El correo es obligatorio";
        _isLoading = false;
      });
      return;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      setState(() {
        emailError = "Formato de correo inválido";
        _isLoading = false;
      });
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      setState(() {
        passwordError = "La contraseña es obligatoria";
        _isLoading = false;
      });
      return;
    } else if (passwordController.text.trim().length < 6) {
      setState(() {
        passwordError = "Debe tener al menos 6 caracteres";
        _isLoading = false;
      });
      return;
    }

    // --- Firebase login ---
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, 'main');
      _attempts = 0; // 🔹 reiniciamos contador si login fue exitoso
    } on FirebaseAuthException catch (e) {
      setState(() {
        _attempts++; // 🔹 sumamos intento fallido
        switch (e.code) {
          case 'user-not-found':
            emailError = "Error al iniciar sesión: credenciales no existen";
            break;
          case 'wrong-password':
            passwordError = "Error al iniciar sesión: contraseña incorrecta";
            break;
          case 'invalid-email':
            emailError = "Formato de correo inválido";
            break;
          case 'user-disabled':
            emailError = "La cuenta está deshabilitada";
            break;
          default:
            passwordError = "Error al iniciar sesión: credenciales no existen o son inválidas";
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBlocked = _blockedUntil != null && DateTime.now().isBefore(_blockedUntil!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),

          const Text(
            'Correo Electrónico',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            hint: 'usuario@empresa.cl',
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          if (emailError != null)
            Text(emailError!, style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 34),

          const Text(
            'Contraseña',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: passwordController,
          ),
          if (passwordError != null)
            Text(passwordError!, style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 72,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? Colors.grey : const Color(0xFF43A047),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 5,
              ),
              onPressed: (isBlocked || _isLoading) ? null : loginUser,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      isBlocked
                          ? "Cuenta bloqueada, espera 10 min"
                          : "Iniciar Sesión",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 40),
          const Divider(),
        ],
      ),
    );
  }
}

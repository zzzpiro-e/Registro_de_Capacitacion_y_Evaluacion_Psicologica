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

  Future<void> loginUser() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    // 🔹 Validación local de correo
    if (emailController.text.trim().isEmpty) {
      setState(() => emailError = "El correo es obligatorio");
      return;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      setState(() => emailError = "Formato de correo inválido");
      return;
    }

    // 🔹 Validación local de contraseña
    if (passwordController.text.trim().isEmpty) {
      setState(() => passwordError = "La contraseña es obligatoria");
      return;
    } else if (passwordController.text.trim().length < 6) {
      setState(() => passwordError = "Debe tener al menos 6 caracteres");
      return;
    }

    // 🔹 Validación con Firebase
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, 'main');
    } on FirebaseAuthException catch (e) {
  setState(() {
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
        // 🔹 Captura cualquier otro error genérico
        passwordError = "Error al iniciar sesión: credenciales no existen o son inválidas";
    }
  });
}
  }

  @override
  Widget build(BuildContext context) {
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

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // 🔹 Aquí puedes implementar recuperación de contraseña
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 72,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 5,
              ),
              onPressed: loginUser,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                ],
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
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
  int _attempts = 0; 
  final int _maxAttempts = 5; 
  DateTime? _blockedUntil; 

  Future<void> loginUser() async {
    if (_isLoading) return;

    if (_blockedUntil != null) {
      if (DateTime.now().isBefore(_blockedUntil!)) {
        if (!mounted) return; 
        setState(() {
          passwordError = "Cuenta bloqueada hasta ${_blockedUntil!.hour}:${_blockedUntil!.minute.toString().padLeft(2, '0')}. Intenta más tarde.";
        });
        return;
      } else {
        _blockedUntil = null;
        _attempts = 0;
      }
    }

    if (_attempts >= _maxAttempts) {
      _blockedUntil = DateTime.now().add(const Duration(minutes: 10));
      if (!mounted) return; 
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

    final emailTexto = emailController.text.trim();
    final passwordTexto = passwordController.text.trim();

    if (emailTexto.isEmpty) {
      setState(() {
        emailError = "El correo es obligatorio";
        _isLoading = false;
      });
      return;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailTexto)) {
      setState(() {
        emailError = "Formato de correo inválido";
        _isLoading = false;
      });
      return;
    }

    if (passwordTexto.isEmpty) {
      setState(() {
        passwordError = "La contraseña es obligatoria";
        _isLoading = false;
      });
      return;
    } else if (passwordTexto.length < 6) {
      setState(() {
        passwordError = "Debe tener al menos 6 caracteres";
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential credencialUsuario = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTexto,
        password: passwordTexto,
      );

      User? usuario = credencialUsuario.user;
      if (usuario != null && mounted) {
        // 1. Buscar en la colección 'usuarios'
        DocumentSnapshot documentoUsuario = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .get();
            
        // 2. Si no existe, buscar en 'trabajadores'
        if (!documentoUsuario.exists) {
          documentoUsuario = await FirebaseFirestore.instance
              .collection('trabajadores')
              .doc(usuario.uid)
              .get();
        }

        if (!mounted) return; 

        if (documentoUsuario.exists && documentoUsuario.data() != null) {
          Map<String, dynamic> datosUsuario = documentoUsuario.data() as Map<String, dynamic>;
          String rol = (datosUsuario['rol'] ?? datosUsuario['role'] ?? '').toString().toLowerCase();

          _attempts = 0; 

          // 🟢 Apagamos de forma segura el cargando antes de saltar de pantalla
          setState(() {
            _isLoading = false;
          });

          // 🟢 Redirección totalmente separada por roles
          if (rol == 'psicologo') {
            Navigator.pushReplacementNamed(context, 'psicologo_main');
          } else if (rol == 'rrhh') {
            Navigator.pushReplacementNamed(context, 'main'); // Mandamos a RRHH a su MainScreen
          } else if (rol == 'admin') {
            Navigator.pushReplacementNamed(context, 'admin_main'); // El administrador va a AdminMainScreen
          } else {
            Navigator.pushReplacementNamed(context, 'main');
          }
          return; 
        } else {
          // Si el documento no existe en ninguna colección real de la base de datos
          if (emailTexto == 'admin@empresa.cl') {
            setState(() { _isLoading = false; });
            Navigator.pushReplacementNamed(context, 'admin_main');
            return;
          } else {
            setState(() {
              passwordError = "Error: No se encontró el perfil en la base de datos.";
              _isLoading = false;
            });
            return;
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; 
      setState(() {
        _attempts++; 
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
            passwordError = "Error al iniciar sesión: credenciales incorrectas o no existen";
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
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; 
      setState(() {
        passwordError = "Error inesperado: $e";
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
                      isBlocked ? "Cuenta bloqueada, espera 10 min" : "Iniciar Sesión",
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
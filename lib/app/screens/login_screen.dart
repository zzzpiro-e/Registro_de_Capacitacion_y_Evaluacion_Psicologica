import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // 🔹 Quitamos padding lateral para permitir ancho completo
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado dinámico (cambia según tipoLogin)
              ContainerUno(tipoLogin: 1), // RRHH
              // ContainerUno(tipoLogin: 2), // Académico
              // ContainerUno(tipoLogin: 3), // Médico

              const SizedBox(height: 20),

              // Texto dinámico de bienvenida
              ContainerDosLogin(tipoLogin: 1),

              const SizedBox(height: 20),

              // Formulario de correo y contraseña
              const ContainerTresLogin(),

              const SizedBox(height: 20),

              // Footer con versión del sistema
              const ContainerCuatroLogin(),
            ],
          ),
        ),
      ),
    );
  }
}

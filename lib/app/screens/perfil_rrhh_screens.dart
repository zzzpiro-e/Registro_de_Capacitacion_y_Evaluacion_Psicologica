import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_perfil_rrhh.dart';

class PerfilRRHHScreen extends StatelessWidget {
  const PerfilRRHHScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil Analista RRHH',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF388E3C), // Verde institucional
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            // Contenedor 1: Perfil principal
            ContainerPerfilRRHHUno(),
            SizedBox(height: 20),

            // Contenedor 2: Información de contacto
            ContainerPerfilRRHHDos(),
            SizedBox(height: 20),

            // Contenedor 3: Información profesional
            ContainerPerfilRRHHTres(),
            SizedBox(height: 20),

            // Contenedor 4: Botón cerrar sesión
            ContainerPerfilRRHHCuatro(),
          ],
        ),
      ),
    );
  }
}

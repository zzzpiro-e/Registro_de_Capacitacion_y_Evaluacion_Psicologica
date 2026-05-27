import 'package:flutter/material.dart';

class ContainerPerfilPsicologoCuatro extends StatelessWidget {
  const ContainerPerfilPsicologoCuatro({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          // Destruye las vistas actuales y te manda al Login Screen directo
          Navigator.pushReplacementNamed(context, 'login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF2E3D), // Tu Rojo del diseño
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.logout, color: Colors.white, size: 22),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔹 Importante: Añadimos este import para poder usar Firebase

class ContainerPerfilPsicologoCuatro extends StatelessWidget {
  const ContainerPerfilPsicologoCuatro({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        // 🔹 1. Transformamos la función a asíncrona (async)
        onPressed: () async {
          
          // 🔹 2. Forzamos el cierre de sesión real en los servidores y la caché local
          await FirebaseAuth.instance.signOut();

          // 🔹 3. Limpiamos TODA la pila de navegación para que no queden rastros en memoria
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF2E3D),
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
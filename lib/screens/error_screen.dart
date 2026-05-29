import 'package:flutter/material.dart';

/// 🛑 PANTALLA DE ERROR
///
/// Se muestra cuando se intenta acceder a una ruta que no existe
/// en el sistema de navegación definido en AppRoutes.

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Ruta no encontrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La página que buscas no existe',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'home',
                  (route) => false,
                );
              },
              child: const Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PsicologoScreen extends StatelessWidget {
  const PsicologoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        title: const Text('Psicólogo'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.psychology_outlined,
                      size: 72,
                      color: Color(0xFF7C3AED),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Panel de Psicólogo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Aquí podrás ver evaluaciones, registrar observaciones y gestionar pacientes o trabajadores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

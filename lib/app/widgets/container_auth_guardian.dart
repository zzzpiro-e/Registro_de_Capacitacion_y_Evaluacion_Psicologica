import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/screens/login_screen.dart';
import 'package:proyecto_flutter/app/screens/main_screen.dart';
import 'package:proyecto_flutter/app/screens/admin_main_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_main_screen.dart';

class ContainerAuthGuardian extends StatelessWidget {
  const ContainerAuthGuardian({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    
    // Si está cargando el estado de la red, mostramos el indicador
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    // 🔹 CAMBIO CRÍTICO: Verificación estricta de datos reales del usuario
    if (snapshot.hasData && snapshot.data != null && snapshot.data?.uid != null) {
      return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  ),
                );
              }

              if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                final userData = roleSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final String role = (userData['rol'] ?? userData['role'] ?? '').toString().toLowerCase();

                // Redirigir automaticamente segun rol detectado
                if (role == 'psicologo') return const PsicologoMainScreen();
                if (role == 'admin') return const AdminMainScreen();
                return const MainScreen(); // RRHH por defecto
              }

              // Si falla la lectura del rol la sesion se cierra por seguridad
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            },
          );
        }

        // Si no hay sesion va directo al login estandar
        return const LoginScreen();
      },
    );
  }
}
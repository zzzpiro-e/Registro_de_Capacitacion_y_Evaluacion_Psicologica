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
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            ),
          );
        }

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


                switch (role) {
                  case 'admin':
                    return const AdminMainScreen();
                  case 'psicologo':
                    return const PsicologoMainScreen();
                  case 'rrhh':
                  default:
                    return const MainScreen(); // RRHH por defecto corporativo
                }
              }

              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
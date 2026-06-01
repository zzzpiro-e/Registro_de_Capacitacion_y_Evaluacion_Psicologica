import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'main_screen.dart';
import 'admin_main_screen.dart';
import 'psicologo_main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getHomeScreen() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      return const LoginScreen();
    }

    final data = userDoc.data() as Map<String, dynamic>;
    final role = data['rol'] ?? data['role'] ?? '';

    switch (role) {
      case 'admin':
        return const AdminMainScreen();

      case 'psicologo':
        return const PsicologoMainScreen();

      case 'rrhh':
      default:
        return const MainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getHomeScreen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data!;
      },
    );
  }
}

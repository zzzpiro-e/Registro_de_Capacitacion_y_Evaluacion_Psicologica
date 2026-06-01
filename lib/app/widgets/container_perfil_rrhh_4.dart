import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContainerPerfilRRHHCuatro extends StatelessWidget {
  const ContainerPerfilRRHHCuatro({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();

          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
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

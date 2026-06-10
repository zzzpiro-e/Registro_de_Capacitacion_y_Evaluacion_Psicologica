import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔹 Necesitamos esto para obtener el uid
import 'package:proyecto_flutter/app/widgets/widgets_perfil_rrhh.dart';

class PerfilRRHHScreen extends StatelessWidget {
  const PerfilRRHHScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual
    final User? user = FirebaseAuth.instance.currentUser;
    final String currentUid = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil Analista RRHH',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF388E3C)),
      ),
      body: currentUid.isEmpty 
          ? const Center(child: Text("No hay un usuario autenticado"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pasamos el currentUid a cada contenedor
                  ContainerPerfilRRHHUno(uid: currentUid),
                  const SizedBox(height: 20),

                  ContainerPerfilRRHHDos(uid: currentUid),
                  const SizedBox(height: 20),

                  ContainerPerfilRRHHTres(uid: currentUid),
                  const SizedBox(height: 20),

                  // Si el cuarto contenedor no necesita datos, déjalo así
                  const ContainerPerfilRRHHCuatro(),
                ],
              ),
            ),
    );
  }
}
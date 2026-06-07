import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerPerfilRRHHTres extends StatelessWidget {
  const ContainerPerfilRRHHTres({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user?.uid) // documento con el UID del usuario autenticado
          .snapshots(),   // 🔹 escucha cambios en tiempo real
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No se encontró información profesional"));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final especialidad = data['especialidad'] ?? 'Especialidad no registrada';
        final departamento = data['departamento'] ?? 'Departamento no registrado';
        final registroProfesional = data['registroProfesional'] ?? 'Registro no registrado';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información Profesional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Especialidad
              Row(
                children: [
                  const Icon(Icons.business_center_outlined, color: Color(0xFF388E3C), size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Especialidad',
                          style: TextStyle(
                            color: Color(0xFF388E3C),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          especialidad,
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Departamento
              Row(
                children: [
                  const Icon(Icons.domain_outlined, color: Color(0xFF388E3C), size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Departamento',
                          style: TextStyle(
                            color: Color(0xFF388E3C),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          departamento,
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Número de Registro Profesional
              Row(
                children: [
                  const Icon(Icons.badge_outlined, color: Color(0xFF388E3C), size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'N° Registro Profesional',
                          style: TextStyle(
                            color: Color(0xFF388E3C),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          registroProfesional,
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

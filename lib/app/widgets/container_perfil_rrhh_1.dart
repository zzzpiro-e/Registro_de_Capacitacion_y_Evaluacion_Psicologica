import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerPerfilRRHHUno extends StatelessWidget {
  final String uid;
  const ContainerPerfilRRHHUno({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('trabajadores').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final nombre = data?['nombre'] ?? 'Usuario';
        final cargo = data?['rol'] ?? 'Sin rol'; // Asumiendo que 'rol' es el cargo

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF388E3C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF66BB6A),
                child: Icon(Icons.person, size: 42, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(cargo, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
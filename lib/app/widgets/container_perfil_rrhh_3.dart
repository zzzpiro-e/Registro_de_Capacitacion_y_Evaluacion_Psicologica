import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerPerfilRRHHTres extends StatelessWidget {
  final String uid;
  const ContainerPerfilRRHHTres({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('trabajadores').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // Solo RUT y Correo Personal
              _buildRow(Icons.badge_outlined, 'RUT', data['rut'] ?? 'N/A'),
              const SizedBox(height: 18),
              _buildRow(Icons.mail_outline, 'Correo Personal', data['correoPersonal'] ?? 'N/A'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(IconData icon, String label, String val) => Row(
    children: [
      Icon(icon, color: const Color(0xFF388E3C)),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF388E3C), fontSize: 13)),
          Text(val, style: const TextStyle(fontSize: 15))
        ]
      )
    ]
  );
}
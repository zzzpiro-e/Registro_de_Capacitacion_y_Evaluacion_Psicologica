import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerDerivacionesContador extends StatelessWidget {
  final String? psicologoEmail;

  const ContainerDerivacionesContador({
    super.key,
    required this.psicologoEmail,
  });

  @override
  Widget build(BuildContext context) {
    const Color verdeBanner = Color(0xFF2E7D32);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('empleados')
          .where('derivado', isEqualTo: true)
          .where('psicologoEmail', isEqualTo: psicologoEmail)
          .snapshots(),
      builder: (context, snapshot) {
        int totalPendientes = 0;

        if (snapshot.hasData && snapshot.data != null) {
          for (var doc in snapshot.data!.docs) {
            final datos = doc.data() as Map<String, dynamic>;
            String estadoLimpio = (datos['estado'] ?? 'Pendiente')
                .toString()
                .trim()
                .toLowerCase();
            if (estadoLimpio == 'pendiente' || estadoLimpio == 'activo') {
              totalPendientes++;
            }
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: verdeBanner,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Casos Pendientes en Bandeja',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalPendientes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/widgets/widgets_capacitaciones.dart';

class CapacitacionesPage extends StatefulWidget {
  final VoidCallback? onReturnToDashboard;

  const CapacitacionesPage({super.key, this.onReturnToDashboard});

  @override
  State<CapacitacionesPage> createState() => _CapacitacionesPageState();
}

class _CapacitacionesPageState extends State<CapacitacionesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Encabezado
            ContainerCapacitacionesUno(
              onBackTap: widget.onReturnToDashboard,
            ),

            // 🔹 Resumen (pendientes, realizadas, totales)
            const ContainerCapacitacionesDos(),

            // 🔹 Lista de capacitaciones desde Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('capacitaciones').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No hay capacitaciones registradas"));
                  }

                  final capacitaciones = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'titulo': data['titulo'] ?? '',
                      'institucion': data['institucion'] ?? '',
                      'fechaInicio': data['fechaInicio'] != null
                          ? "${(data['fechaInicio'] as Timestamp).toDate().day}/"
                            "${(data['fechaInicio'] as Timestamp).toDate().month}/"
                            "${(data['fechaInicio'] as Timestamp).toDate().year}"
                          : 'Sin fecha',
                      'estado': data['estado'] ?? 'pendiente',
                    };
                  }).toList();

                  // 🔹 Pasamos la lista completa al container
                  return ContainerCapacitacionesTres(capacitaciones: capacitaciones);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

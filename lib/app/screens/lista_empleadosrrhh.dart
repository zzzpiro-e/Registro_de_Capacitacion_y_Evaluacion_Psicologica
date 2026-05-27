import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detalle_empleadorrhh.dart';

class ListaEmpleadosRRHH extends StatelessWidget {
  const ListaEmpleadosRRHH({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        title: const Text('Empleados'),
        backgroundColor: const Color(0xFF4CAF50),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('empleados')
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay empleados registrados',
              ),
            );
          }

          final empleados = snapshot.data!.docs;

          return ListView.builder(
            itemCount: empleados.length,

            itemBuilder: (context, index) {

              final emp =
                  empleados[index].data()
                      as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),

                child: ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.green,
                  ),

                  title: Text(
                    "${emp['nombres'] ?? ''} ${emp['apellidos'] ?? ''}",
                  ),

                  subtitle: Text(
                    "RUT: ${emp['rut'] ?? ''}",
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetalleEmpleadoRRHH(
                          rut: emp['rut'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/container_detalle_buscador.dart';
import '../widgets/container_derivaciones_contador.dart';
import '../widgets/container_lista_psicologo_2.dart';
import '../widgets/container_lista_psicologo_3.dart';

class PsicologoDerivacionesScreen extends StatefulWidget {
  const PsicologoDerivacionesScreen({super.key});

  @override
  State<PsicologoDerivacionesScreen> createState() =>
      _PsicologoDerivacionesScreenState();
}

class _PsicologoDerivacionesScreenState
    extends State<PsicologoDerivacionesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String correoPsicologo =
        FirebaseAuth.instance.currentUser?.email ?? '';

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          const ContainerListaPsicologoDos(titulo: 'Bandeja de Derivaciones'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: ContainerDerivacionesContador(
              psicologoEmail: correoPsicologo,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ContainerDetalleBuscador(
              controller: _searchController,
              onChanged: (valor) =>
                  setState(() => _filtroTexto = valor.toLowerCase().trim()),
            ),
          ),
          const SizedBox(height: 2),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('empleados')
                  .where('derivado', isEqualTo: true)
                  .where('psicologoEmail', isEqualTo: correoPsicologo)
                  .where(
                    'estado',
                    whereIn: [
                      'Pendiente',
                      'pendiente',
                      'En Proceso',
                      'en proceso',
                      'activo',
                      'Activo',
                    ],
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "Error de red al obtener las derivaciones",
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No hay empleados derivados"),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ContainerListaPsicologoTres(
                        documentosRaw: snapshot.data!.docs,
                        filtroTexto: _filtroTexto,
                        onRefresh: () => setState(() {}),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

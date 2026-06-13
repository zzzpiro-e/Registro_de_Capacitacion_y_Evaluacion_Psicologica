// Archivo: psicologo_derivaciones_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Componentes modulares importados
import '../widgets/container_detalle_buscador.dart'; 
import '../widgets/container_lista_psicologo_2.dart';
import '../widgets/container_lista_psicologo_3.dart';

class PsicologoDerivacionesScreen extends StatefulWidget {
  const PsicologoDerivacionesScreen({super.key});

  @override
  State<PsicologoDerivacionesScreen> createState() => _PsicologoDerivacionesScreenState();
}

class _PsicologoDerivacionesScreenState extends State<PsicologoDerivacionesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String correoPsicologo = FirebaseAuth.instance.currentUser?.email ?? '';

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          
          // 🏢 CONTAINER 2: Encabezado estático
          const ContainerListaPsicologoDos(titulo: 'Bandeja de Derivaciones'),
          
          // Buscador común de la app
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ContainerDetalleBuscador(
              controller: _searchController,
              onChanged: (valor) => setState(() => _filtroTexto = valor.toLowerCase().trim()),
            ),
          ),
          const SizedBox(height: 2),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('empleados')
                  .where('derivado', isEqualTo: true)
                  .where('psicologoEmail', isEqualTo: correoPsicologo)
                  .where('estado', whereIn: ['Pendiente', 'En Proceso', 'activo'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay empleados derivados"));
                }

                // 🏢 CONTAINER 3: Procesador y renderizador inteligente de la lista
                return ContainerListaPsicologoTres(
                  documentosRaw: snapshot.data!.docs,
                  filtroTexto: _filtroTexto,
                  onRefresh: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
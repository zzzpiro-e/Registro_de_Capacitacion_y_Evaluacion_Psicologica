import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/widgets/widgets_lista_empleados.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

class ListaEmpleadosPage extends StatefulWidget {
  final VoidCallback? onReturnToDashboard;

  const ListaEmpleadosPage({super.key, this.onReturnToDashboard});

  @override
  State<ListaEmpleadosPage> createState() => _ListaEmpleadosPageState();
}

class _ListaEmpleadosPageState extends State<ListaEmpleadosPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            ContainerListaEmpleadosUno(
              titulo: "Empleados",
              onBackTap: widget.onReturnToDashboard,
            ),
            ContainerListaEmpleadosDos(
              onSearch: (query) => setState(() => _query = query),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('empleados').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No hay empleados registrados"));
                  }

                  // Convertimos documentos en mapas
                  final empleados = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'nombres': data['nombres'] ?? '',
                      'apellidos': data['apellidos'] ?? '',
                      'rut': data['rut'] ?? '',
                      'estado': data['estado'] ?? '',
                    };
                  }).toList();

                  // Aplicamos filtro de búsqueda
                  final empleadosFiltrados = empleados.where((empleado) {
                    final nombreCompleto = "${empleado['nombres']} ${empleado['apellidos']}".toLowerCase();
                    final rutNormalizado = empleado['rut'].replaceAll(RegExp(r'[^0-9]'), '');
                    final queryNormalizado = TextUtils.quitarTildes(_query.toLowerCase());
                    return nombreCompleto.contains(queryNormalizado) || rutNormalizado.contains(queryNormalizado);
                  }).toList();

                  return ContainerListaEmpleadosTres(empleados: empleadosFiltrados);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

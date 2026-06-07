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
  int _retryKey = 0;

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
                key: ValueKey(_retryKey),
                stream: FirebaseFirestore.instance
                    .collection('empleados')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Error de conexión al cargar los empleados",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _retryKey++;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Reintentar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No hay empleados registrados"),
                    );
                  }

                  final empleados = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'id': doc.id,
                      'nombres': data['nombres'] ?? '',
                      'apellidos': data['apellidos'] ?? '',
                      'rut': data['rut'] ?? '',
                      'estado': data['estado'] ?? '',
                    };
                  }).toList();

                  final empleadosFiltrados = empleados.where((empleado) {
                    final nombreCompleto =
                        "${empleado['nombres']} ${empleado['apellidos']}"
                            .toLowerCase();
                    final rutNormalizado = empleado['rut'].replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    final queryNormalizado = TextUtils.quitarTildes(
                      _query.toLowerCase(),
                    );
                    return nombreCompleto.contains(queryNormalizado) ||
                        rutNormalizado.contains(queryNormalizado);
                  }).toList();

                  return ContainerListaEmpleadosTres(
                    empleados: empleadosFiltrados,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

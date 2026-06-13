import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/widgets/widgets_lista_empleados.dart';
import 'package:proyecto_flutter/app/services/empleados_service.dart';

class ListaEmpleadosPage extends StatefulWidget {
  final VoidCallback? onReturnToDashboard;

  const ListaEmpleadosPage({
    super.key,
    this.onReturnToDashboard,
  });

  @override
  State<ListaEmpleadosPage> createState() =>
      _ListaEmpleadosPageState();
}

class _ListaEmpleadosPageState
    extends State<ListaEmpleadosPage> {
  String _query = '';
  int _retryKey = 0;

  final EmpleadosService _service =
      EmpleadosService();

  // Controlar si usamos búsqueda optimizada o filtro local
  bool _usarBusquedaOptimizada = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            ContainerListaEmpleadosUno(
              titulo: "Empleados",
              onBackTap:
                  widget.onReturnToDashboard,
            ),
            ContainerListaEmpleadosDos(
              onSearch: (query) {
                setState(() {
                  _query = query;
                  // Decidir qué método usar según la búsqueda
                  _usarBusquedaOptimizada = _service.esBusquedaMayusculas(query);
                });
              },
            ),
            Expanded(
              child: _usarBusquedaOptimizada
                  ? _buildBusquedaOptimizada()
                  : _buildBusquedaLocal(),
            ),
          ],
        ),
      ),
    );
  }

  // BÚSQUEDA OPTIMIZADA (mayúsculas - consulta a Firestore)
  Widget _buildBusquedaOptimizada() {
    return StreamBuilder<QuerySnapshot>(
      key: ValueKey('optimized-$_query'),
      stream: _service.buscarEnFirestore(_query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No se encontraron empleados para '$_query'",
            ),
          );
        }

        final empleados = _service.convertirEmpleados(snapshot.data!);
        return ContainerListaEmpleadosTres(
          empleados: empleados,
        );
      },
    );
  }

  // BÚSQUEDA LOCAL (minúsculas/tildes - filtra en memoria)
  Widget _buildBusquedaLocal() {
    return StreamBuilder<QuerySnapshot>(
      key: ValueKey('local-$_retryKey'),
      stream: _service.obtenerEmpleados(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No hay empleados registrados"),
          );
        }

        final empleados = _service.convertirEmpleados(snapshot.data!);
        final empleadosFiltrados = _service.filtrarEmpleados(empleados, _query);

        if (empleadosFiltrados.isEmpty && _query.isNotEmpty) {
          return Center(
            child: Text(
              "No se encontraron resultados para '$_query'",
            ),
          );
        }

        return ContainerListaEmpleadosTres(
          empleados: empleadosFiltrados,
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
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
}
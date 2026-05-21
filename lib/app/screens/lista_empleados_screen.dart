import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_lista_empleados.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

class ListaEmpleadosPage extends StatefulWidget {
  const ListaEmpleadosPage({super.key});

  @override
  State<ListaEmpleadosPage> createState() => _ListaEmpleadosPageState();
}

class _ListaEmpleadosPageState extends State<ListaEmpleadosPage> {
  String _query = '';

  final List<Map<String, dynamic>> _empleados = [
    {'nombre': 'María González Díaz', 'rut': '12.345.678-9', 'estado': 'Activo'},
    {'nombre': 'Carlos Rodríguez López', 'rut': '15.789.456-2', 'estado': 'Pendiente'},
    {'nombre': 'Ana Martínez Silva', 'rut': '18.234.567-1', 'estado': 'Activo'},
    {'nombre': 'Roberto Fernández Castro', 'rut': '16.987.654-3', 'estado': 'Pendiente'},
    {'nombre': 'Laura Sánchez Morales', 'rut': '14.567.890-5', 'estado': 'Activo'},
    {'nombre': 'Diego Torres Ramírez', 'rut': '19.876.543-7', 'estado': 'Activo'},
  ];

  // 🔹 Filtrar empleados según búsqueda (normalizando nombres y query)
  List<Map<String, dynamic>> get _empleadosFiltrados {
    if (_query.isEmpty) return _empleados;

    final queryNormalizado = TextUtils.quitarTildes(_query);

    return _empleados.where((empleado) {
      final nombreNormalizado = TextUtils.quitarTildes(empleado['nombre']);
      final rutNormalizado = empleado['rut'].replaceAll(RegExp(r'[^0-9]'), '');
      return nombreNormalizado.contains(queryNormalizado) || rutNormalizado.contains(queryNormalizado);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      bottomNavigationBar: const ContainerListaEmpleadosCuatro(),
      body: SafeArea(
        child: Column(
          children: [
            const ContainerListaEmpleadosUno(titulo: "Empleados"),
            ContainerListaEmpleadosDos(
              onSearch: (query) => setState(() => _query = query),
            ),
            Expanded(
              child: ContainerListaEmpleadosTres(empleados: _empleadosFiltrados),
            ),
          ],
        ),
      ),
    );
  }
}

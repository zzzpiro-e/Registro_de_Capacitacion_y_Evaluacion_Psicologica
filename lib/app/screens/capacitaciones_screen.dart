import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_1.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_2.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_3.dart';
import 'package:proyecto_flutter/app/services/capacitaciones_service.dart';

class CapacitacionesPage extends StatefulWidget {
  final VoidCallback? onReturnToDashboard;
  final String filtroInicial;

  const CapacitacionesPage({
    super.key,
    this.onReturnToDashboard,
    this.filtroInicial = 'todas',
  });

  @override
  State<CapacitacionesPage> createState() => _CapacitacionesPageState();
}

class _CapacitacionesPageState extends State<CapacitacionesPage> {
  late String _filtroActivo;
  int _retryKey = 0;

  final CapacitacionesService _service = CapacitacionesService();

  @override
  void initState() {
    super.initState();
    _filtroActivo = widget.filtroInicial;
  }

  void _cambiarFiltro(String filtro) {
    if (_filtroActivo == filtro) return;
    setState(() {
      _filtroActivo = filtro;
    });
    debugPrint("Filtro cambiado a: ${filtro.toUpperCase()}");
  }

  void _reiniciarConexion() {
    setState(() => _retryKey++);
  }

  String _getTextoMostrando() {
    switch (_filtroActivo) {
      case 'todas': return 'Todas';
      case 'pendiente': return 'Pendientes';
      case 'realizada': return 'Realizadas';
      default: return 'Todas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            ContainerCapacitacionesUno(
              onBackTap: widget.onReturnToDashboard,
            ),
            // Stack con los filtros táctiles
            Stack(
              children: [
                const ContainerCapacitacionesDos(),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => _cambiarFiltro('pendiente'),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => _cambiarFiltro('realizada'),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => _cambiarFiltro('todas'),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            // Indicador de filtro activo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Mostrando: ${_getTextoMostrando()}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  if (_filtroActivo != 'todas') ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _cambiarFiltro('todas'),
                      child: const Text(
                        "(Ver todas)",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Lista de capacitaciones
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                key: ValueKey('$_retryKey'),
                stream: _service.obtenerCapacitaciones(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            "Error de conexión al cargar las capacitaciones",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _reiniciarConexion,
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
                      child: Text("No hay capacitaciones registradas"),
                    );
                  }

                  // Convertir capacitaciones usando el service
                  final todasLasCapacitaciones = _service.convertirLista(snapshot.data!);

                  // Filtrar por estado usando el service
                  final capacitacionesFiltradas = _service.filtrarPorEstado(
                    todasLasCapacitaciones,
                    _filtroActivo,
                  );

                  if (capacitacionesFiltradas.isEmpty) {
                    return Center(
                      child: Text(
                        "No hay capacitaciones ${_filtroActivo == 'pendiente' ? 'pendientes' : 'realizadas'}",
                        style: const TextStyle(color: Colors.black45, fontSize: 15),
                      ),
                    );
                  }

                  return ContainerCapacitacionesTres(
                    capacitaciones: capacitacionesFiltradas,
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
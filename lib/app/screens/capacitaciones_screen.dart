import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_1.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_2.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_3.dart';
import 'package:proyecto_flutter/app/services/capacitaciones_service.dart';

// Constantes
const _backgroundColor = Color(0xFFF4F4F4);
const _verdeFirebase = Color(0xFF2E7D32);

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
  bool _estadosVerificados = false;

  final CapacitacionesService _service = CapacitacionesService();

  @override
  void initState() {
    super.initState();
    _filtroActivo = widget.filtroInicial;
    _verificarEstados();
  }

  Future<void> _verificarEstados() async {
    await _service.verificarTodosLosEstados();
    if (mounted) {
      setState(() => _estadosVerificados = true);
    }
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
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ContainerCapacitacionesUno(
              onBackTap: widget.onReturnToDashboard,
            ),
            _buildFiltros(),
            _buildIndicadorFiltro(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                key: ValueKey('$_retryKey'),
                stream: _service.obtenerCapacitacionesPorEstado(_filtroActivo),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorWidget();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final capacitaciones = _service.convertirLista(snapshot.data!);

                  return ContainerCapacitacionesTres(
                    capacitaciones: capacitaciones,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _FiltroButton(
            texto: "Pendientes",
            activo: _filtroActivo == 'pendiente',
            onTap: () => _cambiarFiltro('pendiente'),
          ),
          const SizedBox(width: 12),
          _FiltroButton(
            texto: "Realizadas",
            activo: _filtroActivo == 'realizada',
            onTap: () => _cambiarFiltro('realizada'),
          ),
          const SizedBox(width: 12),
          _FiltroButton(
            texto: "Todas",
            activo: _filtroActivo == 'todas',
            onTap: () => _cambiarFiltro('todas'),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadorFiltro() {
    return Padding(
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
                  color: _verdeFirebase,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
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
            "Error de conexión al cargar las capacitaciones",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _reiniciarConexion,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _verdeFirebase,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final texto = _filtroActivo == 'pendiente'
        ? 'No hay capacitaciones pendientes'
        : _filtroActivo == 'realizada'
            ? 'No hay capacitaciones realizadas'
            : 'No hay capacitaciones registradas';

    return Center(
      child: Text(
        texto,
        style: const TextStyle(color: Colors.black45, fontSize: 15),
      ),
    );
  }
}

class _FiltroButton extends StatelessWidget {
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroButton({
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: activo ? _verdeFirebase : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: activo
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: activo ? Colors.white : Colors.black87,
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
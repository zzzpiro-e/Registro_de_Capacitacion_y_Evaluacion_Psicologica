import 'package:flutter/material.dart';
import '../widgets/container_detalle_trabajador.dart';
import '../widgets/container_detalle_caso.dart';
import '../widgets/container_detalle_acciones.dart'; 

class PsicologoDetalleDerivacionScreen extends StatefulWidget {
  final Map<String, dynamic> derivacion;

  const PsicologoDetalleDerivacionScreen({
    super.key,
    required this.derivacion,
  });

  @override
  State<PsicologoDetalleDerivacionScreen> createState() => _PsicologoDetalleDerivacionScreenState();
}

class _PsicologoDetalleDerivacionScreenState extends State<PsicologoDetalleDerivacionScreen> {
  late String _estadoActual;
  late Map<String, dynamic> _datosDerivacion;

  @override
  void initState() {
    super.initState();
    _datosDerivacion = widget.derivacion;
    _estadoActual = _datosDerivacion['estado'] ?? 'Pendiente';
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return const Color(0xFFFFF3CD);
      case 'En Proceso': return const Color(0xFFD0E2FF);
      case 'Completado': return const Color(0xFFDFFFD6);
      default: return Colors.grey.shade200;
    }
  }

  Color _colorTextoEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return const Color(0xFFB8860B);
      case 'En Proceso': return const Color(0xFF0056B3);
      case 'Completado': return const Color(0xFF2E7D32);
      default: return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _estadoActual);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text(
            'Detalle de Derivación',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32), size: 20),
            onPressed: () => Navigator.pop(context, _estadoActual),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          decoration: BoxDecoration(
                            color: _colorEstado(_estadoActual),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _estadoActual,
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: _colorTextoEstado(_estadoActual),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ContainerDetalleTrabajador(datos: _datosDerivacion),
                      const SizedBox(height: 16),
                      ContainerDetalleCaso(datos: _datosDerivacion),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            ContainerDetalleAcciones(
              derivacion: _datosDerivacion,
              estadoActual: _estadoActual,
              onActualizarCaso: (nuevoEstado, nuevosDatos) {
                setState(() {
                  _estadoActual = nuevoEstado;
                  _datosDerivacion = nuevosDatos;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
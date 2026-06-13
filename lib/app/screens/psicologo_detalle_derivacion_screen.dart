// Archivo: psicologo_detalle_derivacion_screen.dart
import 'package:flutter/material.dart';

// Containers de la captura (manteniendo su naturaleza semántica)
import '../widgets/container_detalle_trabajador.dart';
import '../widgets/container_detalle_caso.dart';
import '../widgets/container_detalle_acciones.dart'; 
// 🔹 NUEVO CONTAINER CON NOMBRE INTUITIVO Y DESCRIPTIVO
import '../widgets/container_detalle_estado_psicologo.dart';

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
                      // 🏢 LLAMADA AL NUEVO CONTAINER SEMÁNTICO
                      ContainerDetalleEstadoPsicologo(estadoActual: _estadoActual),
                      const SizedBox(height: 20),
                      
                      ContainerDetalleTrabajador(datos: _datosDerivacion),
                      const SizedBox(height: 16),
                      
                      ContainerDetalleCaso(
                        datos: _datosDerivacion,
                        onInformeEliminado: (datosActualizados) {
                          setState(() {
                            _datosDerivacion = Map<String, dynamic>.from(datosActualizados);
                          });
                        },
                      ),
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
                
                if (nuevoEstado == 'Completado') {
                  Navigator.pop(context, nuevoEstado);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
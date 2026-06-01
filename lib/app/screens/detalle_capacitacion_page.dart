import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_detalle_capacitacion.dart';

class DetalleCapacitacionPage extends StatelessWidget {
  final Map<String, dynamic> capacitacion;

  const DetalleCapacitacionPage({super.key, required this.capacitacion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          "Detalle de Capacitación",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardInformacionPrincipal(capacitacion: capacitacion),
            const SizedBox(height: 16),
            CardFechasCapacitacion(capacitacion: capacitacion),
            const SizedBox(height: 16),
            CardListaEmpleadosCruce(
              rutsCampo: capacitacion['empleadosRealizaron'],
              tituloSeccion: "Empleados que la Realizaron",
              icono: Icons.check_circle_outline,
              colorIcono: const Color(0xFF2E7D32),
              mensajeVacio:
                  "Ningún empleado ha registrado la realización de esta actividad.",
            ),
            const SizedBox(height: 16),
            CardListaEmpleadosCruce(
              rutsCampo: capacitacion['empleadosAsignados'],
              tituloSeccion: "Empleados Asignados / Pendientes",
              icono: Icons.history_toggle_off,
              colorIcono: Colors.orange,
              mensajeVacio: "No constan empleados pendientes asignados.",
            ),
          ],
        ),
      ),
    );
  }
}

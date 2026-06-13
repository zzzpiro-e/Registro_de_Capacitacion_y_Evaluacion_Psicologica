import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/services/capacitaciones_service.dart';
import 'package:proyecto_flutter/app/widgets/widgets_detalle_capacitacion.dart';

class DetalleCapacitacionPage extends StatefulWidget {
  final Map<String, dynamic> capacitacion;

  const DetalleCapacitacionPage({
    super.key,
    required this.capacitacion,
  });

  @override
  State<DetalleCapacitacionPage> createState() =>
      _DetalleCapacitacionPageState();
}

class _DetalleCapacitacionPageState
    extends State<DetalleCapacitacionPage> {
  final CapacitacionesService _service =
      CapacitacionesService();

  late Future<List<Map<String, dynamic>>> _futureRealizaron;
  late Future<List<Map<String, dynamic>>> _futureAsignados;

  @override
  void initState() {
    super.initState();

    final List<String> rutsRealizaron =
        _service.convertirAListaString(
      widget.capacitacion['empleadosRealizaron'],
    );

    final List<String> rutsAsignados =
        _service.convertirAListaString(
      widget.capacitacion['empleadosAsignados'],
    );

    _futureRealizaron =
        _service.obtenerDetallesEmpleados(
      rutsRealizaron,
    );

    _futureAsignados =
        _service.obtenerDetallesEmpleados(
      rutsAsignados,
    );
  }

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
        iconTheme:
            const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            CardInformacionPrincipal(
              capacitacion: widget.capacitacion,
            ),

            const SizedBox(height: 16),

            CardFechasCapacitacion(
              capacitacion: widget.capacitacion,
            ),

            const SizedBox(height: 16),

            FutureBuilder<
                List<Map<String, dynamic>>>(
              future: _futureRealizaron,
              builder: (context, snapshot) {
                final empleados =
                    snapshot.data ?? [];

                return CardListaEmpleadosCruce(
                  rutsCampo: empleados,
                  tituloSeccion:
                      "Empleados que la Realizaron",
                  icono:
                      Icons.check_circle_outline,
                  colorIcono:
                      const Color(0xFF2E7D32),
                  mensajeVacio:
                      "Ningún empleado ha registrado la realización de esta actividad.",
                );
              },
            ),

            const SizedBox(height: 16),

            FutureBuilder<
                List<Map<String, dynamic>>>(
              future: _futureAsignados,
              builder: (context, snapshot) {
                final empleados =
                    snapshot.data ?? [];

                return CardListaEmpleadosCruce(
                  rutsCampo: empleados,
                  tituloSeccion:
                      "Empleados Asignados / Pendientes",
                  icono:
                      Icons.history_toggle_off,
                  colorIcono: Colors.orange,
                  mensajeVacio:
                      "No constan empleados pendientes asignados.",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
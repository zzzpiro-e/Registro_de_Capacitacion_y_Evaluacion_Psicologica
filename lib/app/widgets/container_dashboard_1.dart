import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Constantes fuera de la clase
const _verdeDashboard = Color(0xFF388E3C);
const _bienvenido = 'Bienvenido de vuelta';
const _rolUsuario = 'Jefe de RRHH';

class ContainerDashboardUno extends StatelessWidget {
  const ContainerDashboardUno({super.key});

  // La fecha se calcula una sola vez al construir el widget
  String get _fechaFormateada {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d MMMM yyyy', 'es_CL');
    final fechaRaw = formatter.format(now);
    return fechaRaw[0].toUpperCase() + fechaRaw.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: const BoxDecoration(
        color: _verdeDashboard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            _bienvenido,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12),
          Text(
            _rolUsuario,
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          // La fecha se obtiene del getter
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContainerPerfilEmpleadoDos extends StatefulWidget {
  final String empleadoId;

  const ContainerPerfilEmpleadoDos({super.key, required this.empleadoId});

  @override
  State<ContainerPerfilEmpleadoDos> createState() =>
      _ContainerPerfilEmpleadoDosState();
}

class _ContainerPerfilEmpleadoDosState
    extends State<ContainerPerfilEmpleadoDos> {
  final Color verdePrincipal = const Color(0xFF2E7D32);
  int _retryKey = 0;

  String _formatearRut(String rut) {
    String value = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
    if (value.length < 2) return value;
    
    String cuerpo = value.substring(0, value.length - 1);
    String dv = value.substring(value.length - 1).toUpperCase();
    
    String cuerpoFormateado = "";
    int contador = 0;
    for (int i = cuerpo.length - 1; i >= 0; i--) {
      cuerpoFormateado = cuerpo[i] + cuerpoFormateado;
      contador++;
      if (contador == 3 && i != 0) {
        cuerpoFormateado = '.$cuerpoFormateado';
        contador = 0;
      }
    }
    return '$cuerpoFormateado-$dv';
  }
  

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      key: ValueKey(_retryKey),
      stream: FirebaseFirestore.instance
          .collection('empleados')
          .doc(widget.empleadoId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text(
                    "Error al cargar datos personales",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _retryKey++),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reintentar"),
                    style: TextButton.styleFrom(
                      foregroundColor: verdePrincipal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Empleado no encontrado'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final nombreCompleto =
            "${data['nombres'] ?? ''} ${data['apellidos'] ?? ''}".trim();
        final nombreFinal = nombreCompleto.isEmpty
            ? 'Información no ingresada'
            : nombreCompleto;

        final rut = data['rut']?.toString() ?? 'Información no ingresada';
        final edad = data['edad']?.toString() ?? 'Información no ingresada';
        final cargo = data['cargo']?.toString() ?? 'Información no ingresada';

        String fechaIngreso = 'Información no ingresada';
        if (data['fechaIngreso'] != null) {
          if (data['fechaIngreso'] is Timestamp) {
            final timestamp = data['fechaIngreso'] as Timestamp;
            fechaIngreso = DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
          } else {
            final str = data['fechaIngreso'].toString();
            try {
              final parsed = DateFormat('yyyy-MM-dd/HH:mm').parse(str);
              fechaIngreso = DateFormat('dd/MM/yyyy HH:mm').format(parsed);
            } catch (_) {
              fechaIngreso = str;
            }
          }
        }
        String ultimaEdicion = 'Nunca editado';
        if (data['fechaUltimaEdicion'] is Timestamp) {
          final ts = data['fechaUltimaEdicion'] as Timestamp;
          ultimaEdicion = DateFormat('dd/MM/yyyy HH:mm').format(ts.toDate());
        }
        

        final salario = data['salario'] != null
            ? '\$${NumberFormat.decimalPattern('es_CL').format(data['salario'] is int ? data['salario'] : int.tryParse(data['salario'].toString()) ?? 0)}'
            : 'Información no ingresada';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      'editar_empleado_rrhh',
                      arguments: {'empleadoId': widget.empleadoId},
                    );
                  },
                  icon: Icon(Icons.edit, color: verdePrincipal),
                ),
              ),
              CircleAvatar(
                radius: 40,
                backgroundColor: verdePrincipal,
                child: const Icon(Icons.person, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 12),
              Text(
                nombreFinal,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatearRut(data['rut']?.toString() ?? ''),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16, // Un poco más grande que el texto normal
                  fontWeight: FontWeight.w700, // Negrito (w700 es visible pero no negro absoluto)
                  color: Colors.black87, // Un gris muy oscuro, menos agresivo que negro puro
                ),
              ),

              const SizedBox(height: 20),
              _buildInfoRow(Icons.badge_outlined, 'Edad', edad),
              _buildInfoRow(Icons.work_outline, 'Cargo', cargo),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Fecha de ingreso',
                fechaIngreso,
              ),
              _buildInfoRow(Icons.attach_money_outlined, 'Salario', salario),
              const Divider(height: 20),
              _buildInfoRow(Icons.history_outlined, 'Última edición', ultimaEdicion),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: verdePrincipal, size: 22),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

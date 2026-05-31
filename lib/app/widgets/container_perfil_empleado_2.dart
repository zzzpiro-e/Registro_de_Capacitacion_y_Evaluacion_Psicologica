import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContainerPerfilEmpleadoDos extends StatelessWidget {
  final String empleadoId;

  const ContainerPerfilEmpleadoDos({
    super.key,
    required this.empleadoId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('empleados')
          .doc(empleadoId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Empleado no encontrado'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        // Nombre completo
        final nombreCompleto =
            "${data['nombres'] ?? ''} ${data['apellidos'] ?? ''}".trim();
        final nombreFinal =
            nombreCompleto.isEmpty ? 'Información no ingresada' : nombreCompleto;

        // RUT
        final rut = data['rut'] ?? 'Información no ingresada';

        // Edad
        final edad = data['edad'] != null
            ? data['edad'].toString()
            : 'Información no ingresada';

        // Cargo
        final cargo = data['cargo']?.toString() ?? 'Información no ingresada';

        // Fecha de ingreso (Timestamp → DateTime → String)
        String fechaIngreso = 'Información no ingresada';
        if (data['fechaIngreso'] != null && data['fechaIngreso'] is Timestamp) {
          final timestamp = data['fechaIngreso'] as Timestamp;
          final dateTime = timestamp.toDate();
          fechaIngreso = DateFormat('dd/MM/yyyy').format(dateTime);
        }

        // Salario
        final salario = data['salario'] != null
            ? data['salario'].toString()
            : 'Información no ingresada';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF2E7D32),
                child: Icon(Icons.person, color: Colors.white, size: 50),
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
                rut,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _buildInfoRow(Icons.badge_outlined, 'Edad', edad),
              _buildInfoRow(Icons.work_outline, 'Cargo', cargo),
              _buildInfoRow(Icons.calendar_today_outlined, 'Fecha de ingreso', fechaIngreso),
              _buildInfoRow(Icons.attach_money_outlined, 'Salario', salario),
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
          Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

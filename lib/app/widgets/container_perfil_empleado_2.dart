import 'package:flutter/material.dart';

class ContainerPerfilEmpleadoDos extends StatelessWidget {
  final String nombre;
  final String rut;
  final String edad;
  final String cargo;
  final String fechaIngreso;
  final String salario;
  final String fichaPsicologica;

  const ContainerPerfilEmpleadoDos({
    super.key,
    required this.nombre,
    required this.rut,
    required this.edad,
    required this.cargo,
    required this.fechaIngreso,
    required this.salario,
    required this.fichaPsicologica,
  });

  @override
  Widget build(BuildContext context) {
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
          // Icono de perfil
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF2E7D32),
            child: Icon(Icons.person, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 12),

          // Nombre y RUT
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rut,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // Datos personales y laborales
          _buildInfoRow(Icons.badge_outlined, 'Edad', edad),
          _buildInfoRow(Icons.work_outline, 'Cargo', cargo),
          _buildInfoRow(Icons.calendar_today_outlined, 'Fecha de ingreso', fechaIngreso),
          _buildInfoRow(Icons.attach_money_outlined, 'Salario', salario),

          const SizedBox(height: 20),

          // Ficha psicológica
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Ficha Psicológica',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fichaPsicologica,
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  // --- Widget auxiliar para filas de información ---
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

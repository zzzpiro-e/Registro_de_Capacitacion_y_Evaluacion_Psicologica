import 'package:flutter/material.dart';

class ContainerDetalleTrabajador extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ContainerDetalleTrabajador({
    super.key,
    required this.datos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person_outline, color: Color(0xFF2E7D32), size: 24),
              SizedBox(width: 10),
              Text(
                'Datos del Trabajador',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDatoItem('Nombre Completo', datos['nombre'] ?? 'No especificado'),
          const SizedBox(height: 14),
          _buildDatoItem('RUT', datos['rut'] ?? 'No especificado'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildDatoItemWithIcon(Icons.business_center_outlined, 'Cargo', datos['cargo'] ?? 'Analista de Sistemas')),
              //Expanded(child: _buildDatoItemWithIcon(Icons.domain_outlined, 'Área', datos['area'] ?? 'Tecnología')), (No existe "Area" recordar eliminar este campo)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatoItem(String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(valor, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDatoItemWithIcon(IconData icono, String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 16, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 6),
            Text(etiqueta, style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 3),
        Text(valor, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
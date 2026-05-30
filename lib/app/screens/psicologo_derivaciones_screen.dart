import 'package:flutter/material.dart';
import 'psicologo_detalle_derivacion_screen.dart';

class PsicologoDerivacionesScreen extends StatefulWidget {
  const PsicologoDerivacionesScreen({super.key});

  @override
  State<PsicologoDerivacionesScreen> createState() => _PsicologoDerivacionesScreenState();
}

class _PsicologoDerivacionesScreenState extends State<PsicologoDerivacionesScreen> {
  // Mock Data Temporal
  final List<Map<String, dynamic>> derivaciones = [
    {'nombre': 'Carlos Rodríguez López', 'rut': '15.789.456-2', 'motivo': 'Estrés Laboral', 'estado': 'Pendiente', 'fecha': '18 Mayo 2026'},
    {'nombre': 'Ana Martínez Silva', 'rut': '18.234.567-1', 'motivo': 'Agotamiento', 'estado': 'En Proceso', 'fecha': '15 Mayo 2026'},
    {'nombre': 'Roberto Fernández', 'rut': '16.987.654-3', 'motivo': 'Conflicto de Equipo', 'estado': 'Completado', 'fecha': '10 Mayo 2026'},
  ];

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
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            width: double.infinity,
            child: const Text('Bandeja de Derivaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          const SizedBox(height: 10),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: derivaciones.length,
              itemBuilder: (context, index) {
                final derivacion = derivaciones[index];
                return InkWell(
                  onTap: () async {
                    final nuevoEstado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PsicologoDetalleDerivacionScreen(derivacion: derivacion),
                      ),
                    );
                    if (nuevoEstado != null && nuevoEstado is String && nuevoEstado != derivacion['estado']) {
                      setState(() {
                        derivaciones[index]['estado'] = nuevoEstado;
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(50)),
                          child: const Icon(Icons.person_outline, color: Color(0xFF2E7D32), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(derivacion['nombre'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text("Motivo: ${derivacion['motivo']}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                              const SizedBox(height: 4),
                              Text(derivacion['fecha'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: _colorEstado(derivacion['estado']), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            derivacion['estado'],
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _colorTextoEstado(derivacion['estado'])),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
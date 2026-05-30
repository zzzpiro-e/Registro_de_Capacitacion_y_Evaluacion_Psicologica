import 'package:flutter/material.dart';
import '../services/derivaciones_services.dart'; 
import 'psicologo_detalle_derivacion_screen.dart';

class PsicologoDerivacionesScreen extends StatefulWidget {
  const PsicologoDerivacionesScreen({super.key});

  @override
  State<PsicologoDerivacionesScreen> createState() => _PsicologoDerivacionesScreenState();
}

class _PsicologoDerivacionesScreenState extends State<PsicologoDerivacionesScreen> {
  // Apuntamos directo a la base de datos compartida del servicio
  final List<Map<String, dynamic>> _listaDerivaciones = DerivacionService.derivaciones;

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
              itemCount: _listaDerivaciones.length,
              itemBuilder: (context, index) {
                final derivacion = _listaDerivaciones[index];
                return InkWell(
                  onTap: () async {
                    // Esperamos el regreso de la pantalla de detalle
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PsicologoDetalleDerivacionScreen(derivacion: derivacion),
                      ),
                    );
                    
                    // Al volver, forzamos refresco local por si mutó el estado interno del objeto
                    setState(() {});
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
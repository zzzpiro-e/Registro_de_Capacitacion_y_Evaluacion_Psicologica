import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContainerPerfilEmpleadoTres extends StatelessWidget {
  final String empleadoId;

  const ContainerPerfilEmpleadoTres({super.key, required this.empleadoId});

  String _formatearFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha.toDate());
    }
    return fecha?.toString() ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('empleados')
          .doc(empleadoId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Sin datos de perfil psicológico.'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final bool esDerivado = data['derivado'] ?? false;
        final estado = data['estado'] ?? 'Sin estado';
        final derivacionFecha = data['derivacionFecha'];
        final List informes = data['informes'] ?? [];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perfil Psicológico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),

              if (esDerivado) ...[
                Row(
                  children: [
                    const Icon(Icons.assignment_ind, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Text('Estado: $estado', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF2E7D32), size: 18),
                    const SizedBox(width: 8),
                    Text('Derivado el: ${_formatearFecha(derivacionFecha)}'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.attach_file, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Text('Informes adjuntos: ${informes.length}'),
                  ],
                ),
              ] else ...[
                const Text(
                  'Este empleado aún no tiene informes psicológicos registrados.',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Historial de Informes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              informes.isEmpty
                  ? const Text(
                      'No se registran informes cargados.',
                      style: TextStyle(color: Colors.black54),
                    )
                  : Column(
                      children: informes.map((inf) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(inf['nombre_archivo'] ?? 'PDF', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('Subido: ${inf['fecha_subida'] ?? 'N/A'}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final controller = TextEditingController();
                    final email = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Derivar al psicólogo'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Correo del psicólogo',
                              hintText: 'ej: psicologo@empresa.cl',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, controller.text.trim()),
                              child: const Text('Derivar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (email != null && email.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('empleados')
                          .doc(empleadoId)
                          .update({
                        'derivado': true,
                        'psicologoEmail': email,
                        'derivacionFecha': Timestamp.now(),
                        'estado': 'Pendiente',
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Empleado derivado al psicólogo: $email'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Derivar al psicólogo', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
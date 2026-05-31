import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerCrearCapacitacionDos extends StatefulWidget {
  const ContainerCrearCapacitacionDos({super.key});

  @override
  State<ContainerCrearCapacitacionDos> createState() =>
      _ContainerCrearCapacitacionDosState();
}

class _ContainerCrearCapacitacionDosState
    extends State<ContainerCrearCapacitacionDos> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _institucionController = TextEditingController();
  final _empleadosAsignadosController = TextEditingController();
  final _tipoController = TextEditingController();

  bool _asignarATodos = false;

  Future<void> _guardarCapacitacion() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      List<String> empleadosAsignados = [];

      if (_asignarATodos) {
        final empleadosSnapshot = await FirebaseFirestore.instance
            .collection('empleados')
            .get();

        empleadosAsignados = empleadosSnapshot.docs
            .map((doc) => doc.id)
            .toList();
      } else {
        final rutIngresado = _empleadosAsignadosController.text.trim();

        final empleadoDoc = await FirebaseFirestore.instance
            .collection('empleados')
            .doc(rutIngresado)
            .get();

        if (!empleadoDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El RUT ingresado no existe en la base de datos'),
            ),
          );
          return;
        }

        empleadosAsignados.add(rutIngresado);
      }

      final titulo = _tituloController.text.trim();

      await FirebaseFirestore.instance
          .collection('capacitaciones')
          .doc(titulo)
          .set({
            'titulo': titulo,
            'descripcion': _descripcionController.text.trim(),
            'institucion': _institucionController.text.trim(),

            'empleadosAsignados': empleadosAsignados,

            'empleadosRealizaron': <String>[],

            'tipo': _tipoController.text.trim(),

            'estado': 'pendiente',

            'fechaInicio': Timestamp.now(),
            'fechaFin': Timestamp.now(),
            'fechaRegistro': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capacitación guardada correctamente')),
      );

      _tituloController.clear();
      _descripcionController.clear();
      _institucionController.clear();
      _empleadosAsignadosController.clear();
      _tipoController.clear();

      setState(() {
        _asignarATodos = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _institucionController.dispose();
    _empleadosAsignadosController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Título ---
            const Text('Título', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                hintText: 'Ej: Extinción de Fuegos',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el título';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // --- Descripción ---
            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Descripción de la capacitación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese la descripción';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // --- Institución ---
            const Text(
              'Institución',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _institucionController,
              decoration: const InputDecoration(
                hintText: 'Mutual de Seguridad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese la institución';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // --- Asignación ---
            const Text(
              'Asignación',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                value: _asignarATodos,
                title: const Text('Asignar a todos los empleados'),
                activeColor: const Color(0xFF2E7D32),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    _asignarATodos = value ?? false;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            if (!_asignarATodos) ...[
              const Text(
                'RUT del empleado',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _empleadosAsignadosController,
                decoration: const InputDecoration(
                  hintText: '107553967',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (!_asignarATodos &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Ingrese un RUT';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 20),

            // --- Tipo ---
            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tipoController,
              decoration: const InputDecoration(
                hintText: 'Ej: seguridad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el tipo';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            // --- Botón Guardar ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardarCapacitacion,
                icon: const Icon(Icons.save_alt, color: Colors.white),
                label: const Text(
                  'Guardar Capacitación',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

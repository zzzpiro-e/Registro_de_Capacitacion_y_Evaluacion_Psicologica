import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ContainerPerfilEmpleadoDos extends StatelessWidget {
  final String empleadoId;
  final Color verdePrincipal = const Color(0xFF2E7D32);

  const ContainerPerfilEmpleadoDos({super.key, required this.empleadoId});

  // --- Formateador de miles para el Salario ---
  String _formatearMiles(String texto) {
    String limpio = texto.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.isEmpty) return '';
    final numero = int.parse(limpio);
    final formato = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '',
      decimalDigits: 0,
    );
    return formato.format(numero);
  }

  // --- Estética unificada ---
  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: verdePrincipal, width: 2),
    ),
  );

  Future<void> _editarEmpleado(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final edadActual = int.tryParse(data['edad']?.toString() ?? '0') ?? 0;

    final edadController = TextEditingController(
      text: data['edad']?.toString() ?? '',
    );
    final cargoController = TextEditingController(
      text: data['cargo']?.toString() ?? '',
    );
    final salarioController = TextEditingController(
      text: data['salario']?.toString() ?? '',
    );

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Editar empleado',
            style: TextStyle(
              color: verdePrincipal,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: edadController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Edad'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: cargoController,
                    decoration: _inputDecoration('Cargo'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: salarioController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final valorFormateado = _formatearMiles(value);
                      salarioController.value = TextEditingValue(
                        text: valorFormateado,
                        selection: TextSelection.collapsed(
                          offset: valorFormateado.length,
                        ),
                      );
                    },
                    decoration: _inputDecoration('Salario'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: verdePrincipal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final edadTexto = edadController.text.trim();
                final cargoTexto = cargoController.text.trim();
                final salarioTexto = salarioController.text.trim();

                if (edadTexto.isEmpty ||
                    cargoTexto.isEmpty ||
                    salarioTexto.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los campos son obligatorios'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final edadNueva = int.tryParse(edadTexto);
                if (edadNueva == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La edad debe ser numérica'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (edadNueva < edadActual) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'La edad no puede ser menor a $edadActual años',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (edadNueva > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La edad no puede superar los 100 años'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (cargoTexto.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'El cargo debe tener al menos 3 caracteres',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Guardar manteniendo los puntos (formato String)
                await FirebaseFirestore.instance
                    .collection('empleados')
                    .doc(empleadoId)
                    .update({
                      'edad': edadNueva,
                      'cargo': cargoTexto,
                      'salario': salarioTexto,
                    });

                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empleado actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
        final rut = data['rut'] ?? 'Información no ingresada';
        final edad = data['edad'] != null
            ? data['edad'].toString()
            : 'Información no ingresada';
        final cargo = data['cargo']?.toString() ?? 'Información no ingresada';

        String fechaIngreso = 'Información no ingresada';
        if (data['fechaIngreso'] != null && data['fechaIngreso'] is Timestamp) {
          final timestamp = data['fechaIngreso'] as Timestamp;
          fechaIngreso = DateFormat('dd/MM/yyyy').format(timestamp.toDate());
        }

        final salario =
            data['salario']?.toString() ?? 'Información no ingresada';

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
                  onPressed: () => _editarEmpleado(context, data),
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
              Text(
                rut,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
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

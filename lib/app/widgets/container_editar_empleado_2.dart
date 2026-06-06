import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_flutter/app/utils/date_time_input_formatter.dart';


class ContainerEditarEmpleadoDos extends StatefulWidget {
  final String empleadoId;

  const ContainerEditarEmpleadoDos({super.key, required this.empleadoId});

  @override
  State<ContainerEditarEmpleadoDos> createState() => _EditarEmpleadoDosState();
}

class _EditarEmpleadoDosState extends State<ContainerEditarEmpleadoDos> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _rutController = TextEditingController();
  final _salarioController = TextEditingController();
  final _edadController = TextEditingController();
  final _fechaIngresoController = TextEditingController();
  final _cargoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _rutController.dispose();
    _salarioController.dispose();
    _edadController.dispose();
    _fechaIngresoController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final doc = await FirebaseFirestore.instance
        .collection('empleados')
        .doc(widget.empleadoId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nombreController.text = data['nombres'] ?? '';
        _apellidoController.text = data['apellidos'] ?? '';
        _rutController.text = data['rut'] ?? '';
        _edadController.text = data['edad']?.toString() ?? '';
        _cargoController.text = data['cargo'] ?? '';

        if (data['fechaIngreso'] != null) {
          if (data['fechaIngreso'] is Timestamp) {
            final ts = data['fechaIngreso'] as Timestamp;
            _fechaIngresoController.text =
                DateFormat('dd/MM/yyyy').format(ts.toDate());
          } else {
            _fechaIngresoController.text = data['fechaIngreso'].toString();
          }
        }

        if (data['salario'] != null) {
          final numero = data['salario'] is int
              ? data['salario']
              : int.tryParse(data['salario'].toString()) ?? 0;
          _salarioController.text =
              '\$${NumberFormat.decimalPattern('es_CL').format(numero)}';
        }
      });
    }
  }

  String _formatearMiles(String valor) {
    if (valor.isEmpty) return '';
    final numero = int.tryParse(valor.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numero == null) return valor;
    return '\$${NumberFormat.decimalPattern('es_CL').format(numero)}';
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final salarioLimpio = int.tryParse(
          _salarioController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ?? 0;

    final edadLimpia = int.tryParse(_edadController.text) ?? 0;

    // Conversión de string dd/MM/yyyy a Timestamp para mantener consistencia en Firestore
    dynamic fechaParaGuardar = _fechaIngresoController.text.trim();
    try {
      final fechaParseada = DateFormat('dd/MM/yyyy').parse(fechaParaGuardar);
      fechaParaGuardar = Timestamp.fromDate(fechaParseada);
    } catch (_) {
      // Si falla el parseo, se guarda temporalmente como String original
    }

    await FirebaseFirestore.instance
        .collection('empleados')
        .doc(widget.empleadoId)
        .update({
      'nombres': _nombreController.text.trim(),
      'apellidos': _apellidoController.text.trim(),
      'rut': _rutController.text.trim(),
      'salario': salarioLimpio,
      'edad': edadLimpia,
      'cargo': _cargoController.text.trim(),
      'fechaIngreso': fechaParaGuardar,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado actualizado correctamente')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _eliminarEmpleado() async {
    await FirebaseFirestore.instance
        .collection('empleados')
        .doc(widget.empleadoId)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado eliminado')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nombres'),
              TextFormField(
                controller: _nombreController,
                decoration: _inputDecoration('Ej: Juan Carlos'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Ingrese los nombres'
                    : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Apellidos'),
              TextFormField(
                controller: _apellidoController,
                decoration: _inputDecoration('Ej: Pérez González'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Ingrese los apellidos'
                    : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('RUT'),
              TextFormField(
                controller: _rutController,
                readOnly: true,
                decoration: _inputDecoration('RUT'),
              ),
              const SizedBox(height: 20),

              _buildLabel('Edad'),
              TextFormField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('Ej: 35'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese la edad' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Cargo'),
              TextFormField(
                controller: _cargoController,
                decoration: _inputDecoration('Ej: Analista de RRHH'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese el cargo' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Fecha de Ingreso'),
              TextFormField(
                controller: _fechaIngresoController,
                keyboardType: TextInputType.number,
                inputFormatters: [DateTimeInputFormatter()], // 🔹 usa tu formatter de utils
                decoration: _inputDecoration('Ej: 2026-05-29/17:50'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingrese la fecha';
                  // Validar formato básico yyyy-MM-dd/HH:mm
                  final regExp = RegExp(r'^\d{4}-\d{2}-\d{2}/\d{2}:\d{2}$');
                  if (!regExp.hasMatch(v)) return 'Formato inválido (yyyy-MM-dd/HH:mm)';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Salario (CLP)'),
              TextFormField(
                controller: _salarioController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final formateado = _formatearMiles(value);
                  _salarioController.value = TextEditingValue(
                    text: formateado,
                    selection: TextSelection.collapsed(
                        offset: formateado.length),
                  );
                },
                decoration: _inputDecoration('\$1.500.000'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese el salario' : null,
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _guardarCambios,
                      icon: const Icon(Icons.save_alt, color: Colors.white),
                      label: const Text(
                        'Guardar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _eliminarEmpleado,
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    'Eliminar Empleado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
        ],
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2E7D32)),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}
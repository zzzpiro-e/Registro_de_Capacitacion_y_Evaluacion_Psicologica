import 'dart:async'; // 🔹 Agregado para capturar TimeoutException
import 'package:flutter/foundation.dart'; // 🔹 Agregado para usar debugPrint
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_flutter/app/utils/date_time_input_formatter.dart';
import 'package:proyecto_flutter/app/services/auditoria_service.dart';

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

  Map<String, dynamic> _valoresOriginales = {};
  bool _isLoading = false; // 🔹 Bloquea campos y botones en transiciones de red

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

  // Valida que el texto traiga obligatoriamente al menos dos palabras válidas
  bool _validarFormatoDosPalabras(String value) {
    final texto = value.trim();
    final soloLetras = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(texto);
    if (!soloLetras) return false;

    final palabras = texto.split(RegExp(r'\s+'));
    if (palabras.length < 2) return false;
    
    for (var palabra in palabras) {
      if (palabra.length < 2) return false;
    }
    return true;
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      // 🔹 Timeout para que no se quede colgado indefinidamente si no hay internet al abrir
      final doc = await FirebaseFirestore.instance
          .collection('empleados')
          .doc(widget.empleadoId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists && mounted) {
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
                  DateFormat('yyyy-MM-dd/HH:mm').format(ts.toDate());
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

          _valoresOriginales = {
            'nombres': _nombreController.text,
            'apellidos': _apellidoController.text,
            'rut': _rutController.text,
            'edad': _edadController.text,
            'cargo': _cargoController.text,
            'fechaIngreso': _fechaIngresoController.text,
            'salario': _salarioController.text,
          };
        });
      }
    } on TimeoutException catch (_) {
      _mostrarMensajeErrorRed('No se pudieron cargar los datos del empleado. Tiempo de espera agotado.');
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
      _mostrarMensajeErrorRed('Error de red al intentar conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatearMiles(String valor) {
    if (valor.isEmpty) return '';
    final numero = int.tryParse(valor.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numero == null) return valor;
    return '\$${NumberFormat.decimalPattern('es_CL').format(numero)}';
  }

  void _mostrarMensajeErrorRed(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    final salarioLimpio = int.tryParse(
          _salarioController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ?? 0;

    final edadLimpia = int.tryParse(_edadController.text) ?? 0;

    dynamic fechaParaGuardar = _fechaIngresoController.text.trim();
    try {
      final fechaParseada = DateFormat('yyyy-MM-dd/HH:mm').parse(fechaParaGuardar);
      fechaParaGuardar = Timestamp.fromDate(fechaParseada);
    } catch (_) {}

    try {
      // 🔹 Se le asigna un timeout de 10 segundos para mitigar problemas en Edge
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
      }).timeout(const Duration(seconds: 10));

      // 📝 REGISTRAR EN AUDITORÍA
      Map<String, dynamic> camposAntes = {};
      Map<String, dynamic> camposDespues = {};
      List<String> camposEditados = [];
      
      void check(String key, String oldVal, String newVal) {
        if (oldVal != newVal) {
          camposAntes[key] = oldVal;
          camposDespues[key] = newVal;
          camposEditados.add(key);
        }
      }
      
      check('nombres', _valoresOriginales['nombres'], _nombreController.text.trim());
      check('apellidos', _valoresOriginales['apellidos'], _apellidoController.text.trim());
      check('edad', _valoresOriginales['edad'], _edadController.text.trim());
      check('cargo', _valoresOriginales['cargo'], _cargoController.text.trim());
      check('fechaIngreso', _valoresOriginales['fechaIngreso'], _fechaIngresoController.text.trim());
      check('salario', _valoresOriginales['salario'], _salarioController.text.trim());
      
      if (camposEditados.isNotEmpty) {
        final nombreCompleto = "${_nombreController.text.trim()} ${_apellidoController.text.trim()}";
        await AuditoriaService.rrhhEditoEmpleado(
          nombre: nombreCompleto,
          campos: camposEditados,
          camposAntes: camposAntes,
          camposDespues: camposDespues,
        ).timeout(const Duration(seconds: 5));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('Empleado actualizado correctamente')),
        );
        Navigator.pop(context);
      }

    } on TimeoutException catch (_) {
      _mostrarMensajeErrorRed('No se pudo guardar los cambios. Tiempo de espera agotado (Sin respuesta del servidor).');
    } on FirebaseException catch (fe) {
      debugPrint('Error de Firebase: ${fe.code}');
      _mostrarMensajeErrorRed('Fallo de base de datos. Código: ${fe.code}');
    } catch (e) {
      debugPrint('Error desconocido al actualizar: $e');
      _mostrarMensajeErrorRed('Ocurrió un error inesperado de red al procesar la actualización.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarEmpleado() async {
    if (_isLoading) return;

    // Diálogo de confirmación antes de borrar directamente
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Empleado?'),
        content: const Text('Esta acción quitará al trabajador de forma permanente del sistema.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('empleados')
          .doc(widget.empleadoId)
          .delete()
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.redAccent, content: Text('Empleado eliminado')),
        );
        Navigator.pop(context);
      }
    } on TimeoutException catch (_) {
      _mostrarMensajeErrorRed('No se pudo eliminar al empleado. El servidor no responde.');
    } catch (e) {
      debugPrint('Error al eliminar: $e');
      _mostrarMensajeErrorRed('Error de conexión de red al intentar eliminar.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nombres'),
              TextFormField(
                controller: _nombreController,
                enabled: !_isLoading,
                decoration: _inputDecoration('Ej: Juan Carlos'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese los nombres';
                  if (RegExp(r'[0-9]').hasMatch(v)) return 'No se permiten números en los nombres';
                  if (!_validarFormatoDosPalabras(v)) return 'Ingrese al menos dos nombres válidos';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Apellidos'),
              TextFormField(
                controller: _apellidoController,
                enabled: !_isLoading,
                decoration: _inputDecoration('Ej: Pérez González'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese los apellidos';
                  if (RegExp(r'[0-9]').hasMatch(v)) return 'No se permiten números en los apellidos';
                  if (!_validarFormatoDosPalabras(v)) return 'Ingrese los dos apellidos completos';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('RUT'),
              TextFormField(
                controller: _rutController,
                readOnly: true, // El rut actúa como ID único immutable
                style: const TextStyle(color: Colors.grey),
                decoration: _inputDecoration('RUT'),
              ),
              const SizedBox(height: 20),

              _buildLabel('Edad'),
              TextFormField(
                controller: _edadController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('Ej: 35'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese la edad';
                  final numero = int.tryParse(v) ?? 0;
                  if (numero < 18 || numero > 100) return 'La edad debe estar entre 18 y 100 años';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Cargo'),
              TextFormField(
                controller: _cargoController,
                enabled: !_isLoading,
                decoration: _inputDecoration('Ej: Analista de RRHH'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingrese el cargo' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Fecha de Ingreso'),
              TextFormField(
                controller: _fechaIngresoController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                inputFormatters: [DateTimeInputFormatter()],
                decoration: _inputDecoration('Ej: 2026-05-29/17:50'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingrese la fecha';
                  final regExp = RegExp(r'^\d{4}-\d{2}-\d{2}/\d{2}:\d{2}$');
                  if (!regExp.hasMatch(v)) return 'Formato inválido (yyyy-MM-dd/HH:mm)';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Salario (CLP)'),
              TextFormField(
                controller: _salarioController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final formateado = _formatearMiles(value);
                  _salarioController.value = TextEditingValue(
                    text: formateado,
                    selection: TextSelection.collapsed(offset: formateado.length),
                  );
                },
                decoration: _inputDecoration('\$1.500.000'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingrese el salario';
                  final limpio = v.replaceAll(RegExp(r'[^0-9]'), '');
                  if (limpio.isEmpty) return 'Ingrese el salario';

                  final numero = int.tryParse(limpio) ?? 0;
                  if (numero < 400000) return 'Debe ser igual o superior al sueldo mínimo (\$400.000)';
                  if (numero > 20000000) return 'El salario no puede superar los \$20.000.000';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                ),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _guardarCambios,
                      icon: const Icon(Icons.save_alt, color: Colors.white),
                      label: const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel, color: Colors.black54),
                      label: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _eliminarEmpleado,
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    'Eliminar Empleado',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
}
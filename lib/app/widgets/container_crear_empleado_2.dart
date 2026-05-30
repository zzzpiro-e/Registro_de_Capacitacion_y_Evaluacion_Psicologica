import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ContainerCrearEmpleadoDos extends StatefulWidget {
  const ContainerCrearEmpleadoDos({super.key});

  @override
  State<ContainerCrearEmpleadoDos> createState() => _ContainerCrearEmpleadoDosState();
}

class _ContainerCrearEmpleadoDosState extends State<ContainerCrearEmpleadoDos> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _rutController = TextEditingController();
  final _salarioController = TextEditingController();
  final _fichaController = TextEditingController();

  // --- Validación del RUT ---
  bool validarRut(String rut) {
    rut = rut.replaceAll('.', '').replaceAll('-', '');
    if (rut.length < 2) return false;

    String dvIngresado = rut.substring(rut.length - 1).toUpperCase();
    String cuerpo = rut.substring(0, rut.length - 1);

    int suma = 0;
    int factor = 2;

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      suma += int.parse(cuerpo[i]) * factor;
      factor = (factor == 7) ? 2 : factor + 1;
    }

    int resto = 11 - (suma % 11);
    String dvCalculado;
    if (resto == 11) {
      dvCalculado = "0";
    } else if (resto == 10) {
      dvCalculado = "K";
    } else {
      dvCalculado = resto.toString();
    }

    return dvIngresado == dvCalculado;
  }
  // --- Formateo automático del RUT ---
  void _formatearRut(String value) {
    String limpio = value.replaceAll(RegExp(r'[^0-9kK]'), '');
    if (limpio.isEmpty) {
      _rutController.text = '';
      return;
    }

    // separar cuerpo y dígito verificador
    String cuerpo = limpio.length > 1 ? limpio.substring(0, limpio.length - 1) : limpio;
    String dv = limpio.length > 1 ? limpio.substring(limpio.length - 1) : '';

    // agregar puntos cada 3 dígitos desde el final
    final buffer = StringBuffer();
    int contador = 0;
    for (int i = cuerpo.length - 1; i >= 0; i--) {
      buffer.write(cuerpo[i]);
      contador++;
      if (contador == 3 && i != 0) {
        buffer.write('.');
        contador = 0;
      }
    }
    String cuerpoFormateado = buffer.toString().split('').reversed.join('');
    String rutFormateado = dv.isNotEmpty ? '$cuerpoFormateado-$dv' : cuerpoFormateado;

    _rutController.value = TextEditingValue(
      text: rutFormateado,
      selection: TextSelection.collapsed(offset: rutFormateado.length),
    );
  }

  // --- Formateo automático del salario ---
  void _formatearSalario(String value) {
    String limpio = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.isEmpty) {
      _salarioController.text = '';
      return;
    }

    final numero = int.parse(limpio);
    final formateado = '\$${_formatearMiles(numero)}';
    _salarioController.value = TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }

  String _formatearMiles(int numero) {
    final str = numero.toString();
    final buffer = StringBuffer();
    int contador = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      contador++;
      if (contador == 3 && i != 0) {
        buffer.write('.');
        contador = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  // --- Guardar empleado en Firestore ---
  Future<void> _guardarEmpleado() async {
    if (!_formKey.currentState!.validate()) return;

    final rutLimpio = _rutController.text.replaceAll('.', '').replaceAll('-', '');
    final fechaIngreso = DateFormat('yyyy-MM-dd/HH:mm').format(DateTime.now());

    // ✅ Verificar si ya existe un empleado con ese RUT
    final docRef = FirebaseFirestore.instance.collection('empleados').doc(rutLimpio);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Mostrar aviso si el RUT ya está registrado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este RUT ya ha sido registrado')),
      );
      return; // detener la ejecución
    }

    // Si no existe, crear el nuevo empleado
    final empleado = {
      'nombres': _nombreController.text.trim(),
      'apellidos': _apellidoController.text.trim(),
      'rut': _rutController.text.trim(),
      'salario': _salarioController.text.trim(),
      'fichaPsicologica': 'No tiene permiso para adjuntar informes psicológicos',
      'fechaIngreso': fechaIngreso,
      'estado': 'activo',
    };

    await docRef.set(empleado);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Empleado guardado correctamente')),
    );

    _formKey.currentState!.reset();
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
            // --- Nombres ---
            const Text('Nombres', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                hintText: 'Ej: Juan Carlos',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese los nombres';
                }
                if (RegExp(r'[0-9]').hasMatch(value)) {
                  return 'No se permiten números en los nombres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // --- Apellidos ---
            const Text('Apellidos', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                hintText: 'Ej: Pérez González',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese los apellidos';
                }
                if (RegExp(r'[0-9]').hasMatch(value)) {
                  return 'No se permiten números en los apellidos';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // --- RUT ---
            const Text('RUT', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _rutController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9kK]')), // ✅ solo números y K/k
                LengthLimitingTextInputFormatter(9), // ✅ máximo 9 caracteres
              ],
              decoration: const InputDecoration(
                hintText: '12.345.678-9',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              onChanged: _formatearRut, // ✅ formateo automático
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingrese el RUT';

                final limpio = value.replaceAll('.', '').replaceAll('-', '');
                if (limpio.length < 8 || limpio.length > 9) {
                  return 'El RUT debe tener entre 8 y 9 dígitos';
                }

                if (!RegExp(r'^[0-9kK.-]+$').hasMatch(value)) {
                  return 'El RUT solo puede contener números y la letra K';
                }
                if (!validarRut(value)) return 'RUT inválido';
                return null;
              },
            ),
            const SizedBox(height: 20),





            // --- Salario ---
            const Text('Salario (CLP)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _salarioController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '\$1.500.000',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              onChanged: _formatearSalario,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el salario';
                }
                final limpio = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (limpio.isEmpty) return 'Ingrese el salario';

                final numero = int.tryParse(limpio) ?? 0;
                if (numero <= 0) {
                  return 'El salario debe ser mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // --- Ficha Psicológica ---
            const Text('Ficha Psicológica', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _fichaController,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'No tiene permiso para adjuntar informes psicológicos',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 30),

            // --- Botón Guardar ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardarEmpleado,
                icon: const Icon(Icons.save_alt, color: Colors.white),
                label: const Text(
                  'Guardar Empleado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/app/widgets/widgets_crear_empleado.dart';
import 'package:proyecto_flutter/app/utils/date_input_formatter.dart';
class ContainerCrearEmpleadoDos extends StatefulWidget {
  const ContainerCrearEmpleadoDos({super.key});

  @override
  State<ContainerCrearEmpleadoDos> createState() =>
      _ContainerCrearEmpleadoDosState();
}

class _ContainerCrearEmpleadoDosState extends State<ContainerCrearEmpleadoDos> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _rutController = TextEditingController();
  final _salarioController = TextEditingController();
  final _cargoController = TextEditingController();
  final _edadController = TextEditingController();
  final _fechaIngresoController = TextEditingController();

  @override
  void dispose() {
    // 💡 Liberamos los controladores para evitar fugas de memoria
    _nombreController.dispose();
    _apellidoController.dispose();
    _rutController.dispose();
    _salarioController.dispose();
    _cargoController.dispose();
    _edadController.dispose();
    _fechaIngresoController.dispose();
    super.dispose();
  }

  // --- Validación del RUT ---
  bool validarRut(String rut) {
    rut = rut.replaceAll('.', '').replaceAll('-', '');
    if (rut.length < 2) return false;

    String dvIngresado = rut.substring(rut.length - 1).toUpperCase();
    String cuerpo = rut.substring(0, rut.length - 1);

    int suma = 0;
    int factor = 2;

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      try {
        suma += int.parse(cuerpo[i]) * factor;
      } catch (e) {
        return false; // Por si se coló algún caracter no numérico en el cuerpo
      }
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

    String cuerpo = limpio.length > 1
        ? limpio.substring(0, limpio.length - 1)
        : limpio;
    String dv = limpio.length > 1 ? limpio.substring(limpio.length - 1) : '';

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
    String rutFormateado = dv.isNotEmpty
        ? '$cuerpoFormateado-$dv'
        : cuerpoFormateado;

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

    final rutLimpio = _rutController.text.replaceAll('.', '').replaceAll('-', '').toUpperCase();
    final fechaIngreso = _fechaIngresoController.text.trim();
    final edadLimpia = int.tryParse(_edadController.text) ?? 0;
    try {
      final docRef = FirebaseFirestore.instance
          .collection('empleados')
          .doc(rutLimpio);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este RUT ya ha sido registrado')),
        );
        return;
      }

      final empleado = {
        'nombres': _nombreController.text.trim(),
        'apellidos': _apellidoController.text.trim(),
        'rut': _rutController.text
            .trim()
            .toUpperCase(), // Guardar siempre la K en mayúscula
        'cargo': _cargoController.text.trim(),
        'salario':
            int.tryParse(
              _salarioController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        'edad': edadLimpia,
        'fechaIngreso': fechaIngreso,
        'estado': 'activo',
      };

      await docRef.set(empleado);
    
      if (!mounted) return;

      context
          .read<EmpleadosProvider>()
          .notificarNuevoEmpleado();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empleado guardado correctamente'),
        ),
      );

          _formKey.currentState!.reset();
          _nombreController.clear();
          _apellidoController.clear();
          _rutController.clear();
          _cargoController.clear();
          _salarioController.clear();
          _edadController.clear();
          _fechaIngresoController.clear();
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Nombres ---
              const Text(
                'Nombres',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nombreController,
                inputFormatters: [
                  // Bloquea cualquier dígito del 0 al 9
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(30),
                ],
                decoration: const InputDecoration(
                  hintText: 'Ej: Juan Carlos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese los nombres';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Apellidos ---
              const Text(
                'Apellidos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _apellidoController,
                inputFormatters: [
                  // Bloquea cualquier dígito del 0 al 9
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(40),
                ],
                decoration: const InputDecoration(
                  hintText: 'Ej: Pérez González',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese los apellidos';
                  }
                  if (value.trim().length < 2) {
                    return 'El apellido debe tener al menos 2 caracteres';
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
                keyboardType: TextInputType
                    .text, // 🛠️ CORREGIDO: Permite que aparezca la letra 'K' en teclados móviles
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9kK]')),
                  LengthLimitingTextInputFormatter(
                    9,
                  ), // Máximo 9 caracteres sin contar puntos/guiones que agrega el formato
                ],
                decoration: const InputDecoration(
                  hintText: '12.345.678-9',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: _formatearRut,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese el RUT';
                  final limpio = value.replaceAll('.', '').replaceAll('-', '');
                  if (limpio.length < 8 || limpio.length > 9) {
                    return 'El RUT debe tener entre 8 y 9 dígitos';
                  }
                  if (!validarRut(value)) return 'RUT inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Edad ---
              const Text('Edad', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2), // 🔹 Límite de 2 dígitos
                ],
                decoration: const InputDecoration(
                  hintText: 'Ej: 35',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la edad';
                  }
                  final numero = int.tryParse(value);
                  if (numero == null) return 'Ingrese una edad válida';
                  if (numero < 18) return 'La edad mínima requerida es 18 años';
                  if (numero > 75) return 'La edad máxima permitida es 75 años';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Cargo ---
              const Text(
                'Cargo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cargoController,
                inputFormatters: [
                  // Solo permite letras, espacios y algunos caracteres especiales comunes (como guiones o barras)
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-]')),
                  LengthLimitingTextInputFormatter(50), 
                ],
                decoration: const InputDecoration(
                  hintText: 'Ej: Analista de Compensaciones',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el cargo';
                  }
                  // Validación adicional por si el usuario logra saltar el inputFormatter
                  if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'El cargo no puede contener números';
                  }
                  if (value.trim().length < 3) {
                    return 'El cargo es muy corto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('Fecha de Ingreso', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fechaIngresoController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  DateInputFormatter(),
                ],
                decoration: const InputDecoration(
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  labelText: 'Fecha de Ingreso',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.length != 10) return 'Formato: DD/MM/YYYY';

                  final partes = value.split('/');
                  final dia = int.tryParse(partes[0]) ?? 0;
                  final mes = int.tryParse(partes[1]) ?? 0;
                  final anio = int.tryParse(partes[2]) ?? 0;

                  // Validación de rango de años (1900 - 2100)
                  if (anio < 1950 || anio > 2026) return 'Año fuera de rango (1950-2026)';
                  
                  // Validación de Mes
                  if (mes < 1 || mes > 12) return 'Mes inválido';

                  // Validación de Días por Mes
                  final diasEnMes = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
                  
                  // Ajuste por año bisiesto
                  bool esBisiesto = (anio % 4 == 0 && anio % 100 != 0) || (anio % 400 == 0);
                  if (esBisiesto) diasEnMes[2] = 29;

                  if (dia < 1 || dia > diasEnMes[mes]) return 'Día inválido para el mes seleccionado';

                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Salario ---
              const Text(
                'Salario (CLP)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _salarioController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                ],
                decoration: const InputDecoration(
                  hintText: '\$539.000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: _formatearSalario,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese el salario';
                  
                  final limpio = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (limpio.isEmpty) return 'Ingrese el salario';

                  final numero = int.tryParse(limpio) ?? 0;
                  const int sueldoMinimo = 539000;
                  const int sueldoMaximo = 2500000;

                  if (numero < sueldoMinimo) return 'El salario debe ser al menos \$539.000';
                  if (numero > sueldoMaximo) return 'El salario supera el límite permitido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

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
      ),
    );
  }
}

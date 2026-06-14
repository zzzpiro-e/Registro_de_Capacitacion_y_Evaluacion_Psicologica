import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/app/widgets/widgets_crear_empleado.dart';

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
  final _cargoController = TextEditingController();
  final _edadController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _rutController.dispose();
    _salarioController.dispose();
    _cargoController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  // ==========================================
  // VALIDADORES DE ESTRUCTURA DE TEXTO
  // ==========================================
  
  /// Valida que el texto contenga solo letras y espacios, y que obligatoriamente
  /// posea al menos DOS palabras/bloques (ej: "Juan Carlos" o "Pérez Gómez").
  bool _validarFormatoDosPalabras(String value) {
    final texto = value.trim();
    
    // 1. Validar que no contenga números ni símbolos raros
    final soloLetras = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(texto);
    if (!soloLetras) return false;

    // 2. Separar por espacios eliminando espacios dobles intermedios
    final palabras = texto.split(RegExp(r'\s+'));
    
    // Exigir al menos 2 palabras y que cada una tenga mínimo 2 letras (ej: "Ab")
    if (palabras.length < 2) return false;
    
    // Verifica que ninguna de las palabras sea un caracter suelto o vacío
    for (var palabra in palabras) {
      if (palabra.length < 2) return false;
    }

    return true;
  }

  /// Valida que el cargo tenga sentido (letras, espacios, números permitidos, mínimo 3 caracteres)
  bool _validarCargoCoherente(String value) {
    final texto = value.trim();
    final tieneLetras = RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ]').hasMatch(texto);
    final caracteresValidos = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s.\-/()]+$').hasMatch(texto);
    return tieneLetras && caracteresValidos && texto.length >= 3;
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
        return false; 
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

    String cuerpo = limpio.length > 1 ? limpio.substring(0, limpio.length - 1) : limpio;
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

    final rutLimpio = _rutController.text.replaceAll('.', '').replaceAll('-', '').toUpperCase();
    final fechaIngreso = DateFormat('yyyy-MM-dd/HH:mm').format(DateTime.now());
    final edadLimpia = int.tryParse(_edadController.text) ?? 0;

    try {
      final docRef = FirebaseFirestore.instance.collection('empleados').doc(rutLimpio);
      final docSnapshot = await docRef.get().timeout(const Duration(seconds: 7));

      if (docSnapshot.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este RUT ya ha sido registrado previamente')),
        );
        return;
      }

      final empleado = {
        'nombres': _nombreController.text.trim(),
        'apellidos': _apellidoController.text.trim(),
        'rut': _rutController.text.trim().toUpperCase(),
        'cargo': _cargoController.text.trim(),
        'salario': int.tryParse(
          _salarioController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ?? 0,
        'edad': edadLimpia,
        'fechaIngreso': fechaIngreso,
        'estado': 'activo',
      };

      await docRef.set(empleado).timeout(const Duration(seconds: 7));

      if (!mounted) return;

      context.read<EmpleadosProvider>().notificarNuevoEmpleado();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
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
      
    } on FirebaseException catch (fe) {
      if (!mounted) return;
      String mensajeError = 'No se pudo conectar con el servidor. Revisa tu conexión a internet.';
      if (fe.code == 'permission-denied') {
        mensajeError = 'No tienes permisos necesarios para realizar esta operación.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(mensajeError)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Error inesperado al guardar. Por favor, intente más tarde.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Nombres ---
              const Text('Nombres', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nombreController,
                maxLength: 40,
                decoration: const InputDecoration(
                  hintText: 'Ej: Juan Carlos',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese los nombres';
                  if (!_validarFormatoDosPalabras(value)) {
                    return 'Ingrese al menos dos nombres válidos (solo letras)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- Apellidos ---
              const Text('Apellidos', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _apellidoController,
                maxLength: 40,
                decoration: const InputDecoration(
                  hintText: 'Ej: Pérez González',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese los apellidos';
                  if (!_validarFormatoDosPalabras(value)) {
                    return 'Ingrese los dos apellidos completos (Paterno y Materno)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- RUT ---
              const Text('RUT', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _rutController,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9kK]')),
                  LengthLimitingTextInputFormatter(9), 
                ],
                decoration: const InputDecoration(
                  hintText: '12.345.678-9',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
                maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Ej: 35',
                  counterText: "",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese la edad';
                  final numero = int.tryParse(value) ?? 0;
                  if (numero < 18 || numero > 100) {
                    return 'La edad laboral debe estar entre 18 y 100 años';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Cargo ---
              const Text('Cargo', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cargoController,
                maxLength: 40,
                decoration: const InputDecoration(
                  hintText: 'Ej: Analista de RRHH v2',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese el cargo';
                  if (!_validarCargoCoherente(value)) {
                    return 'Ingrese un cargo coherente (mínimo 3 letras, sin símbolos)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- Salario ---
              const Text('Salario (CLP)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _salarioController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: '\$1.500.000',
                  counterText: "",
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
                  if (numero < 400000) {
                    return 'El salario debe ser igual o superior al sueldo mínimo';
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
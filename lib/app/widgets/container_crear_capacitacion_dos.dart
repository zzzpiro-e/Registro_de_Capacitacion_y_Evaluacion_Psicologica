import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/app/services/auditoria_service.dart';

class CapacitacionesProvider extends ChangeNotifier {
  int _version = 0;

  int get version => _version;

  void refresh() {
    _version++;
    notifyListeners();
  }
}

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
  final _tipoController = TextEditingController();

  final List<TextEditingController> _rutControllers = [];

  bool _asignarATodos = false;
  bool _isLoading = false;
  bool _formValido = false;

  bool _validarTextoConNumeros(String? value, int minLength, int maxLength) {
    if (value == null) return false;
    final texto = value.trim();
    if (texto.length < minLength || texto.length > maxLength) return false;
    
    return RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ]').hasMatch(texto);
  }

  bool _validarTextoSoloLetras(String? value, int minLength, int maxLength) {
    if (value == null) return false;
    final texto = value.trim();
    if (texto.length < minLength || texto.length > maxLength) return false;

    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s.,()\-]+$').hasMatch(texto);
  }

  void _agregarCampoRut() {
    final nuevoController = TextEditingController();
    nuevoController.addListener(_actualizarEstado);
    setState(() {
      _rutControllers.add(nuevoController);
    });
    _actualizarEstado();
  }

  void _removerCampoRut(int index) {
    _rutControllers[index].dispose();
    setState(() {
      _rutControllers.removeAt(index);
    });
    _actualizarEstado();
  }

  // Devuelve el formato plano (Ej: 123456781)
  String _limpiarRutEspecifico(String rutOriginal) {
    return rutOriginal.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
  }

  // Devuelve el formato con puntos y guion (Ej: 12.345.678-1)
  String _formatearRut(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();

    if (clean.isEmpty) return '';

    String cuerpo;
    String dv = '';

    if (clean.length > 1) {
      cuerpo = clean.substring(0, clean.length - 1);
      dv = clean.substring(clean.length - 1);
    } else {
      cuerpo = clean;
    }

    String formatted = '';
    int count = 0;

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      formatted = cuerpo[i] + formatted;
      count++;

      if (count == 3 && i != 0) {
        formatted = '.$formatted';
        count = 0;
      }
    }

    if (dv.isNotEmpty) {
      formatted = '$formatted-$dv';
    }

    return formatted;
  }

  Future<bool> _existeTitulo(String titulo) async {
    final doc = await FirebaseFirestore.instance
        .collection('capacitaciones')
        .doc(titulo)
        .get();

    return doc.exists;
  }

  void _actualizarEstado() {
    bool rutsValidos = _rutControllers.isNotEmpty;
    
    for (var controller in _rutControllers) {
      final textoLimpio = _limpiarRutEspecifico(controller.text);
      // Un RUT válido limpio tiene entre 7 y 9 caracteres (Ej: 12345678K)
      if (textoLimpio.length < 7 || textoLimpio.length > 9) {
        rutsValidos = false;
        break;
      }
    }

    final valido =
        _validarTextoConNumeros(_tituloController.text, 3, 50) &&
        _validarTextoConNumeros(_descripcionController.text, 10, 200) &&
        _validarTextoSoloLetras(_institucionController.text, 3, 50) &&
        _validarTextoSoloLetras(_tipoController.text, 3, 50) &&
        (_asignarATodos || rutsValidos);

    setState(() {
      _formValido = valido;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || !_formValido) return;

    setState(() => _isLoading = true);

    try {
      final titulo = _tituloController.text.trim();
      final existe = await _existeTitulo(titulo);

      if (existe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya existe una capacitación con ese nombre')),
        );
        setState(() => _isLoading = false);
        return;
      }

      List<String> empleadosAsignados = [];

      if (_asignarATodos) {
        final snapshot = await FirebaseFirestore.instance
            .collection('empleados')
            .get();

        empleadosAsignados = snapshot.docs.map((e) => e.id).toList();
      } else {
        List<String> rutsInexistentesOErrores = [];

        // 🔥 GESTIÓN ULTRA-FLEXIBLE DE BÚSQUEDA DE RUTS
        for (var controller in _rutControllers) {
          final textoOriginal = controller.text.trim();
          if (textoOriginal.isEmpty) continue;

          // 1. Formato Todo Junto (Ej: 123456781) -> Remueve puntos y guiones
          final rutTodoJunto = textoOriginal.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
          
          // 2. Formato Chileno Estándar (Ej: 12.345.678-1)
          final rutConPuntosYGuion = _formatearRut(textoOriginal);

          // 3. Formato Solo Guion (Ej: 12345678-1)
          String rutSoloGuion = rutTodoJunto;
          if (rutTodoJunto.length > 1) {
            rutSoloGuion = "${rutTodoJunto.substring(0, rutTodoJunto.length - 1)}-${rutTodoJunto.substring(rutTodoJunto.length - 1)}";
          }

          // --- RONDA DE CONSULTAS A FIRESTORE ---
          
          // Intento 1: Buscar todo junto (Como está en tu BD: 123456781)
          var docRef = FirebaseFirestore.instance.collection('empleados').doc(rutTodoJunto);
          var snapshot = await docRef.get();

          if (snapshot.exists) {
            empleadosAsignados.add(rutTodoJunto);
            continue; 
          }

          // Intento 2: Buscar por Texto Exacto (por si el usuario lo ingresó manual)
          docRef = FirebaseFirestore.instance.collection('empleados').doc(textoOriginal);
          snapshot = await docRef.get();
          if (snapshot.exists) {
            empleadosAsignados.add(textoOriginal);
            continue;
          }

          // Intento 3: Buscar con puntos y guion (12.345.678-1)
          docRef = FirebaseFirestore.instance.collection('empleados').doc(rutConPuntosYGuion);
          snapshot = await docRef.get();
          if (snapshot.exists) {
            empleadosAsignados.add(rutConPuntosYGuion);
            continue;
          }

          // Intento 4: Buscar solo con guion (12345678-1)
          docRef = FirebaseFirestore.instance.collection('empleados').doc(rutSoloGuion);
          snapshot = await docRef.get();
          if (snapshot.exists) {
            empleadosAsignados.add(rutSoloGuion);
            continue;
          }

          // Si no entra en ninguno, guardamos el formato con puntos y guion para mostrar el error amigablemente
          rutsInexistentesOErrores.add(rutConPuntosYGuion.isNotEmpty ? rutConPuntosYGuion : textoOriginal);
        }

        if (rutsInexistentesOErrores.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Los siguientes RUTs no existen en la BD: ${rutsInexistentesOErrores.join(", ")}'
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

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
      
      context.read<CapacitacionesProvider>().refresh();
      await AuditoriaService.rrhhCreoCapacitacion(titulo: titulo);

      _tituloController.clear();
      _descripcionController.clear();
      _institucionController.clear();
      _tipoController.clear();
      
      for (var c in _rutControllers) {
        c.dispose();
      }
      _rutControllers.clear();

      setState(() {
        _asignarATodos = false;
        _isLoading = false;
        _formValido = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capacitación guardada con éxito')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tituloController.addListener(_actualizarEstado);
    _descripcionController.addListener(_actualizarEstado);
    _institucionController.addListener(_actualizarEstado);
    _tipoController.addListener(_actualizarEstado);
    _agregarCampoRut();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _institucionController.dispose();
    _tipoController.dispose();
    for (var c in _rutControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tituloController,
              maxLength: 50,
              decoration: const InputDecoration(
                hintText: 'Ej: Extinción de Fuegos v2',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El campo no puede estar vacío';
                if (!_validarTextoConNumeros(v, 3, 50)) {
                  return 'Debe tener entre 3 y 50 caracteres (con letras).';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: 'Breve descripción del curso',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El campo no puede estar vacío';
                if (!_validarTextoConNumeros(v, 10, 200)) {
                  return 'Debe tener entre 10 y 200 caracteres coherentes.';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            const Text('Institución', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _institucionController,
              maxLength: 50,
              decoration: const InputDecoration(
                hintText: 'Mutual de Seguridad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El campo no puede estar vacío';
                if (!_validarTextoSoloLetras(v, 3, 50)) {
                  return 'Debe tener entre 3 y 50 caracteres (solo letras).';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                value: _asignarATodos,
                title: const Text('Asignar a todos los empleados'),
                activeColor: const Color(0xFF2E7D32),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  setState(() => _asignarATodos = v ?? false);
                  _actualizarEstado();
                },
              ),
            ),

            const SizedBox(height: 16),

            if (!_asignarATodos) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Empleados Asignados',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  TextButton.icon(
                    onPressed: _agregarCampoRut,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar Empleado'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rutControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rutControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Empleado ${index + 1}: 12.345.678-9',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            onChanged: (value) {
                              final formatted = _formatearRut(value);
                              _rutControllers[index].value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                              _actualizarEstado();
                            },
                            validator: (v) {
                              if (_asignarATodos) return null;
                              if (v == null || v.trim().isEmpty) {
                                return 'Debe ingresar un RUT';
                              }
                              if (_limpiarRutEspecifico(v).length < 7) {
                                return 'RUT inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_rutControllers.length > 1) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removerCampoRut(index),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tipoController,
              maxLength: 50,
              decoration: const InputDecoration(
                hintText: 'Ej: Seguridad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El campo no puede estar vacío';
                if (!_validarTextoSoloLetras(v, 3, 50)) {
                  return 'Debe tener entre 3 y 50 caracteres (solo letras).';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: (_formValido && !_isLoading) ? _guardar : null,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
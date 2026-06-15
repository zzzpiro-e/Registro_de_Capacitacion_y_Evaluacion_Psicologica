import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/app/services/auditoria_service.dart';
import 'package:flutter/services.dart';

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
  final _empleadosAsignadosController = TextEditingController();
  final _tipoController = TextEditingController();

  bool _asignarATodos = false;
  bool _isLoading = false;
  bool _formValido = false;

  String _rutLimpio = '';

  // ==========================================
  // VALIDADORES GENÉRICOS
  // ==========================================
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
    
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(texto);
  }

  // =========================
  // FORMATO RUT CHILENO REAL
  // =========================
  String _formatearRut(String input) {
      // 1. Limpiamos caracteres no válidos
      String clean = input.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
      
      if (clean.length > 9) {
        clean = clean.substring(0, 9);
      }

      _rutLimpio = clean; 

      if (clean.isEmpty) return '';

      String cuerpo = clean.substring(0, clean.length - 1);
      String dv = clean.substring(clean.length - 1);

      String formattedCuerpo = "";
      int count = 0;
      for (int i = cuerpo.length - 1; i >= 0; i--) {
        formattedCuerpo = cuerpo[i] + formattedCuerpo;
        count++;
        if (count == 3 && i != 0) {
          formattedCuerpo = '.$formattedCuerpo';
          count = 0;
        }
      }

      return cuerpo.isEmpty ? dv : '$formattedCuerpo-$dv';
    }

  // =========================
  // VALIDACIÓN DUPLICADO TITULO
  // =========================
  Future<bool> _existeTitulo(String titulo) async {
    final doc = await FirebaseFirestore.instance
        .collection('capacitaciones')
        .doc(titulo)
        .get();

    return doc.exists;
  }

  void _actualizarEstado() {
    final valido =
        _validarTextoConNumeros(_tituloController.text, 10, 60) &&
        _validarTextoConNumeros(_descripcionController.text, 30, 250) &&
        _validarTextoSoloLetras(_institucionController.text, 5, 40) &&
        _validarTextoSoloLetras(_tipoController.text, 5, 25) && // Límite para Tipo
        (_asignarATodos || (_rutLimpio.length >= 8 && _rutLimpio.length <= 9));

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
        final doc = await FirebaseFirestore.instance
            .collection('empleados')
            .doc(_rutLimpio)
            .get();

        if (!doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El RUT no existe en la base de datos')),
          );
          setState(() => _isLoading = false);
          return;
        }

        empleadosAsignados.add(_rutLimpio);
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
      _empleadosAsignadosController.clear();
      _tipoController.clear();

      setState(() {
        _asignarATodos = false;
        _rutLimpio = '';
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tituloController,
              maxLength: 50, // Límite físico en el teclado
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
              maxLength: 200, // Evita textos eternos e incluye contador visual
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
              keyboardType: TextInputType.text,
              // Bloquea números y caracteres especiales en tiempo real
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              ],
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
              TextFormField(
                controller: _empleadosAsignadosController,
                keyboardType: TextInputType.text, 
                maxLength: 12, 
                decoration: const InputDecoration(
                  hintText: '12.345.678-9',
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: (value) {
                  final formatted = _formatearRut(value);
                  _empleadosAsignadosController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                  _actualizarEstado();
                },
                validator: (v) {
                  if (_asignarATodos) return null;
                  if (v == null || v.trim().isEmpty) return 'Debe ingresar un RUT';
                  if (_rutLimpio.length < 8) return 'RUT incompleto';
                  
                  return null;
                },
              ),
            ],

            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tipoController,
              maxLength: 25, // Ajustado a 25 caracteres
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              ],
              decoration: const InputDecoration(
                hintText: 'Ej: Seguridad, Liderazgo',
                counterText: "", // Oculta el contador pequeño
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 5) return 'Mínimo 5 caracteres';
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
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/services/auditoria_service.dart';

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

  // =========================
  // FORMATO RUT CHILENO REAL
  // xx.xxx.xxx-x
  // =========================
  String _formatearRut(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();

    if (clean.isEmpty) {
      _rutLimpio = '';
      return '';
    }

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

    _rutLimpio = clean;

    return formatted;
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
        _tituloController.text.trim().length >= 3 &&
        _descripcionController.text.trim().length >= 5 &&
        _institucionController.text.trim().length >= 3 &&
        _tipoController.text.trim().length >= 3 &&
        (_asignarATodos || _rutLimpio.length >= 7);

    setState(() {
      _formValido = valido;
    });
  }

  Future<void> _guardar() async {
    if (!_formValido) return;

    setState(() => _isLoading = true);

    try {
      final titulo = _tituloController.text.trim();

      final existe = await _existeTitulo(titulo);

      if (existe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una capacitación con ese nombre'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      List<String> empleadosAsignados = [];

      if (_asignarATodos) {
        final snapshot =
            await FirebaseFirestore.instance.collection('empleados').get();

        empleadosAsignados = snapshot.docs.map((e) => e.id).toList();
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('empleados')
            .doc(_rutLimpio)
            .get();

        if (!doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El RUT no existe')),
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

      // 📝 REGISTRAR EN AUDITORÍA
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
        const SnackBar(content: Text('Capacitación guardada')),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                hintText: 'Ej: Extinción de Fuegos',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            const Text('Descripción',
                style: TextStyle(fontWeight: FontWeight.w600)),
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
              validator: (v) {
                if (v == null || v.trim().length < 5) {
                  return 'Mínimo 5 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            const Text('Institución',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _institucionController,
              decoration: const InputDecoration(
                hintText: 'Mutual de Seguridad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

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

            if (!_asignarATodos)
              TextFormField(
                controller: _empleadosAsignadosController,
                decoration: const InputDecoration(
                  hintText: '12.345.678-9',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: (value) {
                  final formatted = _formatearRut(value);

                  _empleadosAsignadosController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );

                  _actualizarEstado();
                },
                validator: (v) {
                  if (_asignarATodos) return null;
                  if (_rutLimpio.length < 7) {
                    return 'RUT inválido';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 20),

            const Text('Tipo',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tipoController,
              decoration: const InputDecoration(
                hintText: 'Ej: seguridad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: (_formValido && !_isLoading)
                    ? _guardar
                    : null,
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
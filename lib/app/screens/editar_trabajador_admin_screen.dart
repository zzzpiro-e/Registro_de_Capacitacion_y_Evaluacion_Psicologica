import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditarTrabajadorAdminScreen extends StatefulWidget {
  final String trabajadorId;

  const EditarTrabajadorAdminScreen({super.key, required this.trabajadorId});

  @override
  State<EditarTrabajadorAdminScreen> createState() => _EditarTrabajadorAdminScreenState();
}

class _EditarTrabajadorAdminScreenState extends State<EditarTrabajadorAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _rutController = TextEditingController();
  final _emailController = TextEditingController();
  final _correoPersonalController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _activo = true;
  String _rol = 'rrhh';
  bool _cargando = true;

  void _formatearTelefonoEnVivo(String valor) {
    String numeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.startsWith('569') && numeros.length > 3) numeros = numeros.substring(3);
    if (numeros.startsWith('9') && numeros.length == 9) numeros = numeros.substring(1);

    if (numeros.length == 8 || numeros.length == 9) {
      String telefonoFormateado = '+56 9 $numeros';
      _telefonoController.value = TextEditingValue(
        text: telefonoFormateado,
        selection: TextSelection.collapsed(offset: telefonoFormateado.length),
      );
    }
  }

  bool _validarAlgoritmoRut(String rut) {
    if (rut.length < 2) return false;
    String dv = rut.substring(rut.length - 1);
    String cuerpo = rut.substring(0, rut.length - 1);
    int? rutNums = int.tryParse(cuerpo);
    if (rutNums == null) return false;
    int suma = 0, multiplicador = 2;
    for (int i = cuerpo.length - 1; i >= 0; i--) {
      suma += int.parse(cuerpo[i]) * multiplicador;
      multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
    }
    int dvEsperadoNum = 11 - (suma % 11);
    String dvEsperado = dvEsperadoNum == 11 ? '0' : dvEsperadoNum == 10 ? 'K' : dvEsperadoNum.toString();
    return dv == dvEsperado;
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _emailController.dispose();
    _correoPersonalController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final doc = await FirebaseFirestore.instance.collection('trabajadores').doc(widget.trabajadorId).get();

    if (!mounted) return;

    if (doc.exists) {
      final data = doc.data() ?? <String, dynamic>{};
      setState(() {
        _nombreController.text = data['nombre']?.toString() ?? '';
        _rutController.text = data['rut']?.toString() ?? '';
        _emailController.text = data['email']?.toString() ?? '';
        _correoPersonalController.text = data['correoPersonal']?.toString() ?? '';
        _telefonoController.text = data['telefono']?.toString() ?? '';
        _rol = data['rol']?.toString() ?? 'rrhh';
        _activo = data['activo'] ?? true;
        _cargando = false;
      });
    } else {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final String rut = _rutController.text.trim();
    final String email = _emailController.text.trim().toLowerCase();

    // Check duplicate RUT
    try {
      final rutQuery = await FirebaseFirestore.instance
          .collection('trabajadores')
          .where('rut', isEqualTo: rut)
          .get();
      if (rutQuery.docs.any((doc) => doc.id != widget.trabajadorId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este RUT ya está registrado por otro trabajador.')),
        );
        return;
      }

      // Check duplicate Email
      final emailQuery = await FirebaseFirestore.instance
          .collection('trabajadores')
          .where('email', isEqualTo: email)
          .get();
      if (emailQuery.docs.any((doc) => doc.id != widget.trabajadorId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este correo corporativo ya está ocupado por otro trabajador.')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar duplicados: $e')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('trabajadores').doc(widget.trabajadorId).update({
      'nombre': _nombreController.text.trim(),
      'rut': rut,
      'email': email,
      'correoPersonal': _correoPersonalController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'rol': _rol,
      'activo': _activo,
    });

    await FirebaseFirestore.instance.collection('usuarios').doc(widget.trabajadorId).set({
      'uid': widget.trabajadorId,
      'nombre': _nombreController.text.trim(),
      'rut': rut,
      'email': email,
      'rol': _rol,
      'activo': _activo,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trabajador actualizado correctamente')),
    );
    Navigator.pop(context);
  }

  Future<void> _eliminarTrabajador() async {
    final confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar trabajador'),
            content: const Text('Esta acción eliminará el registro del trabajador.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    await FirebaseFirestore.instance.collection('trabajadores').doc(widget.trabajadorId).delete();
    await FirebaseFirestore.instance.collection('usuarios').doc(widget.trabajadorId).delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trabajador eliminado')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Editar trabajador'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF43A047)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: _decoracion('Nombre completo *'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Ingrese el nombre completo';
                        if (RegExp(r'[0-9]').hasMatch(value)) {
                          return 'No se permiten números en el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rutController,
                      decoration: _decoracion('RUT *'),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9kK\.\-]')),
                        RutFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingrese el RUT';
                        String rutLimpio = value.replaceAll('.', '').replaceAll('-', '').toUpperCase();
                        if (!_validarAlgoritmoRut(rutLimpio)) return 'RUT inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _decoracion('Correo corporativo *'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Ingrese el correo corporativo';
                        if (!value.trim().toLowerCase().endsWith('@empresa.cl')) {
                          return 'El correo corporativo debe terminar en @empresa.cl';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _correoPersonalController,
                      decoration: _decoracion('Correo personal *'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Ingrese el correo personal';
                        final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Formato de correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: _decoracion('Teléfono'),
                      keyboardType: TextInputType.phone,
                      onChanged: _formatearTelefonoEnVivo,
                      inputFormatters: [LengthLimitingTextInputFormatter(14)],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        String limpio = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (limpio.startsWith('569')) limpio = limpio.substring(3);
                        if (limpio.length < 8) {
                          return 'Mínimo 8 dígitos.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _rol,
                      decoration: _decoracion('Rol'),
                      items: const [
                        DropdownMenuItem(value: 'rrhh', child: Text('RRHH')),
                        DropdownMenuItem(value: 'psicologo', child: Text('Psicólogo')),
                      ],
                      onChanged: (value) => setState(() => _rol = value ?? 'rrhh'),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Trabajador activo'),
                      subtitle: Text(_activo ? 'Puede ingresar a la app' : 'Acceso desactivado'),
                      value: _activo,
                      activeColor: const Color(0xFF43A047),
                      onChanged: (value) => setState(() => _activo = value),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _guardarCambios,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar cambios'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _eliminarTrabajador,
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('Eliminar trabajador', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: _decoracion(label),
      validator: (value) => value == null || value.trim().isEmpty ? 'Ingrese $label' : null,
    );
  }

  InputDecoration _decoracion(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class RutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('.', '').replaceAll('-', '').toUpperCase();
    if (text.isEmpty) return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    String formatted = '';
    if (text.length > 1) {
      String cuerpo = text.substring(0, text.length - 1);
      String dv = text.substring(text.length - 1);
      String cuerpoConPuntos = '';
      int contador = 0;
      for (int i = cuerpo.length - 1; i >= 0; i--) {
        cuerpoConPuntos = cuerpo[i] + cuerpoConPuntos;
        contador++;
        if (contador == 3 && i != 0) {
          cuerpoConPuntos = '.$cuerpoConPuntos';
          contador = 0;
        }
      }
      formatted = '$cuerpoConPuntos-$dv';
    } else {
      formatted = text;
    }
    return newValue.copyWith(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

    await FirebaseFirestore.instance.collection('trabajadores').doc(widget.trabajadorId).update({
      'nombre': _nombreController.text.trim(),
      'rut': _rutController.text.trim(),
      'email': _emailController.text.trim(),
      'correoPersonal': _correoPersonalController.text.trim(),
      'telefono': _telefonoController.text.trim(),
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
                    _campoTexto(_nombreController, 'Nombre completo'),
                    const SizedBox(height: 16),
                    _campoTexto(_rutController, 'RUT'),
                    const SizedBox(height: 16),
                    _campoTexto(_emailController, 'Correo corporativo'),
                    const SizedBox(height: 16),
                    _campoTexto(_correoPersonalController, 'Correo personal'),
                    const SizedBox(height: 16),
                    _campoTexto(_telefonoController, 'Teléfono'),
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
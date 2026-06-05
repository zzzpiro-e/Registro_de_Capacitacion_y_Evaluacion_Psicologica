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

    _mostrarSnackBar('Trabajador actualizado correctamente', const Color(0xFF388E3C));
    Navigator.pop(context);
  }

  Future<void> _eliminarTrabajador() async {
    final confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('¿Eliminar trabajador?', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Esta acción quitará todos sus accesos y eliminará de forma permanente el registro del sistema.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), 
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
                onPressed: () => Navigator.pop(context, true), 
                child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    await FirebaseFirestore.instance.collection('trabajadores').doc(widget.trabajadorId).delete();

    if (!mounted) return;

    _mostrarSnackBar('Trabajador eliminado', Colors.black87);
    Navigator.pop(context);
  }

  void _mostrarSnackBar(String mensaje, Color colorFondo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.w500)), 
        backgroundColor: colorFondo, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 📦 Bloque 1: Encabezado Inmersivo de la Vista
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Editar Trabajador',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 📦 Bloque 2: Formulario Principal Estilizado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Datos de la Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(height: 16),
                            _campoTexto(_nombreController, 'Nombre completo', Icons.person_outline),
                            const SizedBox(height: 16),
                            _campoTexto(_rutController, 'RUT', Icons.badge_outlined),
                            const SizedBox(height: 16),
                            _campoTexto(_emailController, 'Correo corporativo', Icons.mail_outline),
                            const SizedBox(height: 16),
                            _campoTexto(_correoPersonalController, 'Correo personal', Icons.alternate_email_outlined),
                            const SizedBox(height: 16),
                            _campoTexto(_telefonoController, 'Teléfono', Icons.phone_android_outlined),
                            const SizedBox(height: 16),
                            
                            // Dropdown para Selección de Roles Corporativos
                            const Text('Asignación de Rol', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEAEAEA)),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _rol,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.manage_accounts_outlined, color: Colors.grey, size: 22),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'rrhh', child: Text('Analista RRHH', style: TextStyle(fontSize: 15))),
                                  DropdownMenuItem(value: 'psicologo', child: Text('Psicólogo', style: TextStyle(fontSize: 15))),
                                ],
                                onChanged: (value) => setState(() => _rol = value ?? 'rrhh'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Switch de Estatus de Acceso
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEAEAEA)),
                              ),
                              child: SwitchListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('Trabajador activo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Text(_activo ? 'Puede ingresar a la app' : 'Acceso desactivado', style: const TextStyle(fontSize: 13)),
                                value: _activo,
                                activeColor: const Color(0xFF388E3C),
                                onChanged: (value) => setState(() => _activo = value),
                              ),
                            ),
                            const SizedBox(height: 28),
                            
                            // Botón de Guardar
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _guardarCambios,
                                icon: const Icon(Icons.check_circle_outline, size: 20),
                                label: const Text('Guardar cambios', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF388E3C), 
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Botón de Eliminar
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _eliminarTrabajador,
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                label: const Text('Eliminar de la Base de Datos', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.red.shade200),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAEAEA)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Introduce un valor...',
              prefixIcon: Icon(icon, color: Colors.grey, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            validator: (value) => value == null || value.trim().isEmpty ? 'Este campo es obligatorio' : null,
          ),
        ),
      ],
    );
  }
}
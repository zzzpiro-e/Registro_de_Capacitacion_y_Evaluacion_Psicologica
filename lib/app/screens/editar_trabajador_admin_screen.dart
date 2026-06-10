import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

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
  final _adminPasswordController = TextEditingController();

  bool _activo = true;
  String _rol = 'rrhh';
  bool _cargando = true;

  // Variables espejo
  String _nombreOriginal = '';
  String _rutOriginal = '';
  String _emailOriginal = '';
  String _correoPersonalOriginal = '';
  String _telefonoOriginal = '';
  bool _activoOriginal = true;
  String _rolOriginal = 'rrhh';

  // Color verde principal institucional
  final Color verdePrincipal = const Color(0xFF388E3C);

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
    _adminPasswordController.dispose();
    super.dispose();
  }

  // Validación nativa del dígito verificador del RUT
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
        
        String telf = data['telefono']?.toString() ?? '';
        _telefonoController.text = telf.replaceAll('+569', '').trim();
        
        _rol = data['rol']?.toString() ?? 'rrhh';
        _activo = data['activo'] ?? true;

        // Captura de estados iniciales espejo
        _nombreOriginal = _nombreController.text;
        _rutOriginal = _rutController.text;
        _emailOriginal = _emailController.text;
        _correoPersonalOriginal = _correoPersonalController.text;
        _telefonoOriginal = _telefonoController.text;
        _rolOriginal = _rol;
        _activoOriginal = _activo;

        _cargando = false;
      });
    } else {
      setState(() {
        _cargando = false;
      });
    }
  }

  bool _huboModificaciones() {
    return _nombreController.text.trim() != _nombreOriginal ||
        _rutController.text.trim() != _rutOriginal ||
        _emailController.text.trim() != _emailOriginal ||
        _correoPersonalController.text.trim() != _correoPersonalOriginal ||
        _telefonoController.text.trim() != _telefonoOriginal ||
        _rol != _rolOriginal ||
        _activo != _activoOriginal;
  }

  Future<bool> _rutYaExiste(String rut) async {
    final query = await FirebaseFirestore.instance
        .collection('trabajadores')
        .where('rut', isEqualTo: rut)
        .get();
    
    return query.docs.any((doc) => doc.id != widget.trabajadorId);
  }

  Future<bool> _emailCorporativoYaExiste(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('trabajadores')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get();
    
    return query.docs.any((doc) => doc.id != widget.trabajadorId);
  }

  Future<bool> _correoPersonalYaExiste(String correo) async {
    final query = await FirebaseFirestore.instance
        .collection('trabajadores')
        .where('correoPersonal', isEqualTo: correo.trim().toLowerCase())
        .get();
    
    return query.docs.any((doc) => doc.id != widget.trabajadorId);
  }

  Future<void> _notificarCambiosPorCorreo() async {
    final Map<String, String> cambiosEfectuados = {};
    if (_nombreController.text.trim() != _nombreOriginal) cambiosEfectuados['Nombre'] = _nombreController.text.trim();
    if (_rutController.text.trim() != _rutOriginal) cambiosEfectuados['RUT'] = _rutController.text.trim();
    if (_emailController.text.trim() != _emailOriginal) cambiosEfectuados['Correo Corporativo'] = _emailController.text.trim().toLowerCase();
    if (_correoPersonalController.text.trim() != _correoPersonalOriginal) cambiosEfectuados['Correo Personal'] = _correoPersonalController.text.trim().toLowerCase();
    if (_telefonoController.text.trim() != _telefonoOriginal) cambiosEfectuados['Teléfono'] = '+569 ${_telefonoController.text.trim()}';
    if (_rol != _rolOriginal) cambiosEfectuados['Rol en Plataforma'] = _rol.toUpperCase();

    if (cambiosEfectuados.isEmpty) return;

    String resumenCambios = cambiosEfectuados.entries.map((e) {
      return '''
        <div style="margin-bottom: 12px; padding: 12px; background-color: #f9f9f9; border-left: 4px solid #388E3C; border-radius: 4px;">
          <strong style="color: #333333; font-size: 14px;">${e.key}:</strong>
          <span style="color: #666666; font-size: 14px; display: block; margin-top: 4px;">${e.value}</span>
        </div>
      ''';
    }).join('');

    const String serviceId = 'service_lk6356k';      
    const String templateId = 'template_q1vbqx4';    
    const String publicKey = 'C06WRa_nkaY0OUDL_';
    
    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost', 
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': _correoPersonalController.text.trim().toLowerCase(),
            'user_name': _nombreController.text.split(' ')[0], 
            'changes_details': resumenCambios, 
          },
        }),
      );
    } catch (e) {
      print('❌ Error de red al conectar con EmailJS: $e');
    }
  }

  Future<bool> _validarPasswordAdmin() async {
    _adminPasswordController.clear();
    bool esValida = false;
    bool ocultarPassword = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF388E3C)),
                  SizedBox(width: 10),
                  Text('Confirmar Cambios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Introduce tu contraseña para autorizar las modificaciones en la base de datos:',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEAEAEA)),
                    ),
                    child: TextField(
                      controller: _adminPasswordController,
                      obscureText: ocultarPassword,
                      decoration: InputDecoration(
                        hintText: 'Tu contraseña de administrador',
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(ocultarPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                          onPressed: () => setModalState(() => ocultarPassword = !ocultarPassword),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF388E3C), elevation: 0),
                  onPressed: () async {
                    String passwordInput = _adminPasswordController.text.trim();
                    if (passwordInput.isEmpty) return;

                    try {
                      User? adminUser = FirebaseAuth.instance.currentUser;
                      if (adminUser != null && adminUser.email != null) {
                        AuthCredential credential = EmailAuthProvider.credential(
                          email: adminUser.email!,
                          password: passwordInput,
                        );
                        await adminUser.reauthenticateWithCredential(credential);
                        esValida = true;
                        if (context.mounted) Navigator.pop(context);
                      }
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.code == 'wrong-password' ? 'Contraseña incorrecta' : 'Error de autenticación'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    return esValida;
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_huboModificaciones()) {
      Navigator.pop(context);
      return;
    }

    setState(() => _cargando = true);

    final String rut = _rutController.text.trim();
    final String email = _emailController.text.trim().toLowerCase();
    final String correoPersonal = _correoPersonalController.text.trim().toLowerCase();

    // 1. Validación de RUT duplicado
    if (rut != _rutOriginal) {
      bool existe = await _rutYaExiste(rut);
      if (existe) {
        setState(() => _cargando = false);
        _mostrarSnackBar('El RUT ingresado ya está asignado a otro trabajador', Colors.red);
        return;
      }
    }

    // 2. Validación de Correo Corporativo duplicado
    if (email != _emailOriginal.toLowerCase()) {
      bool existeEmail = await _emailCorporativoYaExiste(email);
      if (existeEmail) {
        setState(() => _cargando = false);
        _mostrarSnackBar('El correo corporativo ya está ocupado por otro trabajador', Colors.red);
        return;
      }
    }

    // 3. Validación de Correo Personal duplicado
    if (correoPersonal != _correoPersonalOriginal.toLowerCase()) {
      bool existeCorreo = await _correoPersonalYaExiste(correoPersonal);
      if (existeCorreo) {
        setState(() => _cargando = false);
        _returnCargandoState();
        _mostrarSnackBar('El correo personal ya está registrado por otro trabajador', Colors.red);
        return;
      }
    }
    
    setState(() => _cargando = false);

    bool verificado = await _validarPasswordAdmin();
    if (!verificado) return;

    try {
      String telefonoCompleto = '+569${_telefonoController.text.trim()}';

      // Actualización atómica en la colección de trabajadores
      await FirebaseFirestore.instance.collection('trabajadores').doc(widget.trabajadorId).update({
        'nombre': _nombreController.text.trim(),
        'rut': rut,
        'email': email,
        'correoPersonal': correoPersonal, 
        'telefono': telefonoCompleto,
        'rol': _rol,
        'activo': _activo,
      });

      // Actualización en cascada de la colección usuarios de control de login
      await FirebaseFirestore.instance.collection('usuarios').doc(widget.trabajadorId).set({
        'uid': widget.trabajadorId,
        'nombre': _nombreController.text.trim(),
        'rut': rut,
        'email': email,
        'rol': _rol,
        'activo': _activo,
      }, SetOptions(merge: true));

      await _notificarCambiosPorCorreo();

      if (!mounted) return;

      _mostrarSnackBar('Trabajador actualizado con éxito', const Color(0xFF388E3C));
      Navigator.pop(context);
    } catch (e) {
      _mostrarSnackBar('Error al guardar cambios: $e', Colors.red);
    }
  }

  void _returnCargandoState() {
    setState(() => _cargando = false);
  }

  Future<void> _eliminarTrabajador() async {
    final confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('¿Eliminar trabajador?', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Esta acción quitará todos sus accesos de forma permanente del sistema.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
                onPressed: () => Navigator.pop(context, true), 
                child: const Text('Eliminar')
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    // Eliminación física y en cascada de ambas tablas de control
    await FirebaseFirestore.instance.collection('trabajadores').doc(widget.trabajadorId).delete();
    await FirebaseFirestore.instance.collection('usuarios').doc(widget.trabajadorId).delete();

    if (!mounted) return;
    _mostrarSnackBar('Trabajador eliminado de forma permanente', Colors.black87);
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
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

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
                          const Text('Editar Trabajador', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Datos de la Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(height: 16),
                            _campoTexto(
                              _nombreController, 
                              'Nombre completo', 
                              Icons.person_outline, 
                              null, 
                              (value) {
                                if (value == null || value.trim().isEmpty) return 'Ingrese el nombre completo';
                                if (RegExp(r'[0-9]').hasMatch(value)) return 'No se permiten números en el nombre';
                                return null;
                              }
                            ),
                            const SizedBox(height: 16),
                            _campoTexto(
                              _rutController, 
                              'RUT', 
                              Icons.badge_outlined, 
                              [RutFormatter()], 
                              (val) {
                                if (val == null || val.isEmpty) return 'El RUT es obligatorio';
                                String rutLimpio = val.replaceAll('.', '').replaceAll('-', '').toUpperCase();
                                if (!_validarAlgoritmoRut(rutLimpio)) return 'RUT inválido';
                                return null;
                              }
                            ),
                            const SizedBox(height: 16),
                            _campoTexto(
                              _emailController, 
                              'Correo corporativo', 
                              Icons.mail_outline, 
                              null, 
                              (val) {
                                if (val == null || val.isEmpty) return 'El correo corporativo es obligatorio';
                                if (!val.trim().toLowerCase().endsWith('@empresa.cl')) return 'Debe usar el dominio @empresa.cl';
                                return null;
                              }
                            ),
                            const SizedBox(height: 16),
                            _campoTexto(
                              _correoPersonalController, 
                              'Correo personal', 
                              Icons.alternate_email_outlined, 
                              null, 
                              (val) {
                                if (val == null || val.isEmpty) return 'El correo personal es obligatorio';
                                if (!emailRegex.hasMatch(val.trim())) return 'Ingresa un correo electrónico válido';
                                return null;
                              }
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Teléfono', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFEAEAEA)),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                  ),
                                  child: TextFormField(
                                    controller: _telefonoController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 8,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        child: Text('+569 ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'El número es obligatorio';
                                      if (val.length != 8) return 'Faltan dígitos (Deben ser 8 números)';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                initialValue: _rol,
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
                                activeThumbColor: const Color(0xFF388E3C),
                                onChanged: (value) => setState(() => _activo = value),
                              ),
                            ),
                            const SizedBox(height: 28),
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
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

  Widget _campoTexto(TextEditingController controller, String label, IconData icon, List<TextInputFormatter>? formatters, String? Function(String?)? validator) {
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
            inputFormatters: formatters,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            validator: validator ?? (value) => value == null || value.trim().isEmpty ? 'Este campo es obligatorio' : null,
          ),
        ),
      ],
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
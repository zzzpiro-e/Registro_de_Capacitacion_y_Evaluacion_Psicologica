import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyecto_flutter/app/services/auditoria_service.dart';

class EditarTrabajadorAdminScreen extends StatefulWidget {
  final String trabajadorId;

  const EditarTrabajadorAdminScreen({super.key, required this.trabajadorId});

  @override
  State<EditarTrabajadorAdminScreen> createState() =>
      _EditarTrabajadorAdminScreenState();
}

class _EditarTrabajadorAdminScreenState
    extends State<EditarTrabajadorAdminScreen> {
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

  Map<String, dynamic> _valoresOriginales = {};

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
    String dvEsperado = dvEsperadoNum == 11
        ? '0'
        : dvEsperadoNum == 10
            ? 'K'
            : dvEsperadoNum.toString();
    return dv == dvEsperado;
  }

  Future<void> _cargarDatos() async {
    final doc = await FirebaseFirestore.instance
        .collection('trabajadores')
        .doc(widget.trabajadorId)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      final data = doc.data() ?? <String, dynamic>{};
      setState(() {
        _nombreController.text = data['nombre']?.toString() ?? '';
        _rutController.text = data['rut']?.toString() ?? '';
        _emailController.text = data['email']?.toString() ?? '';
        _correoPersonalController.text =
            data['correoPersonal']?.toString() ?? '';

        String telf = data['telefono']?.toString() ?? '';
        _telefonoController.text = telf.replaceAll('+569', '').trim();

        _rol = data['rol']?.toString() ?? 'rrhh';
        _activo = data['activo'] ?? true;
        _valoresOriginales = {
          'nombre': _nombreController.text,
          'rut': _rutController.text,
          'email': _emailController.text,
          'correoPersonal': _correoPersonalController.text,
          'telefono': _telefonoController.text,
          'rol': _rol,
          'activo': _activo,
        };

        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  bool _huboModificaciones() {
    return _nombreController.text.trim() != _valoresOriginales['nombre'] ||
        _rutController.text.trim() != _valoresOriginales['rut'] ||
        _emailController.text.trim() != _valoresOriginales['email'] ||
        _correoPersonalController.text.trim() !=
            _valoresOriginales['correoPersonal'] ||
        _telefonoController.text.trim() != _valoresOriginales['telefono'] ||
        _rol != _valoresOriginales['rol'] ||
        _activo != _valoresOriginales['activo'];
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

  Future<void> _notificarCambiosPorCorreo() async {
    final Map<String, String> cambiosEfectuados = {};
    
    if (_nombreController.text.trim() != _valoresOriginales['nombre'])
      cambiosEfectuados['Nombre'] = _nombreController.text.trim();
    if (_rutController.text.trim() != _valoresOriginales['rut'])
      cambiosEfectuados['RUT'] = _rutController.text.trim();
    if (_emailController.text.trim() != _valoresOriginales['email'])
      cambiosEfectuados['Correo Corporativo'] = _emailController.text
          .trim()
          .toLowerCase();
    if (_correoPersonalController.text.trim() !=
        _valoresOriginales['correoPersonal'])
      cambiosEfectuados['Correo Personal'] = _correoPersonalController.text
          .trim()
          .toLowerCase();
    if (_telefonoController.text.trim() != _valoresOriginales['telefono'])
      cambiosEfectuados['Teléfono'] = '+569 ${_telefonoController.text.trim()}';
    if (_rol != _valoresOriginales['rol'])
      cambiosEfectuados['Rol en Plataforma'] = _rol.toUpperCase();
      
    // Notificar el cambio de Estado Activo
    if (_activo != _valoresOriginales['activo']) {
      cambiosEfectuados['Estado de la Cuenta'] = _activo ? 'ACTIVO / HABILITADO' : 'INACTIVO / DESHABILITADO';
    }

    if (cambiosEfectuados.isEmpty) return;

    String resumenCambios = cambiosEfectuados.entries
        .map((e) {
          return '''
        <div style="margin-bottom: 12px; padding: 12px; background-color: #f9f9f9; border-left: 4px solid #388E3C; border-radius: 4px;">
          <strong style="color: #333333; font-size: 14px;">${e.key}:</strong>
          <span style="color: #666666; font-size: 14px; display: block; margin-top: 4px;">${e.value}</span>
        </div>
      ''';
        })
        .join('');

    const String serviceId = 'service_lk6356k';
    const String templateId = 'template_q1vbqx4';
    const String publicKey = 'C06WRa_nkaY0OUDL_';
    const String accessToken = 'cWgB9XiLdDZYN0s0Gb6K6';

    String nombreLimpio = _nombreController.text.trim();
    String primerNombre = nombreLimpio.contains(' ')
        ? nombreLimpio.split(' ')[0]
        : nombreLimpio;

    if (primerNombre.isEmpty) {
      primerNombre = "Trabajador";
    }

    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'accessToken': accessToken,
          'template_params': {
            'worker_email': _correoPersonalController.text.trim().toLowerCase(),
            'user_name': primerNombre,
            'changes_details': resumenCambios,
          },
        }),
      );
      print('📝 Respuesta EmailJS: [${response.statusCode}] ${response.body}');
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF388E3C)),
                  SizedBox(width: 10),
                  Text(
                    'Confirmación Requerida',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Introduce tu contraseña para autorizar esta acción en la base de datos:',
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
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => setModalState(
                            () => ocultarPassword = !ocultarPassword,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    String passwordInput = _adminPasswordController.text.trim();
                    if (passwordInput.isEmpty) return;

                    try {
                      User? adminUser = FirebaseAuth.instance.currentUser;
                      if (adminUser != null && adminUser.email != null) {
                        AuthCredential credential =
                            EmailAuthProvider.credential(
                          email: adminUser.email!,
                          password: passwordInput,
                        );
                        await adminUser.reauthenticateWithCredential(
                          credential,
                        );
                        esValida = true;
                        if (context.mounted) Navigator.pop(context);
                      }
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.code == 'wrong-password'
                                  ? 'Contraseña incorrecta'
                                  : 'Error de autenticación',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    final String correoPersonal = _correoPersonalController.text
        .trim()
        .toLowerCase();
    final String nuevoNombre = _nombreController.text.trim();

    if (rut != _valoresOriginales['rut']) {
      bool existe = await _rutYaExiste(rut);
      if (existe) {
        setState(() => _cargando = false);
        _mostrarSnackBar(
          'El RUT ingresado ya está asignado a otro trabajador',
          Colors.red,
        );
        return;
      }
    }

    if (email != _valoresOriginales['email'].toString().toLowerCase()) {
      bool existeEmail = await _emailCorporativoYaExiste(email);
      if (existeEmail) {
        setState(() => _cargando = false);
        _mostrarSnackBar(
          'El correo corporativo ya está ocupado por otro trabajador',
          Colors.red,
        );
        return;
      }
    }

    setState(() => _cargando = false);

    bool verificado = await _validarPasswordAdmin();
    if (!verificado) return;

    try {
      setState(() => _cargando = true);
      String telefonoCompleto = '+569${_telefonoController.text.trim()}';

      await FirebaseFirestore.instance
          .collection('trabajadores')
          .doc(widget.trabajadorId)
          .update({
        'nombre': nuevoNombre,
        'rut': rut,
        'email': email,
        'correoPersonal': correoPersonal,
        'telefono': telefonoCompleto,
        'rol': _rol,
        'activo': _activo,
      });

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.trabajadorId)
          .set({
        'uid': widget.trabajadorId,
        'nombre': nuevoNombre,
        'rut': rut,
        'email': email,
        'rol': _rol,
        'activo': _activo,
      }, SetOptions(merge: true));

      if (_valoresOriginales['rol'] != _rol) {
        await AuditoriaService.adminCambioRol(
          nombre: nuevoNombre,
          rolAnterior: _valoresOriginales['rol'],
          rolNuevo: _rol,
        );
      }

      if (_valoresOriginales['activo'] != _activo) {
        await AuditoriaService.adminCambioEstado(
          nombre: nuevoNombre,
          activado: _activo,
        );
      }

      Map<String, dynamic> camposAntes = {};
      Map<String, dynamic> camposDespues = {};
      List<String> camposEditados = [];

      void check(String key, String oldVal, String newVal) {
        if (oldVal != newVal) {
          camposAntes[key] = oldVal;
          camposDespues[key] = newVal;
          camposEditados.add(key);
        }
      }

      check('nombre', _valoresOriginales['nombre'], nuevoNombre);
      check('rut', _valoresOriginales['rut'], rut);
      check('email', _valoresOriginales['email'], email);
      check(
        'correoPersonal',
        _valoresOriginales['correoPersonal'],
        _correoPersonalController.text.trim(),
      );
      check(
        'telefono',
        _valoresOriginales['telefono'],
        _telefonoController.text.trim(),
      );

      if (camposEditados.isNotEmpty) {
        await AuditoriaService.adminModificoUsuario(
          nombre: nuevoNombre,
          campos: camposEditados,
          camposAntes: camposAntes,
          camposDespues: camposDespues,
        );
      }

      await _notificarCambiosPorCorreo();

      if (!mounted) return;

      _mostrarSnackBar(
        'Trabajador actualizado con éxito',
        const Color(0xFF388E3C),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarSnackBar('Error al guardar cambios: $e', Colors.red);
    }
  }

  void _mostrarSnackBar(String mensaje, Color colorFondo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colorFondo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _campoTexto(
    TextEditingController controller,
    String label,
    IconData icono,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAEAEA)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            inputFormatters: formatters,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icono, color: Colors.grey, size: 22),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF388E3C)),
              )
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
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black87,
                              size: 22,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Editar Trabajador',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
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
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Datos de la Cuenta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _campoTexto(
                              _nombreController,
                              'Nombre completo',
                              Icons.person_outline,
                              null,
                              (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Ingrese el nombre completo';
                                if (RegExp(r'[0-9]').hasMatch(value))
                                  return 'No se permiten números en el nombre';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _campoTexto(
                              _rutController,
                              'RUT',
                              Icons.badge_outlined,
                              [RutFormatter()],
                              (val) {
                                if (val == null || val.isEmpty)
                                  return 'El RUT es obligatorio';
                                String rutLimpio = val
                                    .replaceAll('.', '')
                                    .replaceAll('-', '')
                                    .toUpperCase();
                                if (!_validarAlgoritmoRut(rutLimpio))
                                  return 'RUT inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _campoTexto(
                              _emailController,
                              'Correo corporativo',
                              Icons.mail_outline,
                              null,
                              (val) {
                                if (val == null || val.isEmpty)
                                  return 'El correo corporativo es obligatorio';
                                if (!val.trim().toLowerCase().endsWith(
                                      '@empresa.cl',
                                    ))
                                  return 'Debe usar el dominio @empresa.cl';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _campoTexto(
                              _correoPersonalController,
                              'Correo personal',
                              Icons.alternate_email_outlined,
                              null,
                              (val) {
                                if (val == null || val.isEmpty)
                                  return 'El correo personal es obligatorio';
                                if (!emailRegex.hasMatch(val.trim()))
                                  return 'Ingresa un correo electrónico válido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Teléfono',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFEAEAEA),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _telefonoController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 8,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          '+569 ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'El número es obligatorio';
                                      if (val.length != 8)
                                        return 'Faltan dígitos (Deben ser 8 números)';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Asignación de Rol',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFEAEAEA),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _rol,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.manage_accounts_outlined,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'rrhh',
                                    child: Text(
                                      'Analista RRHH',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'psicologo',
                                    child: Text(
                                      'Psicólogo',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                                onChanged: (val) =>
                                    setState(() => _rol = val!),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Estado Activo',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Switch(
                                  value: _activo,
                                  activeColor: verdePrincipal,
                                  onChanged: (val) =>
                                      setState(() => _activo = val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: verdePrincipal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _guardarCambios,
                                icon: const Icon(Icons.save_outlined,
                                    color: Colors.white),
                                label: const Text('Guardar Cambios',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
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
}

class RutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text =
        newValue.text.replaceAll('.', '').replaceAll('-', '').toUpperCase();
    if (text.isEmpty) return newValue;
    if (text.length > 9) text = text.substring(0, 9);

    String formatted = '';
    String dv = text.length > 1 ? text.substring(text.length - 1) : '';
    String nums = text.length > 1 ? text.substring(0, text.length - 1) : text;

    if (nums.length > 3) {
      formatted = '.${nums.substring(nums.length - 3)}';
      nums = nums.substring(0, nums.length - 3);
      if (nums.length > 3) {
        formatted = '.${nums.substring(nums.length - 3)}$formatted';
        nums = nums.substring(0, nums.length - 3);
      }
    }
    formatted = nums + formatted;
    if (text.length > 1) formatted = '$formatted-$dv';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
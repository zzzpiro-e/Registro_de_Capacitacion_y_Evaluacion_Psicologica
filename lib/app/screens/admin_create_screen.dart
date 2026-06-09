import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:firebase_core/firebase_core.dart';

class AdminCreateScreen extends StatefulWidget {
  const AdminCreateScreen({super.key});

  @override
  State<AdminCreateScreen> createState() => _AdminCreateScreenState();
}

class _AdminCreateScreenState extends State<AdminCreateScreen> {
  final _nombreController = TextEditingController();
  final _rutController = TextEditingController();
  final _usuarioCorporativoController = TextEditingController(); 
  final _correoPersonalController = TextEditingController();    
  final _telefonoController = TextEditingController();
  final _claveController = TextEditingController();
  
  // FocusNodes
  final FocusNode _rutFocusNode = FocusNode();
  final FocusNode _usuarioFocusNode = FocusNode();
  final FocusNode _correoPersonalFocusNode = FocusNode();
  final FocusNode _telefonoFocusNode = FocusNode(); 
  
  // Variables de validación
  String? _rutError; 
  bool _isRutValid = false; 
  String? _usuarioError;
  bool _isUsuarioValid = false;
  String? _correoPersonalError;
  bool _isCorreoPersonalValid = false;
  String? _telefonoError;
  bool _isTelefonoValid = false;

  bool _isLoading = false;
  String _selectedRole = 'RRHH'; 

  @override
  void initState() {
    super.initState();
    _rutFocusNode.addListener(_onRutFocusChange);
    _usuarioFocusNode.addListener(_onUsuarioFocusChange);
    _correoPersonalFocusNode.addListener(_onCorreoPersonalFocusChange);
    _telefonoFocusNode.addListener(_onTelefonoFocusChange);
    _generarClaveAleatoria();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _usuarioCorporativoController.dispose();
    _correoPersonalController.dispose();
    _telefonoController.dispose();
    _claveController.dispose();
    _rutFocusNode.removeListener(_onRutFocusChange);
    _rutFocusNode.dispose();
    _usuarioFocusNode.removeListener(_onUsuarioFocusChange);
    _usuarioFocusNode.dispose();
    _correoPersonalFocusNode.removeListener(_onCorreoPersonalFocusChange);
    _correoPersonalFocusNode.dispose();
    _telefonoFocusNode.removeListener(_onTelefonoFocusChange);
    _telefonoFocusNode.dispose(); 
    super.dispose();
  }

  void _generarClaveAleatoria() {
    const caracteres = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String claveNueva = List.generate(6, (index) => caracteres[random.nextInt(caracteres.length)]).join();
    setState(() {
      _claveController.text = claveNueva;
    });
  }

  void _onRutFocusChange() { if (!_rutFocusNode.hasFocus) _validarRutInmediato(); }
  void _onUsuarioFocusChange() { if (!_usuarioFocusNode.hasFocus) _validarUsuarioInmediato(); }
  void _onCorreoPersonalFocusChange() { if (!_correoPersonalFocusNode.hasFocus) _validarCorreoPersonalInmediato(); }
  void _onTelefonoFocusChange() { if (!_telefonoFocusNode.hasFocus) _validarTelefonoInmediato(); }

  Future<void> _enviarCorreoNotificacion({
    required String nombreEmpleado,
    required String correoPersonal,
    required String correoCorporativo,
    required String claveProvisoria,
  }) async {
    const String serviceId = 'service_lk6356k'; 
    const String templateId = 'template_8g7cd87';
    const String userId = 'C06WRa_nkaY0OUDL_'; 

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'to_name': nombreEmpleado,
            'to_email': correoPersonal, 
            'corporate_email': correoCorporativo, 
            'temporary_password': claveProvisoria, 
          }
        }),
      );
    } catch (e) {
      print('🚨 Error de conexión al enviar el correo: $e');
    }
  }

  Future<void> _validarUsuarioInmediato() async {
    String usuario = _usuarioCorporativoController.text.trim().toLowerCase();
    if (usuario.isEmpty) {
      setState(() { _usuarioError = null; _isUsuarioValid = false; });
      return;
    }
    String correoCompleto = '$usuario@empresa.cl';
    try {
      final resultado = await FirebaseFirestore.instance
          .collection('trabajadores')
          .where('email', isEqualTo: correoCompleto)
          .get();

      if (resultado.docs.isNotEmpty) {
        setState(() {
          _usuarioError = 'El correo $correoCompleto ya está ocupado.';
          _isUsuarioValid = false;
        });
      } else {
        setState(() {
          _usuarioError = 'Disponible: $correoCompleto';
          _isUsuarioValid = true;
        });
      }
    } catch (e) {
      setState(() { _usuarioError = 'Error al verificar disponibilidad.'; _isUsuarioValid = false; });
    }
  }

  void _validarCorreoPersonalInmediato() {
    String email = _correoPersonalController.text.trim();
    if (email.isEmpty) {
      setState(() { _correoPersonalError = null; _isCorreoPersonalValid = false; });
      return;
    }
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _correoPersonalError = 'Formato inválido (Falta @ o dominio).';
        _isCorreoPersonalValid = false;
      });
    } else {
      setState(() {
        _correoPersonalError = 'Formato de notificación correcto.';
        _isCorreoPersonalValid = true;
      });
    }
  }

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
      setState(() { _telefonoError = 'Formato de teléfono correcto.'; _isTelefonoValid = true; });
    } else if (numeros.isEmpty) {
      setState(() { _telefonoError = null; _isTelefonoValid = true; });
    } else {
      setState(() { _telefonoError = 'Mínimo 8 dígitos.'; _isTelefonoValid = false; });
    }
  }

  void _validarTelefonoInmediato() {
    String texto = _telefonoController.text.trim();
    if (texto.isEmpty) return;
    if (!texto.startsWith('+56') && texto.length < 8) {
      setState(() { _telefonoError = 'Mínimo 8 dígitos.'; _isTelefonoValid = false; });
    }
  }

  Future<void> _validarRutInmediato() async {
    String rutLimpio = _rutController.text.trim().replaceAll('.', '').replaceAll('-', '').toUpperCase();
    if (rutLimpio.isEmpty) {
      setState(() { _rutError = null; _isRutValid = false; });
      return;
    }
    if (!_validarAlgoritmoRut(rutLimpio)) {
      setState(() { _rutError = 'El RUT ingresado no existe.'; _isRutValid = false; });
      return;
    }
    try {
      final resultado = await FirebaseFirestore.instance.collection('trabajadores').where('rut', isEqualTo: _rutController.text.trim()).get();
      if (resultado.docs.isNotEmpty) {
        setState(() { _rutError = 'Este RUT ya ha sido usado.'; _isRutValid = false; });
      } else {
        setState(() { _rutError = 'RUT disponible.'; _isRutValid = true; });
      }
    } catch (e) {
      setState(() { _rutError = 'Error al verificar RUT.'; _isRutValid = false; });
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

  Future<void> _crearTrabajadorEnFirebase() async {
    await _validarRutInmediato();
    await _validarUsuarioInmediato();
    _validarCorreoPersonalInmediato();
    _validarTelefonoInmediato();

    if (!_isRutValid || !_isUsuarioValid || !_isCorreoPersonalValid) {
      _mostrarSnackBar('Por favor, corrige los campos marcados en rojo.', Colors.red);
      return;
    }

    if (_nombreController.text.trim().isEmpty) {
      _mostrarSnackBar('Por favor, rellena el nombre del trabajador.', Colors.orange);
      return;
    }

    setState(() { _isLoading = true; });

    String emailCorporativoFinal = '${_usuarioCorporativoController.text.trim().toLowerCase()}@empresa.cl';
    String claveGenerada = _claveController.text.trim();
    String correoPersonalDestino = _correoPersonalController.text.trim();
    String nombreTrabajador = _nombreController.text.trim();

    FirebaseApp? appTemporal;
    try {
      // Intenta inicializar la app temporal, si ya existe en memoria la reutiliza
      try {
        appTemporal = await Firebase.initializeApp(
          name: 'TemporaryUserCreationApp',
          options: Firebase.app().options, 
        );
      } catch (e) {
        appTemporal = Firebase.app('TemporaryUserCreationApp');
      }

      // Conectamos de forma segura la instancia de autenticación intermedia
      FirebaseAuth authTemporal = FirebaseAuth.instanceFor(app: appTemporal);
      
      // Creamos el usuario en el sub-árbol secundario sin desloguear al Administrador actual
      UserCredential userCredential = await authTemporal.createUserWithEmailAndPassword(
        email: emailCorporativoFinal,
        password: claveGenerada,
      );

      // Enviamos el correo de verificación nativo de Firebase
      await userCredential.user!.sendEmailVerification();
      
      await appTemporal.delete();
          
      final user = userCredential.user;
      if (user == null) {
        _mostrarSnackBar('Error: No se pudo obtener el ID del usuario creado.', Colors.red);
        return;
      }
      String uid = user.uid;
      String rolFirebase = _selectedRole == 'RRHH' ? 'rrhh' : 'psicologo';

      // Escritura unificada en la colección trabajadores
      await FirebaseFirestore.instance.collection('trabajadores').doc(uid).set({
        'uid': uid,
        'nombre': nombreTrabajador,
        'rut': _rutController.text.trim(),
        'email': emailCorporativoFinal, 
        'correoPersonal': correoPersonalDestino, 
        'telefono': _telefonoController.text.trim(), 
        'rol': rolFirebase,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nombre': nombreTrabajador,
        'rut': _rutController.text.trim(),
        'email': emailCorporativoFinal, 
        'rol': rolFirebase,
        'activo': true,
      });

      // Gatillamos la notificación por EmailJS al correo personal
      await _enviarCorreoNotificacion(
        nombreEmpleado: nombreTrabajador,
        correoPersonal: correoPersonalDestino,
        correoCorporativo: emailCorporativoFinal,
        claveProvisoria: claveGenerada,
      );

      // Limpieza de controladores
      _nombreController.clear();
      _rutController.clear();
      _usuarioCorporativoController.clear();
      _correoPersonalController.clear();
      _telefonoController.clear();
      _generarClaveAleatoria();

      setState(() {
        _rutError = null; _isRutValid = false;
        _usuarioError = null; _isUsuarioValid = false;
        _correoPersonalError = null; _isCorreoPersonalValid = false;
        _telefonoError = null; _isTelefonoValid = false;
      });

      _mostrarSnackBar('¡Trabajador creado y credenciales enviadas!', const Color(0xFF2E7D32));

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _mostrarSnackBar('Ese nombre de usuario corporativo ya está tomado.', Colors.red);
      } else {
        _mostrarSnackBar('Error: ${e.message}', Colors.red);
      }
    } catch (e) {
      _mostrarSnackBar('Error inesperado: $e', Colors.red);
    } finally {
      setState(() { _isLoading = false; });
    }
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
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado en bloque RECTO idéntico a las vistas corporativas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                decoration: const BoxDecoration(color: Color(0xFF388E3C)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Módulo de Registro', style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 12),
                    Text('Crear Trabajador', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              // Formulario Principal con el padding unificado de 24
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Informativo Estilizado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(22), 
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
                        border: Border.all(color: const Color(0xFFEAEAEA))
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: const Color(0xFF388E3C), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: const Text(
                              'El sistema creará una cuenta corporativa @empresa.cl y notificará las credenciales vía EmailJS al correo personal.',
                              style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildInputField(label: 'Nombre Completo *', hint: 'Ej: Juan Pérez González', controller: _nombreController),
                    const SizedBox(height: 20),
                    
                    _buildInputField(
                      label: 'RUT *', 
                      hint: '12.345.678-9', 
                      controller: _rutController,
                      focusNode: _rutFocusNode,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9kK\.\-]')),
                        RutFormatter(),
                      ],
                    ), 
                    if (_rutError != null) ...[
                      const SizedBox(height: 6),
                      Text(_rutError!, style: TextStyle(color: _isRutValid ? const Color(0xFF388E3C) : Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 20),
                    
                    _buildInputField(
                      label: 'Usuario Corporativo *', 
                      hint: 'ej: jperez', 
                      controller: _usuarioCorporativoController, 
                      focusNode: _usuarioFocusNode,
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 16.0, top: 14.0),
                        child: Text('@empresa.cl', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    if (_usuarioError != null) ...[
                      const SizedBox(height: 6),
                      Text(_usuarioError!, style: TextStyle(color: _isUsuarioValid ? const Color(0xFF388E3C) : Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'Correo Personal (Notificación) *', 
                      hint: 'ejemplo@gmail.com', 
                      controller: _correoPersonalController, 
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _correoPersonalFocusNode,
                    ),
                    if (_correoPersonalError != null) ...[
                      const SizedBox(height: 6),
                      Text(_correoPersonalError!, style: TextStyle(color: _isCorreoPersonalValid ? const Color(0xFF388E3C) : Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 20),
                    
                    _buildInputField(
                      label: 'Teléfono', 
                      hint: 'Ej: 91234567', 
                      controller: _telefonoController, 
                      keyboardType: TextInputType.phone,
                      focusNode: _telefonoFocusNode,
                      onChanged: _formatearTelefonoEnVivo,
                      inputFormatters: [LengthLimitingTextInputFormatter(14)],
                    ),
                    if (_telefonoError != null) ...[
                      const SizedBox(height: 6),
                      Text(_telefonoError!, style: TextStyle(color: _isTelefonoValid ? const Color(0xFF388E3C) : Colors.red, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 20),

                    const Text('Rol Asignado *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(16), 
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          items: <String>['RRHH', 'Psicólogo'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 16)));
                          }).toList(),
                          onChanged: (newValue) => setState(() { _selectedRole = newValue!; }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'Clave Provisoria Autogenerada *', 
                      hint: 'Generando...', 
                      controller: _claveController, 
                      suffixIcon: IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF388E3C)), onPressed: _generarClaveAleatoria),
                    ),
                    const SizedBox(height: 36),

                    // Botón de Envíos Estilizado (Mismo alto de 56 y bordes circulares corporativos)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), 
                          elevation: 3,
                          shadowColor: Colors.black38,
                        ),
                        onPressed: _isLoading ? null : _crearTrabajadorEnFirebase,
                        icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 24),
                        label: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Crear e Informar Trabajador', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
    FocusNode? focusNode, 
    List<TextInputFormatter>? inputFormatters, 
    ValueChanged<String>? onChanged,
    Widget? suffixIcon, 
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: const Color(0xFFEAEAEA)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isObscure,
            focusNode: focusNode, 
            inputFormatters: inputFormatters, 
            onChanged: onChanged, 
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: suffixIcon, 
            ),
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
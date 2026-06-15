import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // 🟢 Prefijo para evitar colisiones si hiciera falta
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:proyecto_flutter/app/widgets/auth_text_field.dart';
// 🟢 Ocultamos 'User' de Supabase para eliminar el error de duplicado con Firebase
import 'package:supabase_flutter/supabase_flutter.dart' hide User; 

class ContainerTresLogin extends StatefulWidget {
  const ContainerTresLogin({super.key});

  @override
  State<ContainerTresLogin> createState() => _ContainerTresLoginState();
}

class _ContainerTresLoginState extends State<ContainerTresLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;
  bool _isLoading = false; 

  // Función auxiliar para el envío del correo mediante Supabase
  Future<void> _enviarCorreoAlertaAdmin(String emailDestino) async {
    try {
      await Supabase.instance.client.from('alertas_seguridad').insert({
        'correo_afectado': emailDestino,
        'tipo_evento': 'bloqueo_admin_5_intentos',
        'detalles': 'La cuenta con rol "admin" se ha bloqueado temporalmente por 10 minutos debido a 5 intentos fallidos consecutivos.'
      });
      debugPrint("Notificación de seguridad enviada a Supabase.");
    } catch (e) {
      debugPrint("Error al registrar alerta de correo en Supabase: $e");
    }
  }

  Future<void> loginUser() async {
    if (_isLoading) return;

    final emailTexto = emailController.text.trim();
    final passwordTexto = passwordController.text.trim();

    // Validaciones iniciales de formato en la UI
    if (emailTexto.isEmpty) {
      setState(() { emailError = "El correo es obligatorio"; });
      return;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailTexto)) {
      setState(() { emailError = "Formato de correo inválido"; });
      return;
    }

    if (passwordTexto.isEmpty) {
      setState(() { passwordError = "La contraseña es obligatoria"; });
      return;
    } else if (passwordTexto.length < 6) {
      setState(() { passwordError = "Debe tener al menos 6 caracteres"; });
      return;
    }

    setState(() {
      emailError = null;
      passwordError = null;
      _isLoading = true;
    });

    // 🟢 CORRECCIÓN DE SCOPE: Declaramos las variables aquí arriba para que el bloque 'catch' también pueda verlas
    DocumentReference? userDocRef;
    bool esAdmin = false;
    int intentosActuales = 0;

    try {
      // 1. Buscar al usuario en Firestore por su correo antes de acceder a Firebase Auth
      final queryUsuario = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('correo', isEqualTo: emailTexto) 
          .limit(1)
          .get();

      if (queryUsuario.docs.isNotEmpty) {
        final doc = queryUsuario.docs.first;
        userDocRef = doc.reference;
        final datos = doc.data();

        String rol = (datos['rol'] ?? datos['role'] ?? '').toString().toLowerCase();
        
        // 2. Si es un administrador, revisamos si está bloqueado en la base de datos
        if (rol == 'admin') {
          esAdmin = true;
          intentosActuales = datos['intentosFallidos'] ?? 0;

          if (datos['bloqueadoHasta'] != null) {
            DateTime bloqueadoHasta = (datos['bloqueadoHasta'] as Timestamp).toDate();
            
            if (DateTime.now().isBefore(bloqueadoHasta)) {
              setState(() {
                _isLoading = false;
                passwordError = "Cuenta bloqueada hasta ${bloqueadoHasta.hour}:${bloqueadoHasta.minute.toString().padLeft(2, '0')} por intentos fallidos. Revisa tu correo.";
              });
              return; // Frena el proceso de autenticación por completo
            } else {
              // Si la penalización de 10 minutos ya caducó, limpiamos el bloqueo de forma transparente
              await userDocRef.update({'intentosFallidos': 0, 'bloqueadoHasta': null});
              intentosActuales = 0;
            }
          }
        }
      }

      // 3. INTENTAR LA AUTENTICACIÓN CON FIREBASE AUTH (Aquí el compilador ya sabe que User es de Firebase)
      UserCredential credencialUsuario = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTexto,
        password: passwordTexto,
      );

      User? usuario = credencialUsuario.user;
      if (usuario != null && mounted) {
        
        // Si el login fue exitoso y el usuario tiene privilegios admin, limpiamos sus registros fallidos
        if (esAdmin && userDocRef != null) {
          await userDocRef.update({'intentosFallidos': 0, 'bloqueadoHasta': null});
        }

        // Lógica de enrutamiento por roles unificada
        DocumentSnapshot documentoUsuario = await FirebaseFirestore.instance.collection('usuarios').doc(usuario.uid).get();
        if (!documentoUsuario.exists) {
          documentoUsuario = await FirebaseFirestore.instance.collection('trabajadores').doc(usuario.uid).get();
        }

        if (documentoUsuario.exists && documentoUsuario.data() != null) {
          Map<String, dynamic> datosUsuario = documentoUsuario.data() as Map<String, dynamic>;
          String rol = (datosUsuario['rol'] ?? datosUsuario['role'] ?? '').toString().toLowerCase();

          setState(() { _isLoading = false; });

          if (rol == 'psicologo') {
            Navigator.pushReplacementNamed(context, 'psicologo_main');
          } else if (rol == 'rrhh') {
            Navigator.pushReplacementNamed(context, 'main'); 
          } else if (rol == 'admin') {
            Navigator.pushReplacementNamed(context, 'admin_main'); 
          } else {
            Navigator.pushReplacementNamed(context, 'main');
          }
          return; 
        } else {
          // Fallback heredado por si el perfil de desarrollo no existe en colecciones
          if (emailTexto == 'admin@empresa.cl') {
            setState(() { _isLoading = false; });
            Navigator.pushReplacementNamed(context, 'admin_main');
            return;
          } else {
            setState(() {
              passwordError = "Error: No se encontró el perfil en la base de datos.";
              _isLoading = false;
            });
            return;
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; 

      // 4. Manejo exclusivo de captura de intentos fallidos en roles administradores
      if (esAdmin && userDocRef != null) {
        intentosActuales++;

        if (intentosActuales >= 5) {
          DateTime tiempoBloqueo = DateTime.now().add(const Duration(minutes: 10));
          
          // Escribimos el bloqueo de manera persistente en Firestore
          await userDocRef.update({
            'intentosFallidos': intentosActuales,
            'bloqueadoHasta': Timestamp.fromDate(tiempoBloqueo),
          });

          // Disparar el evento de correo en Supabase
          await _enviarCorreoAlertaAdmin(emailTexto);

          setState(() {
            passwordError = "Has alcanzado el máximo de 5 intentos. Esta cuenta Administrador ha sido bloqueada por 10 minutos. Se envió un correo de alerta.";
            _isLoading = false;
          });
          return;
        } else {
          // Si no ha superado el límite, solo sumamos el intento fallido al documento
          await userDocRef.update({'intentosFallidos': intentosActuales});
        }
      }

      // Respuesta de error tradicional para usuarios genéricos o fallas ordinarias
      setState(() {
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
            passwordError = "Error al iniciar sesión: credenciales incorrectas o no existen";
            break;
          case 'invalid-email':
            emailError = "Formato de correo inválido";
            break;
          case 'user-disabled':
            emailError = "La cuenta está deshabilitada";
            break;
          default:
            passwordError = "Error al iniciar sesión: credenciales no existen o son inválidas";
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; 
      setState(() {
        passwordError = "Error inesperado: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Text(
            'Correo Electrónico',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            hint: 'usuario@empresa.cl',
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          if (emailError != null)
            Text(emailError!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 34),
          const Text(
            'Contraseña',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: passwordController,
          ),
          if (passwordError != null)
            Text(passwordError!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 72,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 5,
              ),
              onPressed: _isLoading ? null : loginUser,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
        ],
      ),
    );
  }
}
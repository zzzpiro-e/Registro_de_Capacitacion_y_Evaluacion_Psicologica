import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerRoleValidador extends StatefulWidget {
  final String rolRequerido; // Mantenemos el String simple para no romper tus rutas actuales
  final Widget child;

  const ContainerRoleValidador({
    super.key,
    required this.rolRequerido,
    required this.child,
  });

  @override
  State<ContainerRoleValidador> createState() => _ContainerRoleValidadorState();
}

class _ContainerRoleValidadorState extends State<ContainerRoleValidador> {
  bool _isAuthorized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verificarRolDeSeguridad();
  }

  Future<void> _verificarRolDeSeguridad() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _denegarAcceso();
      return;
    }

    try {
      // 1. Intentar buscar en la colección 'usuarios'
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      // 2. Si NO existe en 'usuarios', buscar en 'trabajadores'
      if (!userDoc.exists) {
        userDoc = await FirebaseFirestore.instance
            .collection('trabajadores')
            .doc(user.uid)
            .get();
      }

      // 3. Si el documento existe en cualquiera de las dos colecciones
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final String currentRole = (userData['rol'] ?? userData['role'] ?? '').toString().toLowerCase();

        // 4. Validar si el rol coincide (O si es 'admin', que tiene acceso total)
        if (currentRole == widget.rolRequerido.toLowerCase() || currentRole == 'admin') {
          setState(() {
            _isAuthorized = true;
            _isLoading = false;
          });
        } else {
          _denegarAcceso(mensaje: 'Acceso denegado: No tienes permisos para este módulo.');
        }
      } else {
        _denegarAcceso(mensaje: 'Error: Perfil no encontrado en la base de datos.');
      }
    } catch (e) {
      _denegarAcceso(mensaje: 'Error de conexión al verificar el rol de seguridad.');
    }
  }

  void _denegarAcceso({String mensaje = 'Sesión inválida. Por favor inicia sesión nuevamente.'}) {
    if (!mounted) return;
    
    // Forzar deslogueo y redirección segura
    FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red.shade800),
    );
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
      );
    }

    return _isAuthorized ? widget.child : const SizedBox.shrink();
  }
}
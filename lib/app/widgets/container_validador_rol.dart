import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerRoleValidador extends StatefulWidget {
  final String rolRequerido;
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
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final String currentRole = (userData['rol'] ?? userData['role'] ?? '').toString().toLowerCase();

        // Validar acceso y bloquear modulos cruzados si no coincide el rol
        if (currentRole == widget.rolRequerido.toLowerCase()) {
          setState(() {
            _isAuthorized = true;
            _isLoading = false;
          });
        } else {
          _denegarAcceso(mensaje: 'Acceso denegado: No tienes permisos para este módulo.');
        }
      } else {
        _denegarAcceso();
      }
    } catch (e) {
      _denegarAcceso();
    }
  }

  void _denegarAcceso({String mensaje = 'Sesión inválida. Por favor inicia sesión nuevamente.'}) {
    if (!mounted) return;
    
    // Forzar deslogueo y redireccion segura
    FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red.shade800),
    );
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
      );
    }

    // Validar permisos antes de mostrar información sensible
    return _isAuthorized ? widget.child : const SizedBox.shrink();
  }
}
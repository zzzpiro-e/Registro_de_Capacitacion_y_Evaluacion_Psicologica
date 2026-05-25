import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/auth_text_field.dart';
import 'package:proyecto_flutter/app/screens/dashboard_screen.dart';
import 'package:proyecto_flutter/app/screens/rrhh_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginAndRedirect() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa correo y contraseña')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Widget destination;

      if (email == 'admin@empresa.com') {
        destination = const DashboardPage();
      } else if (email == 'rrhh@empresa.com') {
        destination = const RrhhScreen();
      } else if (email == 'psicologo@empresa.com') {
        destination = const PsicologoScreen();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ese correo no tiene panel asignado')),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al iniciar sesión')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar sesión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header con gradiente verde ──
            _buildHeader(),

            // ── Formulario de login ──
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildLoginForm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header verde con gradiente, ícono y título
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32), // verde oscuro
            Color(0xFF43A047), // verde medio
            Color(0xFF66BB6A), // verde claro
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              // Ícono con fondo semitransparente
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.groups_2_outlined,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              const SizedBox(height: 28),

              // Título "Sistema RRHH"
              const Text(
                'Sistema RRHH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                'Gestión de Recursos Humanos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formulario de login con campos y botón
  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Bienvenido"
          const Center(
            child: Column(
              children: [
                Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ingresa tus credenciales para continuar',
                  style: TextStyle(
                    color: Color(0xFF558B2F),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Label: Correo Electrónico
          const Text(
            'Correo Electrónico',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 10),
          AuthTextField(
            hint: 'usuario@empresa.cl',
            icon: Icons.email_outlined,
            controller: _emailController,
          ),

          const SizedBox(height: 24),

          // Label: Contraseña
          const Text(
            'Contraseña',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 10),
          AuthTextField(
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: _passwordController,
          ),

          const SizedBox(height: 14),

          // "¿Olvidaste tu contraseña?"
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // TODO: Navegar a recuperar contraseña
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Botón "Iniciar Sesión →"
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF43A047).withOpacity(0.4),
              ),
              onPressed: _loginAndRedirect,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 22),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Divider
          const Divider(color: Color(0xFFE0E0E0), thickness: 1),

          const SizedBox(height: 16),

          const SizedBox(height: 8),

          // Botón de acceso rápido al Admin (atajo)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D32)),
                foregroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Atajo: navegar directamente al panel de administración
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
              child: const Text(
                'Entrar como Admin (atajo)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Footer
          const Center(
            child: Text(
              'Sistema de Gestión de Recursos Humanos',
              style: TextStyle(
                color: Color(0xFF558B2F),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

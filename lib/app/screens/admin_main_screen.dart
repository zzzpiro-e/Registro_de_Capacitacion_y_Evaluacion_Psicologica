import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_flutter/app/screens/admin_dashboard_screen.dart'; 
import 'package:proyecto_flutter/app/screens/admin_create_screen.dart'; 
import 'package:proyecto_flutter/app/screens/admin_workers_list_screen.dart'; 
import 'package:proyecto_flutter/app/screens/admin_profile_screen.dart';
import 'package:proyecto_flutter/app/screens/admin_auditoria_screen.dart';
import 'package:proyecto_flutter/app/screens/login_screen.dart'; 

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}
class _AdminMainScreenState extends State<AdminMainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0; 
  String _workersRoleFilter = 'todos';
  String _workersStatusFilter = 'todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _destruirSesionAdminPorSeguridad();
    }
  }

  void _destruirSesionAdminPorSeguridad() async {
    debugPrint("⚠️ Seguridad Admin: Detectado cierre o segundo plano. Destruyendo sesión activa...");
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Error al cerrar sesión de forma automática: $e");
    }
  }

  void _abrirTrabajadores(String filtroRol, String filtroEstado) {
    setState(() {
      _workersRoleFilter = filtroRol;
      _workersStatusFilter = filtroEstado;
      _currentIndex = 2; 
    });
  }

  void _abrirAuditoria() {
    setState(() {
      _currentIndex = 3; 
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return AdminDashboardScreen(
          onOpenWorkersTab: _abrirTrabajadores,
          onOpenAuditoriaTab: _abrirAuditoria,
        );
      case 1:
        return AdminCreateScreen(
          onReturnToInicio: () {
            setState(() {
              _currentIndex = 0; 
            });
          },
        );
      case 2:
        return AdminWorkersListScreen(
          key: ValueKey('${_workersRoleFilter}_${_workersStatusFilter}'), 
          initialRoleFilter: _workersRoleFilter,
          initialStatusFilter: _workersStatusFilter,
          onReturnToInicio: () {
            setState(() {
              _currentIndex = 0; 
            });
          },
        );
      case 3:
        return AdminAuditoriaScreen(
          onReturnToInicio: () {
            setState(() {
              _currentIndex = 0; 
            });
          },
        );
      case 4:
        return AdminProfileScreen(
          onLogout: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                'login',
                (route) => false,
              );
            }
          },
        );
      default:
        return const Center(child: Text('Página no encontrada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: _buildPage(_currentIndex), 
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            if (index != 2) {
              _workersRoleFilter = 'todos';
              _workersStatusFilter = 'todos';
            }
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_alt_1_outlined), activeIcon: Icon(Icons.person_add_alt_1), label: 'Crear'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Trabajadores'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Auditoría'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Mi perfil'),
        ],
      ),
    );
  }
}
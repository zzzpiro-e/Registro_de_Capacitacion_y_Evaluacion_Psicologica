import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_flutter/app/screens/admin_dashboard_screen.dart'; 
import 'package:proyecto_flutter/app/screens/admin_create_screen.dart'; 
import 'package:proyecto_flutter/app/screens/admin_workers_list_screen.dart'; 
import 'package:proyecto_flutter/app/screens/admin_profile_screen.dart';
import 'package:proyecto_flutter/app/screens/login_screen.dart'; 

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0; 
  String _workersRoleFilter = 'todos';
  String _workersStatusFilter = 'todos';

  @override
  void initState() {
    super.initState();
  }

  void _abrirTrabajadores(String filtroRol, String filtroEstado) {
    setState(() {
      _workersRoleFilter = filtroRol;
      _workersStatusFilter = filtroEstado;
      _currentIndex = 2;
    });
  }

  List<Widget> get _pages => [
        AdminDashboardScreen(onOpenWorkersTab: _abrirTrabajadores),
        AdminCreateScreen(),
        AdminWorkersListScreen(
          key: ValueKey(_workersRoleFilter),
          initialRoleFilter: _workersRoleFilter,
          initialStatusFilter: _workersStatusFilter,
        ),
        AdminProfileScreen(
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
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: _pages[_currentIndex], 
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
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
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Mi perfil'),
        ],
      ),
    );
  }
}
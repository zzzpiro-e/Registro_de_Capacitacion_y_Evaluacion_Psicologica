// Archivo: psicologo_main_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/screens/psicologo_dashboard_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_derivaciones_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_historial_screen.dart';
import 'package:proyecto_flutter/app/widgets/custom_psicologo_bottom_nav_bar.dart';

//  containers originales
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_1.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_2.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_3.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_4.dart';
// 🔹 NUEVOS CONTAINERS CREADOS 
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_5.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_6.dart';

class PsicologoMainScreen extends StatefulWidget {
  const PsicologoMainScreen({super.key});

  @override
  State<PsicologoMainScreen> createState() => _PsicologoMainScreenState();
}

class _PsicologoMainScreenState extends State<PsicologoMainScreen> {
  int _currentIndex = 0;
  int _dashboardRefreshTrigger = 0;
  late Future<Map<String, dynamic>?> _perfilTrabajadorFuture;

  @override
  void initState() {
    super.initState();
    _perfilTrabajadorFuture = _obtenerDatosPsicologo();
  }

  Future<Map<String, dynamic>?> _obtenerDatosPsicologo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var doc = await FirebaseFirestore.instance
            .collection('trabajadores')
            .doc(user.uid)
            .get();
        
        if (doc.exists && doc.data() != null) {
          return doc.data();
        }
      }
    } catch (e) {
      debugPrint('Error al cargar datos del psicólogo: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      PsicologoDashboardScreen(key: ValueKey('dashboard_$_dashboardRefreshTrigger')), 
      const PsicologoDerivacionesScreen(), 
      const PsicologoHistorialScreen(),    
      
      FutureBuilder<Map<String, dynamic>?>(
        future: _perfilTrabajadorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 🏢 LLAMADA AL NUEVO CONTAINER DE CARGA (_5)
            return const ContainerPerfilPsicologoCinco();
          }

          // 🏢 LLAMADA AL NUEVO CONTAINER DE DATOS POR DEFECTO (_6)
          final datosReales = snapshot.data ?? ContainerPerfilPsicologoSeis.obtenerDatosPorDefecto();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Column(
                children: [
                  ContainerPerfilPsicologoUno(datos: datosReales),
                  const SizedBox(height: 16),
                  ContainerPerfilPsicologoDos(datos: datosReales),
                  const SizedBox(height: 16),
                  ContainerPerfilPsicologoTres(datos: datosReales),
                  const SizedBox(height: 24),
                  const ContainerPerfilPsicologoCuatro(), 
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: _currentIndex == 2 || _currentIndex == 3
          ? AppBar(
              title: Text(
                _currentIndex == 2 ? 'Historial de Informes' : 'Mi Perfil',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomPsicologoBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _dashboardRefreshTrigger++; 
          });
        },
      ),
    );
  }
}
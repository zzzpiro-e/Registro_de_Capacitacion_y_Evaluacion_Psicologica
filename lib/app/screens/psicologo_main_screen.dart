import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/screens/psicologo_dashboard_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_derivaciones_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_historial_screen.dart';
import 'package:proyecto_flutter/app/widgets/custom_psicologo_bottom_nav_bar.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_1.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_2.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_3.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_4.dart';

class PsicologoMainScreen extends StatefulWidget {
  const PsicologoMainScreen({super.key});

  @override
  State<PsicologoMainScreen> createState() => _PsicologoMainScreenState();
}

class _PsicologoMainScreenState extends State<PsicologoMainScreen> {
  // Control del índice de la pestaña activa en la barra de navegación
  int _currentIndex = 0;

  // Trigger para forzar el refresco del Dashboard
  int _dashboardRefreshTrigger = 0;

  // Future para obtener los datos reales del psicólogo desde Firestore
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
        // Buscamos en la colección 'trabajadores' usando el UID del usuario logueado
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
    // Definición de las pantallas correspondientes a cada menú indexado
    final List<Widget> screens = [
      PsicologoDashboardScreen(key: ValueKey('dashboard_$_dashboardRefreshTrigger')), 
      const PsicologoDerivacionesScreen(), 
      const PsicologoHistorialScreen(),    
      
      // Vista de perfil estructurada con contenedores independientes y datos reales
      FutureBuilder<Map<String, dynamic>?>(
        future: _perfilTrabajadorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator(color: Color(0xFF388E3C))),
            );
          }

          // Mapa con datos por defecto en caso de que ocurra un error o no existan datos
          final datosReales = snapshot.data ?? {
            'nombre': 'Usuario Profesional',
            'rol': 'psicologo',
            'email': 'sin_sesion@empresa.cl',
            'telefono': '+56 9 0000 0000',
            'rut': '00.000.000-0',
            'correoPersonal': 'no_disponible@gmail.com'
          };

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Column(
                children: [
                  // Pasamos el mapa de datos reales a cada contenedor removiendo los 'const'
                  ContainerPerfilPsicologoUno(datos: datosReales),
                  const SizedBox(height: 16),
                  ContainerPerfilPsicologoDos(datos: datosReales),
                  const SizedBox(height: 16),
                  ContainerPerfilPsicologoTres(datos: datosReales),
                  const SizedBox(height: 24),
                  const ContainerPerfilPsicologoCuatro(), // Mantiene sus botones estáticos/cerrar sesión
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
      // Persistencia del estado de los componentes mediante IndexedStack
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
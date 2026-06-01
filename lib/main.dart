import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:proyecto_flutter/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto_flutter/app/widgets/container_auth_guardian.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('es_CL', null);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema RRHH',
      home: const ContainerAuthGuardian(),       // Guardián reactivo e híbrido como ruta inicial
      routes: AppRoutes.routes,                   // Mapa global de rutas unificado
      onGenerateRoute: AppRoutes.onGenerateRoute, // Ruta de fallback para errores de navegación
    );
  }
}

Future<void> loginUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print("Login exitoso");
  } catch (e) {
    print("Error al iniciar sesión: $e");
  }
}
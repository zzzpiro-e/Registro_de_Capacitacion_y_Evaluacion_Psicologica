import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:proyecto_flutter/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto_flutter/app/widgets/container_auth_guardian.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/app/widgets/widgets_crear_empleado.dart';
import 'package:proyecto_flutter/app/widgets/container_crear_capacitacion_dos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://dndfusbyblziuyufovmv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuZGZ1c2J5Ymx6aXV5dWZvdm12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA1MzIxNTcsImV4cCI6MjA5NjEwODE1N30.JpMVSlYyTslWnKC4JgScoRERgQKysdqpBOV27h-BkW8',
  );

  await initializeDateFormatting('es_CL', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmpleadosProvider()),
        ChangeNotifierProvider(create: (_) => CapacitacionesProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema RRHH',
      home:
          const ContainerAuthGuardian(), // Guardián reactivo e híbrido como ruta inicial
      routes: AppRoutes.routes, // Mapa global de rutas unificado
      onGenerateRoute: AppRoutes
          .onGenerateRoute, // Ruta de fallback para errores de navegación
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

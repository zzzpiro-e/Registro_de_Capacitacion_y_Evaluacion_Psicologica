import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:proyecto_flutter/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto_flutter/app/widgets/container_auth_guardian.dart';
//import 'package:proyecto_flutter/app/screens/admin_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Inicializa localización para español (Chile)
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
      home: const ContainerAuthGuardian(),   // Ruta inicial: login
      routes: AppRoutes.routes,               // Mapa de rutas definidas
      onGenerateRoute: AppRoutes.onGenerateRoute, // Ruta de fallback (error)
      // theme: MyTheme.myTheme,               // Si quieres agregar un tema global
    );
  }
}

Future<void> loginUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Si el login es correcto, navega al dashboard
    print("Login exitoso");
  } catch (e) {
    print("Error al iniciar sesión: $e");
  }
}

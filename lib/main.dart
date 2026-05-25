import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:proyecto_flutter/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa localización para español (Chile)
  await initializeDateFormatting('es_CL', null);

  runApp(const MainApp());
}

/// 🚀 APLICACIÓN PRINCIPAL
/// Punto de entrada limpio y minimalista que usa AppRoutes para toda la navegación.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema RRHH - Ingeniería Civil Informática',
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // Desactiva el efecto de sobre-scroll/"estiramiento" en Android/iOS
      scrollBehavior: _NoOverscrollBehavior(),
    );
  }
}

/// Comportamiento de scroll que evita el efecto de resorte/Glow/Stretch globalmente.
class _NoOverscrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // No mostrar glow ni efecto de estiramiento
  }
}

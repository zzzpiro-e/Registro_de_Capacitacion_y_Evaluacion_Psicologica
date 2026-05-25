import 'package:flutter/material.dart';
import 'package:proyecto_flutter/screens/screens.dart';
import 'package:proyecto_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:proyecto_flutter/app/screens/dashboard_screen.dart';

/// 🛣️ CLASE DE RUTAS CENTRALIZADA
///
/// Centraliza toda la configuración de navegación de la aplicación.
/// Define rutas, pantallas iniciales y manejo de errores.
///
/// VENTAJAS:
/// - Un único lugar para gestionar todas las rutas
/// - Fácil de mantener y actualizar
/// - Facilita agregar nuevas rutas o modificar existentes
/// - Desacopla la lógica de navegación del main.dart

class AppRoutes {
  /// 🏠 Ruta inicial de la aplicación
  static const String initialRoute = 'login';

  /// 🗺️ Mapa de rutas disponibles
  ///
  /// Asocia nombres de rutas [String] con constructores de pantallas [WidgetBuilder]
  /// Permite navegación nombrada a través de Navigator.pushNamed()
  static final Map<String, WidgetBuilder> routes = {
    'home': (BuildContext context) => const HomeScreen(),
    'home2': (BuildContext context) => const Home2Screen(),
    'login': (BuildContext context) => const LoginPage(),
    'admin': (BuildContext context) => const DashboardPage(),
  };

  /// ⚠️ Manejador de rutas no encontradas
  ///
  /// Se ejecuta cuando se intenta acceder a una ruta que no existe en el mapa [routes].
  /// Retorna siempre la pantalla de error [ErrorScreen].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const ErrorScreen(),
      settings: settings,
    );
  }
}

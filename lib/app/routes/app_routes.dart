import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/error_screen.dart';
import '../screens/lista_empleados_screen.dart'; // 🔹 Importa tu nueva pantalla

class AppRoutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'login': (BuildContext context) => const LoginScreen(),
    'dashboard': (BuildContext context) => const DashboardPage(),
    'empleados': (BuildContext context) => const ListaEmpleadosPage(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const ErrorScreen(),
    );
  }
}

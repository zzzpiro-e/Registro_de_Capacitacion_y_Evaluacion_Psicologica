import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/error_screen.dart';
import '../screens/lista_empleados_screen.dart';
import '../screens/perfil_empleados_screen.dart';
import '../screens/main_screen.dart';
import '../screens/psicologo_main_screen.dart';
import 'package:proyecto_flutter/app/screens/admin_main_screen.dart';
import 'package:proyecto_flutter/app/screens/crear_empleado_screens.dart';
import 'package:proyecto_flutter/app/screens/capacitaciones_screen.dart';
import 'package:proyecto_flutter/app/screens/perfil_rrhh_screens.dart';
import 'package:proyecto_flutter/app/screens/crear_capacitacion_screen.dart';
import 'package:proyecto_flutter/app/screens/editar_empleado_rrhh_screens.dart';

class AppRoutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'login': (BuildContext context) => const LoginScreen(),
    'main': (BuildContext context) => const MainScreen(),
    'admin_main': (BuildContext context) => const AdminMainScreen(),
    'dashboard': (BuildContext context) => const DashboardPage(),
    'empleados': (BuildContext context) => const ListaEmpleadosPage(),
    'perfil_empleado': (BuildContext context) => const PerfilEmpleadoScreen(),
    'psicologo_main': (BuildContext context) => const PsicologoMainScreen(),
    'crear_empleado': (BuildContext context) => const CrearEmpleadoScreen(),
    'capacitaciones': (BuildContext context) => const CapacitacionesPage(),
    'perfil_rrhh': (BuildContext context) => const PerfilRRHHScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == 'editar_empleado_rrhh') {
      // 🔹 Recibimos el argumento como Map
      final args = settings.arguments as Map<String, dynamic>;
      final empleadoId = args['empleadoId'] as String;

      return MaterialPageRoute(
        builder: (context) => EditarEmpleadoRRHHScreen(empleadoId: empleadoId),
      );
    }

    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}

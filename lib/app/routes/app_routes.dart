import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/error_screen.dart';
import '../screens/lista_empleados_screen.dart';
import '../screens/perfil_empleados_screen.dart';
import '../screens/main_screen.dart';
import '../screens/psicologo_main_screen.dart';
import 'package:proyecto_flutter/app/screens/admin_main_screen.dart';
import 'package:proyecto_flutter/app/screens/create_worker_screen.dart';
// 🔹 Cuando tengas listas estas pantallas, las importas también:
// import '../screens/capacitaciones_screen.dart';
// import '../screens/crear_screen.dart';

class AppRoutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'login': (BuildContext context) => const LoginScreen(),
    'main': (BuildContext context) => const MainScreen(),
    'admin_main':(BuildContext context) => const AdminMainScreen(),
    'dashboard': (BuildContext context) => const DashboardPage(),
    'empleados': (BuildContext context) => const ListaEmpleadosPage(),
    'perfil_empleado': (BuildContext context) => const PerfilEmpleadoScreen(),
    'psicologo_main': (BuildContext context) => const PsicologoMainScreen(),
    'create_worker': (context) => const CreateWorkerScreen(), 
    // 'capacitaciones': (BuildContext context) => const CapacitacionesPage(),
    // 'crear': (BuildContext context) => const CrearPage(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const ErrorScreen(),
    );
  }
}

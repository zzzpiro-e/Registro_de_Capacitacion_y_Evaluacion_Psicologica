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
import 'package:proyecto_flutter/app/widgets/container_validador_rol.dart';
// import '../screens/capacitaciones_screen.dart';
// import '../screens/crear_screen.dart';

class AppRoutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'login': (BuildContext context) => const LoginScreen(),
    // Validar acceso a modulo rrhh solo si el rol es rrhh
    'main': (BuildContext context) => const ContainerRoleValidador(
          rolRequerido: 'rrhh',
          child: MainScreen(),
        ),
    // Validar acceso a modulo admin solo si el rol es admin
    'admin_main': (BuildContext context) => const ContainerRoleValidador(
          rolRequerido: 'admin',
          child: AdminMainScreen(),
        ),
    // Validar acceso a modulo psicologo solo si el rol es psicologo
    'psicologo_main': (BuildContext context) => const ContainerRoleValidador(
          rolRequerido: 'psicologo',
          child: PsicologoMainScreen(),
        ),
    'dashboard': (BuildContext context) => const DashboardPage(),
    'empleados': (BuildContext context) => const ListaEmpleadosPage(),
    'perfil_empleado': (BuildContext context) => const PerfilEmpleadoScreen(),
    'create_worker': (context) => const CreateWorkerScreen(), 
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const ErrorScreen(),
    );
  }
}

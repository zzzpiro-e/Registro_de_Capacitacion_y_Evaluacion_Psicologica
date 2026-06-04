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
import 'package:proyecto_flutter/app/screens/crear_empleado_screens.dart';
import 'package:proyecto_flutter/app/screens/capacitaciones_screen.dart';
import 'package:proyecto_flutter/app/screens/perfil_rrhh_screens.dart';
import 'package:proyecto_flutter/app/widgets/container_validador_rol.dart';
import 'package:proyecto_flutter/app/screens/crear_capacitacion_screen.dart';
import 'package:proyecto_flutter/app/screens/editar_empleado_rrhh_screens.dart';

class AppRoutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'login': (BuildContext context) => const LoginScreen(),
    'main': (BuildContext context) => const ContainerRoleValidador(
          rolRequerido: 'rrhh',
          child: MainScreen(),
        ),
    'admin_main': (BuildContext context) => const ContainerRoleValidador(
          rolRequerido: 'admin',
          child: AdminMainScreen(),
        ),
    'psicologo_main': (BuildContext context) => const ContainerRoleValidador(
          rolRequerido: 'psicologo',
          child: PsicologoMainScreen(),
        ),
    'dashboard': (BuildContext context) => const DashboardPage(),
    'empleados': (BuildContext context) => const ListaEmpleadosPage(),
    'perfil_empleado': (BuildContext context) => const PerfilEmpleadoScreen(),
    'create_worker': (context) => const CreateWorkerScreen(),
    'crear_empleado': (context) => const CrearEmpleadoScreen(),
    'capacitaciones': (BuildContext context) => const CapacitacionesPage(),
    'perfil_rrhh': (BuildContext context) => const PerfilRRHHScreen(),
    'crear_capacitacion': (context) => const CrearCapacitacionScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == 'editar_empleado_rrhh') {
      final args = settings.arguments as Map<String, dynamic>;
      final empleadoId = args['empleadoId'] as String;

      return MaterialPageRoute(
        builder: (context) => EditarEmpleadoRRHHScreen(empleadoId: empleadoId),
      );
    }

    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}

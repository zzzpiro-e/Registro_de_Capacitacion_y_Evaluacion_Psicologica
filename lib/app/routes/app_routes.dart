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
import '../screens/visor_pdf_screen.dart';
import 'package:proyecto_flutter/app/screens/editar_trabajador_admin_screen.dart';
import '../screens/psicologo_historial_informes_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_flutter/app/screens/comprobante_preview_screen.dart';
//import 'package:firebase_core/firebase_core.dart';

class AppRoutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'login': (BuildContext context) => const LoginScreen(),
    

    'main': (BuildContext context) => const ContainerRoleValidador(
          rolRequerido: 'rrhh',
          child: MainScreen(),
        ),

    'admin_main': (BuildContext context) => ContainerRoleValidador(
          rolRequerido: 'rrhh', 
          child: AdminMainScreen(), // Sin const
        ),
        
    'psicologo_main': (BuildContext context) => const ContainerRoleValidador(
          rolRequerido: 'psicologo',
          child: PsicologoMainScreen(),
        ),
        
    // Rutas de módulos internos
    'dashboard': (BuildContext context) => const DashboardPage(),
    'empleados': (BuildContext context) => const ListaEmpleadosPage(),
    'perfil_empleado': (BuildContext context) => const PerfilEmpleadoScreen(),
    'create_worker': (context) => const CreateWorkerScreen(),
    'crear_empleado': (context) => const CrearEmpleadoScreen(),
    'capacitaciones': (BuildContext context) => const CapacitacionesPage(),
    'perfil_rrhh': (BuildContext context) => const PerfilRRHHScreen(),
    'crear_capacitacion': (context) => const CrearCapacitacionScreen(),
    'visor_pdf': (BuildContext context) => const VisorPdfScreen(),
    'historial_informes': (BuildContext context) => const HistorialInformesScreen(),
    'comprobante_preview': (BuildContext context) => const ComprobantePreviewScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == 'editar_empleado_rrhh') {
      final args = settings.arguments as Map<String, dynamic>;
      final empleadoId = args['empleadoId'] as String;

      return MaterialPageRoute(
        builder: (context) => EditarEmpleadoRRHHScreen(empleadoId: empleadoId),
      );
    }

    if (settings.name == 'editar_trabajador_admin') {
      final args = settings.arguments as Map<String, dynamic>;
      final trabajadorId = args['trabajadorId'] as String;

      return MaterialPageRoute(
        builder: (context) => EditarTrabajadorAdminScreen(trabajadorId: trabajadorId),
      );
    }

    return MaterialPageRoute(builder: (context) => const ErrorScreen());
  }
}

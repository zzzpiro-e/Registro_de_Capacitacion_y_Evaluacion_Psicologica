import 'package:flutter/material.dart';

export 'package:proyecto_flutter/app/widgets/container_crear_empleado_1.dart';
export 'package:proyecto_flutter/app/widgets/container_crear_empleado_2.dart';
export 'package:proyecto_flutter/app/widgets/icon_text.dart';

class EmpleadosProvider extends ChangeNotifier {
  int _version = 0;
  int get version => _version;

  void notificarNuevoEmpleado() {
    _version++;
    notifyListeners();
  }
}

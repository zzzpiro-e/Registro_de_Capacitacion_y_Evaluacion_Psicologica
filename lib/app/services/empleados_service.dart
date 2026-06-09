import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

class EmpleadosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> obtenerEmpleados() {
    return _firestore.collection('empleados').snapshots();
  }

  List<Map<String, dynamic>> convertirEmpleados(
    QuerySnapshot snapshot,
  ) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return {
        'id': doc.id,
        'nombres': data['nombres'] ?? '',
        'apellidos': data['apellidos'] ?? '',
        'rut': data['rut'] ?? '',
        'estado': data['estado'] ?? '',
      };
    }).toList();
  }

  List<Map<String, dynamic>> filtrarEmpleados(
    List<Map<String, dynamic>> empleados,
    String query,
  ) {
    final queryNormalizado = TextUtils.quitarTildes(
      query.toLowerCase(),
    );

    return empleados.where((empleado) {
      final nombreCompleto =
          "${empleado['nombres']} ${empleado['apellidos']}"
              .toLowerCase();

      final rutNormalizado =
          empleado['rut'].replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      return nombreCompleto.contains(queryNormalizado) ||
          rutNormalizado.contains(queryNormalizado);
    }).toList();
  }
} 
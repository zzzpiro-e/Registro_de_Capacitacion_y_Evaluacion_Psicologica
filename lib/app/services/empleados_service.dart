import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

class EmpleadosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> obtenerEmpleados() {
    return _firestore.collection('empleados').snapshots();
  }

  // BÚSQUEDA OPTIMIZADA (para mayúsculas - va a Firestore)
  Stream<QuerySnapshot> buscarEnFirestore(String query) {
    return _firestore
        .collection('empleados')
        .where('nombres', isGreaterThanOrEqualTo: query)
        .where('nombres', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(50)
        .snapshots();
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

  // FILTRO EN MEMORIA (para minúsculas y tildes)
  List<Map<String, dynamic>> filtrarEmpleados(
    List<Map<String, dynamic>> empleados,
    String query,
  ) {
    if (query.isEmpty) return empleados;
    
    final queryNormalizado = TextUtils.quitarTildes(
      query.toLowerCase(),
    );

    return empleados.where((empleado) {
      final nombreCompleto =
          "${empleado['nombres']} ${empleado['apellidos']}"
              .toLowerCase();
      final nombreCompletoNormalizado = TextUtils.quitarTildes(nombreCompleto);

      final rutNormalizado =
          empleado['rut'].replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      return nombreCompletoNormalizado.contains(queryNormalizado) ||
          rutNormalizado.contains(queryNormalizado);
    }).toList();
  }

  // Detectar si la búsqueda es "exacta en mayúsculas"
  bool esBusquedaMayusculas(String query) {
    // Si la query tiene al menos una letra mayúscula y no tiene minúsculas
    return query.contains(RegExp(r'[A-Z]')) && !query.contains(RegExp(r'[a-z]'));
  }
}
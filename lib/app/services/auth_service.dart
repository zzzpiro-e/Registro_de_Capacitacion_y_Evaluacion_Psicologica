import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      UserCredential credencial = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? usuario = credencial.user;

      if (usuario == null) {
        return {
          'success': false,
          'message': 'No se pudo obtener el usuario.',
        };
      }

      DocumentSnapshot documentoUsuario = await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (!documentoUsuario.exists) {
        documentoUsuario = await _firestore
            .collection('trabajadores')
            .doc(usuario.uid)
            .get();
      }

      if (documentoUsuario.exists &&
          documentoUsuario.data() != null) {
        final datos =
            documentoUsuario.data() as Map<String, dynamic>;

        final rol = (datos['rol'] ?? datos['role'] ?? '')
            .toString()
            .toLowerCase();

        return {
          'success': true,
          'rol': rol,
        };
      }

      if (email == 'admin@empresa.cl') {
        return {
          'success': true,
          'rol': 'admin',
        };
      }

      return {
        'success': false,
        'message':
            'No se encontró el perfil en la base de datos.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'errorCode': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
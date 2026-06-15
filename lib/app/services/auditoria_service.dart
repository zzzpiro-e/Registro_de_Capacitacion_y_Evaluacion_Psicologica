import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Tipos de evento para el historial de auditoría del sistema
enum TipoAuditoria {
  cambioRol,
  modificacionUsuario,
  creacionUsuario,
  eliminacionUsuario,
  cambioEstado,       // activar / desactivar
  loginSistema,
  creacionCapacitacion,
  modificacionCapacitacion,
  eliminacionCapacitacion,
  creacionDerivacion,
  actualizacionDerivacion,
  otro,
}

extension TipoAuditoriaExt on TipoAuditoria {
  String get value {
    switch (this) {
      case TipoAuditoria.cambioRol:            return 'cambio_rol';
      case TipoAuditoria.modificacionUsuario:  return 'modificacion_usuario';
      case TipoAuditoria.creacionUsuario:      return 'creacion_usuario';
      case TipoAuditoria.eliminacionUsuario:   return 'eliminacion_usuario';
      case TipoAuditoria.cambioEstado:         return 'cambio_estado';
      case TipoAuditoria.loginSistema:         return 'login';
      case TipoAuditoria.creacionCapacitacion: return 'creacion_capacitacion';
      case TipoAuditoria.modificacionCapacitacion: return 'modificacion_capacitacion';
      case TipoAuditoria.eliminacionCapacitacion:  return 'eliminacion_capacitacion';
      case TipoAuditoria.creacionDerivacion:   return 'creacion_derivacion';
      case TipoAuditoria.actualizacionDerivacion: return 'actualizacion_derivacion';
      case TipoAuditoria.otro:                 return 'otro';
    }
  }

  String get label {
    switch (this) {
      case TipoAuditoria.cambioRol:            return 'Cambio de Rol';
      case TipoAuditoria.modificacionUsuario:  return 'Modificación';
      case TipoAuditoria.creacionUsuario:      return 'Nuevo Usuario';
      case TipoAuditoria.eliminacionUsuario:   return 'Eliminación';
      case TipoAuditoria.cambioEstado:         return 'Cambio de Estado';
      case TipoAuditoria.loginSistema:         return 'Acceso';
      case TipoAuditoria.creacionCapacitacion: return 'Nueva Capacitación';
      case TipoAuditoria.modificacionCapacitacion: return 'Edición Capacitación';
      case TipoAuditoria.eliminacionCapacitacion:  return 'Eliminar Capacitación';
      case TipoAuditoria.creacionDerivacion:   return 'Nueva Derivación';
      case TipoAuditoria.actualizacionDerivacion: return 'Actualización Derivación';
      case TipoAuditoria.otro:                 return 'Evento';
    }
  }
}

class AuditoriaService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ─── Core ───────────────────────────────────────────────────────────────────

  static Future<void> registrar({
    required TipoAuditoria tipo,
    required String descripcion,
    String? modulo,           // 'admin' | 'rrhh' | 'psicologo'
    String? rolQuien,         // rol del actor
    String? rolAnterior,
    String? rolNuevo,
    Map<String, dynamic>? datosExtra,
  }) async {
    try {
      final user  = _auth.currentUser;
      final quien = user?.email ?? 'Sistema';

      await _db.collection('auditoria').add({
        'tipo':        tipo.value,
        'quien':       quien,
        'descripcion': descripcion,
        if (modulo    != null) 'modulo':      modulo,
        if (rolQuien  != null) 'rolQuien':    rolQuien,
        if (rolAnterior != null) 'rolAnterior': rolAnterior,
        if (rolNuevo    != null) 'rolNuevo':    rolNuevo,
        'fecha': FieldValue.serverTimestamp(),
        if (datosExtra != null) ...datosExtra,
      });
    } catch (e) {
      debugPrint('[AuditoriaService] Error al registrar: $e');
    }
  }

  // ─── ADMIN ──────────────────────────────────────────────────────────────────

  /// Admin creó un nuevo usuario
  static Future<void> adminCreoUsuario({
    required String nombre,
    required String rol,
    required String email,
  }) async {
    await registrar(
      tipo: TipoAuditoria.creacionUsuario,
      descripcion: 'Admin creó al usuario "$nombre" con rol $rol',
      modulo: 'admin',
      rolQuien: 'admin',
      datosExtra: {'nombre': nombre, 'rol': rol, 'email': email},
    );
  }

  /// Admin cambió el rol de un usuario
  static Future<void> adminCambioRol({
    required String nombre,
    required String rolAnterior,
    required String rolNuevo,
  }) async {
    await registrar(
      tipo: TipoAuditoria.cambioRol,
      descripcion: 'Admin cambió el rol de "$nombre": $rolAnterior → $rolNuevo',
      modulo: 'admin',
      rolQuien: 'admin',
      rolAnterior: rolAnterior,
      rolNuevo: rolNuevo,
      datosExtra: {'nombre': nombre},
    );
  }

  /// Admin modificó datos de un usuario
  static Future<void> adminModificoUsuario({
    required String nombre,
    required List<String> campos,
    Map<String, dynamic>? camposAntes,
    Map<String, dynamic>? camposDespues,
  }) async {
    await registrar(
      tipo: TipoAuditoria.modificacionUsuario,
      descripcion: 'Admin editó datos de "$nombre": ${campos.join(", ")}',
      modulo: 'admin',
      rolQuien: 'admin',
      datosExtra: {
        'nombre': nombre,
        'campos': campos,
        if (camposAntes    != null) 'camposAntes':    camposAntes,
        if (camposDespues  != null) 'camposDespues':  camposDespues,
      },
    );
  }

  /// Admin cambió estado activo/inactivo
  static Future<void> adminCambioEstado({
    required String nombre,
    required bool activado,
  }) async {
    await registrar(
      tipo: TipoAuditoria.cambioEstado,
      descripcion: 'Admin ${activado ? "activó" : "desactivó"} al usuario "$nombre"',
      modulo: 'admin',
      rolQuien: 'admin',
      datosExtra: {'nombre': nombre, 'activo': activado},
    );
  }

  /// Admin eliminó un usuario
  static Future<void> adminEliminoUsuario({required String nombre}) async {
    await registrar(
      tipo: TipoAuditoria.eliminacionUsuario,
      descripcion: 'Admin eliminó al usuario "$nombre"',
      modulo: 'admin',
      rolQuien: 'admin',
      datosExtra: {'nombre': nombre},
    );
  }

  // ─── RRHH ───────────────────────────────────────────────────────────────────

  /// RRHH creó una capacitación
  static Future<void> rrhhCreoCapacitacion({required String titulo}) async {
    await registrar(
      tipo: TipoAuditoria.creacionCapacitacion,
      descripcion: 'RRHH creó la capacitación "$titulo"',
      modulo: 'rrhh',
      rolQuien: 'rrhh',
      datosExtra: {'titulo': titulo},
    );
  }

  /// RRHH modificó una capacitación
  static Future<void> rrhhModificoCapacitacion({
    required String titulo,
    required List<String> campos,
  }) async {
    await registrar(
      tipo: TipoAuditoria.modificacionCapacitacion,
      descripcion: 'RRHH editó la capacitación "$titulo": ${campos.join(", ")}',
      modulo: 'rrhh',
      rolQuien: 'rrhh',
      datosExtra: {'titulo': titulo, 'campos': campos},
    );
  }

  /// RRHH eliminó una capacitación
  static Future<void> rrhhEliminoCapacitacion({required String titulo}) async {
    await registrar(
      tipo: TipoAuditoria.eliminacionCapacitacion,
      descripcion: 'RRHH eliminó la capacitación "$titulo"',
      modulo: 'rrhh',
      rolQuien: 'rrhh',
      datosExtra: {'titulo': titulo},
    );
  }

  /// RRHH editó el perfil de un empleado
  static Future<void> rrhhEditoEmpleado({
    required String nombre,
    required List<String> campos,
    Map<String, dynamic>? camposAntes,
    Map<String, dynamic>? camposDespues,
  }) async {
    await registrar(
      tipo: TipoAuditoria.modificacionUsuario,
      descripcion: 'RRHH editó el perfil de "$nombre": ${campos.join(", ")}',
      modulo: 'rrhh',
      rolQuien: 'rrhh',
      datosExtra: {
        'nombre': nombre,
        'campos': campos,
        if (camposAntes    != null) 'camposAntes':    camposAntes,
        if (camposDespues  != null) 'camposDespues':  camposDespues,
      },
    );
  }

  // ─── PSICÓLOGO ──────────────────────────────────────────────────────────────

  /// Psicólogo creó una derivación
  static Future<void> psicologoCreoDerivacion({
    required String nombreEmpleado,
    required String motivo,
  }) async {
    await registrar(
      tipo: TipoAuditoria.creacionDerivacion,
      descripcion: 'Psicólogo abrió derivación para "$nombreEmpleado": $motivo',
      modulo: 'psicologo',
      rolQuien: 'psicologo',
      datosExtra: {'empleado': nombreEmpleado, 'motivo': motivo},
    );
  }

  /// Psicólogo actualizó una derivación
  static Future<void> psicologoActualizoDerivacion({
    required String nombreEmpleado,
    required String estadoNuevo,
  }) async {
    await registrar(
      tipo: TipoAuditoria.actualizacionDerivacion,
      descripcion: 'Psicólogo actualizó derivación de "$nombreEmpleado" → $estadoNuevo',
      modulo: 'psicologo',
      rolQuien: 'psicologo',
      datosExtra: {'empleado': nombreEmpleado, 'estado': estadoNuevo},
    );
  }
}

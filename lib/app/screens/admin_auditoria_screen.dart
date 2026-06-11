import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_flutter/app/services/auditoria_service.dart';

class AdminAuditoriaScreen extends StatefulWidget {
  const AdminAuditoriaScreen({super.key});

  @override
  State<AdminAuditoriaScreen> createState() => _AdminAuditoriaScreenState();
}

class _AdminAuditoriaScreenState extends State<AdminAuditoriaScreen> {
  String _filtroTipo   = 'todos';
  String _filtroModulo = 'todos';

  final List<Map<String, dynamic>> _filtrosTipo = [
    {'label': 'Todos',        'valor': 'todos',                  'icon': Icons.list_alt_outlined},
    {'label': 'Roles',        'valor': 'cambio_rol',             'icon': Icons.manage_accounts_outlined},
    {'label': 'Usuarios',     'valor': 'modificacion_usuario',   'icon': Icons.edit_outlined},
    {'label': 'Creaciones',   'valor': 'creacion_usuario',       'icon': Icons.person_add_alt_1_outlined},
    {'label': 'Estado',       'valor': 'cambio_estado',          'icon': Icons.toggle_on_outlined},
    {'label': 'Capacitac.',   'valor': 'creacion_capacitacion',  'icon': Icons.school_outlined},
    {'label': 'Derivaciones', 'valor': 'creacion_derivacion',    'icon': Icons.psychology_outlined},
  ];

  final List<Map<String, dynamic>> _filtrosModulo = [
    {'label': 'Todos',      'valor': 'todos',      'color': const Color(0xFF546E7A)},
    {'label': 'Admin',      'valor': 'admin',      'color': const Color(0xFF6A1B9A)},
    {'label': 'RRHH',       'valor': 'rrhh',       'color': const Color(0xFF1565C0)},
    {'label': 'Psicólogo',  'valor': 'psicologo',  'color': const Color(0xFF00695C)},
  ];

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'cambio_rol':               return const Color(0xFF7B1FA2);
      case 'modificacion_usuario':     return const Color(0xFF1565C0);
      case 'creacion_usuario':         return const Color(0xFF2E7D32);
      case 'eliminacion_usuario':      return const Color(0xFFC62828);
      case 'cambio_estado':            return const Color(0xFFE65100);
      case 'login':                    return const Color(0xFF00695C);
      case 'creacion_capacitacion':    return const Color(0xFF1976D2);
      case 'modificacion_capacitacion':return const Color(0xFF0288D1);
      case 'eliminacion_capacitacion': return const Color(0xFFB71C1C);
      case 'creacion_derivacion':      return const Color(0xFF00796B);
      case 'actualizacion_derivacion': return const Color(0xFF00897B);
      default:                         return const Color(0xFF546E7A);
    }
  }

  IconData _iconPorTipo(String tipo) {
    switch (tipo) {
      case 'cambio_rol':               return Icons.manage_accounts_outlined;
      case 'modificacion_usuario':     return Icons.edit_note_outlined;
      case 'creacion_usuario':         return Icons.person_add_alt_1_outlined;
      case 'eliminacion_usuario':      return Icons.person_off_outlined;
      case 'cambio_estado':            return Icons.toggle_on_outlined;
      case 'login':                    return Icons.login_outlined;
      case 'creacion_capacitacion':    return Icons.school_outlined;
      case 'modificacion_capacitacion':return Icons.edit_calendar_outlined;
      case 'eliminacion_capacitacion': return Icons.delete_outline;
      case 'creacion_derivacion':      return Icons.psychology_outlined;
      case 'actualizacion_derivacion': return Icons.update_outlined;
      default:                         return Icons.history_outlined;
    }
  }

  Color _colorModulo(String? modulo) {
    switch (modulo) {
      case 'admin':     return const Color(0xFF6A1B9A);
      case 'rrhh':      return const Color(0xFF1565C0);
      case 'psicologo': return const Color(0xFF00695C);
      default:          return const Color(0xFF546E7A);
    }
  }

  String _labelModulo(String? modulo) {
    switch (modulo) {
      case 'admin':     return 'Admin';
      case 'rrhh':      return 'RRHH';
      case 'psicologo': return 'Psicólogo';
      default:          return 'Sistema';
    }
  }

  // ─── Abre el panel de detalle ────────────────────────────────────────────────
  void _abrirDetalle(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetalleAuditoria(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.security_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Panel de Administración',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
                const SizedBox(height: 10),
                const Text('Historial & Auditoría',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Toca cualquier registro para ver el detalle completo',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Filtro módulo ───────────────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtrosModulo.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f   = _filtrosModulo[i];
                final sel = _filtroModulo == f['valor'];
                final col = f['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _filtroModulo = f['valor']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? col : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sel ? col : const Color(0xFFDDDDDD)),
                    ),
                    child: Text(f['label'] as String,
                        style: TextStyle(
                          color: sel ? Colors.white : Colors.grey[700],
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        )),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ── Filtro tipo ─────────────────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtrosTipo.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f   = _filtrosTipo[i];
                final sel = _filtroTipo == f['valor'];
                return GestureDetector(
                  onTap: () => setState(() => _filtroTipo = f['valor']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF43A047) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: sel ? const Color(0xFF43A047) : const Color(0xFFDDDDDD)),
                    ),
                    child: Row(children: [
                      Icon(f['icon'] as IconData,
                          size: 14,
                          color: sel ? Colors.white : Colors.grey[600]),
                      const SizedBox(width: 5),
                      Text(f['label'] as String,
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.grey[700],
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          )),
                    ]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // ── Lista ───────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('auditoria')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF43A047)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState();
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final tipoOk   = _filtroTipo   == 'todos' || d['tipo']   == _filtroTipo;
                  final moduloOk = _filtroModulo  == 'todos' || d['modulo'] == _filtroModulo;
                  return tipoOk && moduloOk;
                }).toList();

                if (docs.isEmpty) return _emptyState();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index].data() as Map<String, dynamic>;
                    return _eventCard(d);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(Map<String, dynamic> data) {
    final String tipo        = data['tipo']        ?? 'otro';
    final String quien       = data['quien']       ?? 'Sistema';
    final String descripcion = data['descripcion'] ?? '';
    final String? rolAnterior = data['rolAnterior'];
    final String? rolNuevo    = data['rolNuevo'];
    final String? modulo      = data['modulo'];
    final bool tieneDetalle   = data['camposAntes'] != null || data['camposDespues'] != null;
    final Color  color        = _colorPorTipo(tipo);
    final Color  colorMod     = _colorModulo(modulo);

    String fechaStr = '';
    if (data['fecha'] != null) {
      fechaStr = DateFormat("d MMM yyyy, HH:mm", 'es_ES')
          .format((data['fecha'] as Timestamp).toDate());
    }

    return GestureDetector(
      onTap: () => _abrirDetalle(data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: tieneDetalle
                ? color.withOpacity(0.25)
                : const Color(0xFFF0F0F0),
            width: tieneDetalle ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_iconPorTipo(tipo), color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _badge(tipo.label, color),
                        const SizedBox(width: 6),
                        if (modulo != null)
                          _badge(_labelModulo(modulo), colorMod),
                        const Spacer(),
                        Text(fechaStr,
                            style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.person_outline, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(quien,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333)),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(descripcion,
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                    // Cambio de rol visual
                    if (rolAnterior != null && rolNuevo != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F0FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE1BEE7)),
                        ),
                        child: Row(children: [
                          _rolChip(rolAnterior, isOld: true),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward, size: 14, color: Colors.purple),
                          ),
                          _rolChip(rolNuevo, isOld: false),
                        ]),
                      ),
                    ],
                    // Indicador de que hay detalle disponible
                    if (tieneDetalle) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.touch_app_outlined, size: 12, color: color.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text('Ver campos modificados',
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  ],
                ),
              ),
              // Chevron
              Icon(Icons.chevron_right, color: Colors.grey[300], size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Widget _rolChip(String rol, {required bool isOld}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isOld
              ? Colors.grey[200]
              : const Color(0xFF43A047).withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(rol.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isOld ? Colors.grey[700] : const Color(0xFF2E7D32),
            )),
      );

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.history_outlined,
                  size: 36, color: Color(0xFF43A047)),
            ),
            const SizedBox(height: 14),
            const Text('Sin registros aún',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333))),
            const SizedBox(height: 6),
            const Text('Los cambios del sistema aparecerán aquí',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
}

// ─── PANEL DETALLE ────────────────────────────────────────────────────────────

class _DetalleAuditoria extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DetalleAuditoria({required this.data});

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'cambio_rol':               return const Color(0xFF7B1FA2);
      case 'modificacion_usuario':     return const Color(0xFF1565C0);
      case 'creacion_usuario':         return const Color(0xFF2E7D32);
      case 'eliminacion_usuario':      return const Color(0xFFC62828);
      case 'cambio_estado':            return const Color(0xFFE65100);
      case 'creacion_capacitacion':    return const Color(0xFF1976D2);
      case 'modificacion_capacitacion':return const Color(0xFF0288D1);
      case 'actualizacion_derivacion': return const Color(0xFF00897B);
      default:                         return const Color(0xFF546E7A);
    }
  }

  Color _colorModulo(String? modulo) {
    switch (modulo) {
      case 'admin':     return const Color(0xFF6A1B9A);
      case 'rrhh':      return const Color(0xFF1565C0);
      case 'psicologo': return const Color(0xFF00695C);
      default:          return const Color(0xFF546E7A);
    }
  }

  String _labelModulo(String? modulo) {
    switch (modulo) {
      case 'admin':     return 'Admin';
      case 'rrhh':      return 'RRHH';
      case 'psicologo': return 'Psicólogo';
      default:          return 'Sistema';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tipo        = data['tipo']        ?? 'otro';
    final String quien       = data['quien']       ?? 'Sistema';
    final String descripcion = data['descripcion'] ?? '';
    final String? rolAnterior = data['rolAnterior'];
    final String? rolNuevo    = data['rolNuevo'];
    final String? modulo      = data['modulo'];
    final Color  color        = _colorPorTipo(tipo);
    final Color  colorMod     = _colorModulo(modulo);

    // Campos antes/después
    final Map<String, dynamic> camposAntes   =
        Map<String, dynamic>.from(data['camposAntes']   ?? {});
    final Map<String, dynamic> camposDespues =
        Map<String, dynamic>.from(data['camposDespues'] ?? {});

    // Unión de todas las claves de campos modificados
    final Set<String> allKeys = {...camposAntes.keys, ...camposDespues.keys};

    String fechaStr = '';
    if (data['fecha'] != null) {
      fechaStr = DateFormat("EEEE, d 'de' MMMM yyyy · HH:mm", 'es_ES')
          .format((data['fecha'] as Timestamp).toDate());
      fechaStr = fechaStr.substring(0, 1).toUpperCase() + fechaStr.substring(1);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Barra superior con título y botón cerrar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(_iconPorTipo(tipo), color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Detalle del Registro',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 16, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Contenido scrollable
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Badges
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _badge(tipo.label, color),
                      _badge(_labelModulo(modulo), colorMod),
                    ]),
                    const SizedBox(height: 16),

                    // Quién y cuándo
                    _infoRow(Icons.person_outline, 'Realizado por', quien),
                    const SizedBox(height: 10),
                    if (fechaStr.isNotEmpty)
                      _infoRow(Icons.access_time_outlined, 'Fecha y hora', fechaStr),
                    const SizedBox(height: 10),
                    _infoRow(Icons.description_outlined, 'Descripción', descripcion),

                    // Cambio de rol
                    if (rolAnterior != null && rolNuevo != null) ...[
                      const SizedBox(height: 20),
                      _seccionTitulo('Cambio de Rol', Icons.manage_accounts_outlined, color),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F0FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE1BEE7)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _rolChip(rolAnterior, isOld: true),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.arrow_forward,
                                  color: Colors.purple, size: 20),
                            ),
                            _rolChip(rolNuevo, isOld: false),
                          ],
                        ),
                      ),
                    ],

                    // Campos modificados (antes → después)
                    if (allKeys.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _seccionTitulo(
                          '${allKeys.length} campo${allKeys.length > 1 ? "s" : ""} modificado${allKeys.length > 1 ? "s" : ""}',
                          Icons.compare_arrows_outlined,
                          color),
                      const SizedBox(height: 10),
                      ...allKeys.map((campo) => _campoDiff(
                            campo: campo,
                            antes: camposAntes[campo]?.toString() ?? '—',
                            despues: camposDespues[campo]?.toString() ?? '—',
                            color: color,
                          )),
                    ],

                    // Si no hay diff pero hay campos de datos extra
                    if (allKeys.isEmpty && rolAnterior == null) ...[
                      const SizedBox(height: 20),
                      _seccionTitulo('Información adicional',
                          Icons.info_outline, Colors.blueGrey),
                      const SizedBox(height: 10),
                      ..._extraFields(data),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Ícono por tipo (duplicado local para no depender del state) ──────────────
  IconData _iconPorTipo(String tipo) {
    switch (tipo) {
      case 'cambio_rol':               return Icons.manage_accounts_outlined;
      case 'modificacion_usuario':     return Icons.edit_note_outlined;
      case 'creacion_usuario':         return Icons.person_add_alt_1_outlined;
      case 'eliminacion_usuario':      return Icons.person_off_outlined;
      case 'cambio_estado':            return Icons.toggle_on_outlined;
      case 'login':                    return Icons.login_outlined;
      case 'creacion_capacitacion':    return Icons.school_outlined;
      case 'modificacion_capacitacion':return Icons.edit_calendar_outlined;
      case 'eliminacion_capacitacion': return Icons.delete_outline;
      case 'creacion_derivacion':      return Icons.psychology_outlined;
      case 'actualizacion_derivacion': return Icons.update_outlined;
      default:                         return Icons.history_outlined;
    }
  }

  // ── Widgets auxiliares ───────────────────────────────────────────────────────

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );

  Widget _infoRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );

  Widget _seccionTitulo(String titulo, IconData icon, Color color) => Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(titulo,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      );

  Widget _campoDiff({
    required String campo,
    required String antes,
    required String despues,
    required Color color,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del campo
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Text(campo,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color)),
            ),
            // Antes
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.remove_circle_outline,
                              size: 13, color: Color(0xFFC62828)),
                          SizedBox(width: 4),
                          Text('Antes',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFC62828),
                                  fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3F3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFFFCDD2)),
                          ),
                          child: Text(antes,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFC62828),
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward,
                        size: 16, color: Colors.grey),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.add_circle_outline,
                              size: 13, color: Color(0xFF2E7D32)),
                          SizedBox(width: 4),
                          Text('Después',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FFF0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFC8E6C9)),
                          ),
                          child: Text(despues,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _rolChip(String rol, {required bool isOld}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isOld
              ? Colors.grey[200]
              : const Color(0xFF43A047).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(rol.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isOld ? Colors.grey[700] : const Color(0xFF2E7D32),
            )),
      );

  /// Muestra campos extra genéricos (nombre, email, etc.) cuando no hay diff
  List<Widget> _extraFields(Map<String, dynamic> data) {
    final campos = {
      'Nombre': data['nombre'],
      'Email': data['email'],
      'Rol': data['rol'],
      'Activo': data['activo'] != null ? (data['activo'] ? 'Sí' : 'No') : null,
      'Título capacitación': data['titulo'],
      'Empleado': data['empleado'],
      'Estado derivación': data['estado'],
      'Motivo': data['motivo'],
    };

    return campos.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _infoRow(Icons.info_outline, e.key, e.value.toString()),
            ))
        .toList();
  }
}

// Extensión para label desde String
extension _TipoLabelExt on String {
  String get label {
    switch (this) {
      case 'cambio_rol':                return 'Cambio de Rol';
      case 'modificacion_usuario':      return 'Modificación';
      case 'creacion_usuario':          return 'Nuevo Usuario';
      case 'eliminacion_usuario':       return 'Eliminación';
      case 'cambio_estado':             return 'Cambio Estado';
      case 'login':                     return 'Acceso';
      case 'creacion_capacitacion':     return 'Nueva Capacitación';
      case 'modificacion_capacitacion': return 'Edición Capac.';
      case 'eliminacion_capacitacion':  return 'Eliminar Capac.';
      case 'creacion_derivacion':       return 'Nueva Derivación';
      case 'actualizacion_derivacion':  return 'Actualiz. Derivación';
      default:                          return 'Evento';
    }
  }
}

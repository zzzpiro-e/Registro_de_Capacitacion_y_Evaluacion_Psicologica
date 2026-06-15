import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAuditoriaScreen extends StatefulWidget {
  final VoidCallback? onReturnToDashboard;

  const AdminAuditoriaScreen({super.key, this.onReturnToDashboard});

  @override
  State<AdminAuditoriaScreen> createState() => _AdminAuditoriaScreenState();
}

class _AdminAuditoriaScreenState extends State<AdminAuditoriaScreen> {
  String _filtroTipo   = 'todos';
  String _filtroModulo = 'todos';

  // Línea visual unificada basada en el color corporativo plano y acentos limpios
  static const Color verdeBoton = Color(0xFF008744);
  static const Color fondoGrisPantalla = Color(0xFFF5F5F5);

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
    {'label': 'Todos',      'valor': 'todos',      'color': Color(0xFF757575)},
    {'label': 'Admin',      'valor': 'admin',      'color': Color(0xFF6A1B9A)},
    {'label': 'RRHH',       'valor': 'rrhh',       'color': Color(0xFF1A73E8)},
    {'label': 'Psicólogo',  'valor': 'psicologo',  'color': Color(0xFF00796B)},
  ];

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'cambio_rol':               return const Color(0xFF6A1B9A);
      case 'modificacion_usuario':     return const Color(0xFF1A73E8);
      case 'creacion_usuario':         return verdeBoton;
      case 'eliminacion_usuario':      return const Color(0xFFC62828);
      case 'cambio_estado':            return const Color(0xFFE65100);
      case 'login':                    return const Color(0xFF00796B);
      case 'creacion_capacitacion':    return const Color(0xFF1A73E8);
      case 'modificacion_capacitacion':return const Color(0xFF0288D1);
      case 'eliminacion_capacitacion': return const Color(0xFFC62828);
      case 'creacion_derivacion':      return const Color(0xFF00796B);
      case 'actualizacion_derivacion': return const Color(0xFF00897B);
      default:                         return const Color(0xFF757575);
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
      case 'rrhh':      return const Color(0xFF1A73E8);
      case 'psicologo': return const Color(0xFF00796B);
      default:          return const Color(0xFF757575);
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
      backgroundColor: fondoGrisPantalla,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: verdeBoton, size: 22),
          onPressed: () {
            if (widget.onReturnToDashboard != null) {
              widget.onReturnToDashboard!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Historial & Auditoría',
          style: TextStyle(
            color: Color(0xFF202124),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ── Filtro Módulo Estilizado ─────────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filtrosModulo.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f   = _filtrosModulo[i];
                final sel = _filtroModulo == f['valor'];
                final col = f['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _filtroModulo = f['valor']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? col.withOpacity(0.12) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? col : const Color(0xFFEAEAEA),
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(f['label'] as String,
                        style: TextStyle(
                          color: sel ? col : const Color(0xFF757575),
                          fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        )),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── Filtro Tipo Estilizado ───────────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filtrosTipo.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f   = _filtrosTipo[i];
                final sel = _filtroTipo == f['valor'];
                return GestureDetector(
                  onTap: () => setState(() => _filtroTipo = f['valor']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? verdeBoton.withOpacity(0.12) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? verdeBoton : const Color(0xFFEAEAEA),
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Icon(f['icon'] as IconData,
                          size: 14,
                          color: sel ? verdeBoton : const Color(0xFF757575)),
                      const SizedBox(width: 6),
                      Text(f['label'] as String,
                          style: TextStyle(
                            color: sel ? verdeBoton : const Color(0xFF757575),
                            fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          )),
                    ]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Listado de Eventos (Plano, Limpio y de Altura Constante) ─────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('auditoria')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: verdeBoton, strokeWidth: 2.5));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState();
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final tipoOk = _filtroTipo == 'todos' || d['tipo'] == _filtroTipo;
                  final moduloOk = _filtroModulo == 'todos' || d['modulo'] == _filtroModulo;
                  return tipoOk && moduloOk;
                }).toList();

                if (docs.isEmpty) return _emptyState();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                  physics: const BouncingScrollPhysics(),
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
    final String? rolAnterior = data['rolAnterior'];
    final String? rolNuevo    = data['rolNuevo'];
    final String? modulo      = data['modulo'];
    final bool tieneDetalle   = data['camposAntes'] != null || data['camposDespues'] != null;
    final Color  color        = _colorPorTipo(tipo);
    final Color  colorMod     = _colorModulo(modulo);

    String fechaStr = '';
    if (data['fecha'] != null) {
      fechaStr = DateFormat("d MMM, HH:mm", 'es_ES')
          .format((data['fecha'] as Timestamp).toDate());
    }

    return GestureDetector(
      onTap: () => _abrirDetalle(data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEAEAEA),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Centrado simétrico de los elementos
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconPorTipo(tipo), color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _badge(tipo.label, color),
                        const SizedBox(width: 6),
                        if (modulo != null)
                          _badge(_labelModulo(modulo), colorMod),
                        const Spacer(),
                        Text(fechaStr,
                            style: const TextStyle(color: Color(0xFF757575), fontSize: 11, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.person_outline, size: 13, color: Color(0xFF757575)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(quien,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF202124)),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    // 🔲 El bloque de descripción repetitivo se removió para homogeneizar el tamaño
                    if (rolAnterior != null && rolNuevo != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _rolChip(rolAnterior, isOld: true),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF757575)),
                            ),
                            _rolChip(rolNuevo, isOld: false),
                          ],
                        ),
                      ),
                    ],
                    if (tieneDetalle && (rolAnterior == null || rolNuevo == null)) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.touch_app_outlined, size: 13, color: color.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text('Ver campos modificados',
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFBCC1C6), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Widget _rolChip(String rol, {required bool isOld}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isOld ? const Color(0xFFEAEAEA) : verdeBoton.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isOld ? const Color(0xFFD2D2D2) : verdeBoton.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(rol.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isOld ? const Color(0xFF5F6368) : verdeBoton,
            )),
      );

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: verdeBoton.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.history_outlined,
                  size: 32, color: verdeBoton),
            ),
            const SizedBox(height: 14),
            const Text('Sin registros aún',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202124))),
            const SizedBox(height: 4),
            const Text('Los cambios del sistema aparecerán aquí',
                style: TextStyle(fontSize: 12, color: Color(0xFF5F6368))),
          ],
        ),
      );
}

// ─── PANEL DETALLE HOJA INFERIOR ──────────────────────────────────────────────

class _DetalleAuditoria extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DetalleAuditoria({required this.data});

  static const Color verdeBoton = Color(0xFF008744);

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'cambio_rol':               return const Color(0xFF6A1B9A);
      case 'modificacion_usuario':     return const Color(0xFF1A73E8);
      case 'creacion_usuario':         return verdeBoton;
      case 'eliminacion_usuario':      return const Color(0xFFC62828);
      case 'cambio_estado':            return const Color(0xFFE65100);
      case 'creacion_capacitacion':    return const Color(0xFF1A73E8);
      case 'modificacion_capacitacion':return const Color(0xFF0288D1);
      case 'actualizacion_derivacion': return const Color(0xFF00897B);
      default:                         return const Color(0xFF757575);
    }
  }

  Color _colorModulo(String? modulo) {
    switch (modulo) {
      case 'admin':     return const Color(0xFF6A1B9A);
      case 'rrhh':      return const Color(0xFF1A73E8);
      case 'psicologo': return const Color(0xFF00796B);
      default:          return const Color(0xFF757575);
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

    final Map<String, dynamic> camposAntes   = Map<String, dynamic>.from(data['camposAntes']   ?? {});
    final Map<String, dynamic> camposDespues = Map<String, dynamic>.from(data['camposDespues'] ?? {});
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_iconPorTipo(tipo), color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detalle del Registro',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF5F6368)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEAEAEA)),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _badge(tipo.label, color),
                      _badge(_labelModulo(modulo), colorMod),
                    ]),
                    const SizedBox(height: 16),
                    _infoRow(Icons.person_outline, 'Realizado por', quien),
                    const SizedBox(height: 12),
                    if (fechaStr.isNotEmpty)
                      _infoRow(Icons.access_time_outlined, 'Fecha y hora', fechaStr),
                    const SizedBox(height: 12),
                    // ℹ️ Aquí se conserva el mensaje para que el administrador pueda auditar el texto completo si lo desea
                    _infoRow(Icons.description_outlined, 'Descripción completa', descripcion),

                    if (rolAnterior != null && rolNuevo != null) ...[
                      const SizedBox(height: 20),
                      _seccionTitulo('Cambio de Rol', Icons.manage_accounts_outlined, color),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _rolChip(rolAnterior, isOld: true),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF757575), size: 12),
                            ),
                            _rolChip(rolNuevo, isOld: false),
                          ],
                        ),
                      ),
                    ],

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

                    if (allKeys.isEmpty && rolAnterior == null) ...[
                      const SizedBox(height: 20),
                      _seccionTitulo('Información adicional', Icons.info_outline, const Color(0xFF5F6368)),
                      const SizedBox(height: 10),
                      ..._extraFields(data),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Text(text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );

  Widget _infoRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF5F6368)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF5F6368), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF202124))),
              ],
            ),
          ),
        ],
      );

  Widget _seccionTitulo(String titulo, IconData icon, Color color) => Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(titulo,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
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
          border: Border.all(color: const Color(0xFFEAEAEA)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA))),
              ),
              child: Text(campo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF202124))),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.remove_circle_outline, size: 12, color: Color(0xFFC62828)),
                          SizedBox(width: 4),
                          Text('Antes',
                              style: TextStyle(fontSize: 10, color: Color(0xFF757575), fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFCDD2).withOpacity(0.5)),
                          ),
                          child: Text(antes,
                              style: const TextStyle(fontSize: 13, color: Color(0xFFC62828), fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF757575)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.add_circle_outline, size: 12, color: verdeBoton),
                          SizedBox(width: 4),
                          Text('Después',
                              style: TextStyle(fontSize: 10, color: verdeBoton, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: verdeBoton.withOpacity(0.2)),
                          ),
                          child: Text(despues,
                              style: const TextStyle(fontSize: 13, color: verdeBoton, fontWeight: FontWeight.w500)),
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
          color: isOld ? const Color(0xFFF1F3F4) : verdeBoton.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOld ? const Color(0xFFEAEAEA) : verdeBoton.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(rol.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isOld ? const Color(0xFF5F6368) : verdeBoton,
            )),
      );

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
              padding: const EdgeInsets.only(bottom: 10),
              child: _infoRow(Icons.info_outline, e.key, e.value.toString()),
            ))
        .toList();
  }
}

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
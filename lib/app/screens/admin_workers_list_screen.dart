import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_flutter/app/screens/editar_trabajador_admin_screen.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

class AdminWorkersListScreen extends StatefulWidget {
  final String initialRoleFilter;
  final String initialStatusFilter;
  final VoidCallback? onReturnToDashboard;

  const AdminWorkersListScreen({
    super.key,
    this.initialRoleFilter = 'todos',
    this.initialStatusFilter = 'todos',
    this.onReturnToDashboard,
  });

  @override
  State<AdminWorkersListScreen> createState() => _AdminWorkersListScreenState();
}

class _AdminWorkersListScreenState extends State<AdminWorkersListScreen> {
  final _searchController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  String _query = '';
  late String _selectedRoleFilter;
  late String _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _selectedRoleFilter = widget.initialRoleFilter;
    _selectedStatusFilter = widget.initialStatusFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  void _abrirEdicion(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarTrabajadorAdminScreen(trabajadorId: uid),
      ),
    );
  }

  Future<bool> _validarPasswordAdmin() async {
    _adminPasswordController.clear();
    bool esValida = false;
    bool ocultarPassword = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF008744)),
                  SizedBox(width: 10),
                  Text(
                    'Confirmación Requerida',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Introduce tu contraseña para autorizar esta acción en la base de datos:',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF757575).withOpacity(0.4)),
                    ),
                    child: TextField(
                      controller: _adminPasswordController,
                      obscureText: ocultarPassword,
                      decoration: InputDecoration(
                        hintText: 'Tu contraseña de administrador',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF757575),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF757575),
                          ),
                          onPressed: () => setModalState(
                            () => ocultarPassword = !ocultarPassword,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008744),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    String passwordInput = _adminPasswordController.text.trim();
                    if (passwordInput.isEmpty) return;

                    try {
                      User? adminUser = FirebaseAuth.instance.currentUser;
                      if (adminUser != null && adminUser.email != null) {
                        AuthCredential credential =
                            EmailAuthProvider.credential(
                              email: adminUser.email!,
                              password: passwordInput,
                            );
                        await adminUser.reauthenticateWithCredential(
                          credential,
                        );
                        esValida = true;
                        if (context.mounted) Navigator.pop(context);
                      }
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.code == 'wrong-password'
                                  ? 'Contraseña incorrecta'
                                  : 'Error de autenticación',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return esValida;
  }

  Future<void> _eliminarTrabajador(String uid, String nombreTrabajador) async {
    bool confirmar =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    '¿Eliminar Trabajador?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(
                '¿Estás seguro de que deseas eliminar a $nombreTrabajador? Esta acción es completamente irreversible y quitará todos sus accesos de inmediato.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmar) return;

    bool verificado = await _validarPasswordAdmin();
    if (!verificado) return;

    try {
      await FirebaseFirestore.instance
          .collection('trabajadores')
          .doc(uid)
          .delete();
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .delete();
      _mostrarSnackBar(
        'Trabajador eliminado de la base de datos de forma permanente.',
        Colors.black87,
      );
    } catch (e) {
      _mostrarSnackBar('Error al intentar eliminar: $e', Colors.red);
    }
  }

  void _mostrarSnackBar(String mensaje, Color colorFondo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colorFondo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _abrirFiltros() async {
    String tempRole = _selectedRoleFilter;
    String tempStatus = _selectedStatusFilter;

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildSectionTitle(String title) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202124),
                  ),
                ),
              );
            }

            Widget buildChoice(
              String label,
              String value,
              String current,
              ValueChanged<String> onChanged,
            ) {
              final selected = current == value;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setModalState(() => onChanged(value)),
                selectedColor: const Color(0xFF008744).withOpacity(0.12),
                labelStyle: TextStyle(
                  color: selected ? const Color(0xFF008744) : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF008744)
                      : Colors.grey.shade300,
                ),
                backgroundColor: Colors.white,
              );
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const Text(
                      'Filtros de Búsqueda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF202124),
                      ),
                    ),
                    const SizedBox(height: 18),
                    buildSectionTitle('Rol'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        buildChoice('Todos', 'todos', tempRole, (value) => tempRole = value),
                        buildChoice('RRHH', 'rrhh', tempRole, (value) => tempRole = value),
                        buildChoice('Psicólogos', 'psicologo', tempRole, (value) => tempRole = value),
                      ],
                    ),
                    const SizedBox(height: 20),
                    buildSectionTitle('Estado'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        buildChoice('Todos', 'todos', tempStatus, (value) => tempStatus = value),
                        buildChoice('Activo', 'activo', tempStatus, (value) => tempStatus = value),
                        buildChoice('Desactivado', 'desactivado', tempStatus, (value) => tempStatus = value),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context, {
                              'role': 'todos',
                              'status': 'todos',
                            }),
                            child: const Text('Limpiar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008744),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context, {
                              'role': tempRole,
                              'status': tempStatus,
                            }),
                            child: const Text('Aplicar Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedRoleFilter = result['role'] ?? 'todos';
        _selectedStatusFilter = result['status'] ?? 'todos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeBoton = Color(0xFF008744);
    const Color fondoGrisPantalla = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: fondoGrisPantalla,
      // 🟢 APPBAR BLANCO LIMPIO (Sin el cuadro verde superior gigante)
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
          'Lista de Trabajadores',
          style: TextStyle(
            color: Color(0xFF202124),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🟢 BARRA DE BÚSQUEDA ADAPTADA AL ESTILO DE TUS INPUTS (Gris perimetral plano)
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4), // Gris exacto de los inputs anteriores
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF757575).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.search,
                      color: Color(0xFF757575),
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black87, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o RUT...',
                        hintStyle: TextStyle(color: Color(0xFF757575), fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _query = TextUtils.quitarTildes(value.trim());
                        });
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filtros',
                    onPressed: _abrirFiltros,
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: verdeBoton,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Listado reactivo de trabajadores
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trabajadores')
                  .orderBy('fechaCreacion', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: verdeBoton),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay trabajadores registrados.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final listaTrabajadores = snapshot.data!.docs.where((doc) {
                  final datos = doc.data() as Map<String, dynamic>;
                  final nombre = TextUtils.quitarTildes((datos['nombre'] ?? '').toString());
                  final rut = TextUtils.quitarTildes((datos['rut']?.toString() ?? ''));
                  final rol = (datos['rol'] ?? '').toString().toLowerCase();
                  final bool esActivo = (datos['activo'] ?? true) == true;

                  final coincideBusqueda =
                      _query.isEmpty || nombre.contains(_query) || rut.contains(_query);
                  final coincideRol =
                      _selectedRoleFilter == 'todos' || rol == _selectedRoleFilter;
                  final coincideEstado =
                      _selectedStatusFilter == 'todos' ||
                      (_selectedStatusFilter == 'activo' && esActivo) ||
                      (_selectedStatusFilter == 'desactivado' && !esActivo);

                  return coincideBusqueda && coincideRol && coincideEstado;
                }).toList();

                if (listaTrabajadores.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay trabajadores para ese filtro.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
                  itemCount: listaTrabajadores.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    var doc = listaTrabajadores[index];
                    var datos = doc.data() as Map<String, dynamic>;
                    bool esPsicologo = datos['rol'] == 'psicologo';
                    bool isActive = (datos['activo'] ?? true) == true;
                    String idTrabajador = datos['uid']?.toString() ?? doc.id;

                    return _buildEmployeeCard(
                      uid: idTrabajador,
                      name: datos['nombre'] ?? 'Sin Nombre',
                      rut: datos['rut'] ?? 'Sin RUT',
                      role: esPsicologo ? 'Psicólogo' : 'RRHH',
                      isPsychologist: esPsicologo,
                      isActive: isActive,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 TARJETAS DE TRABAJADORES ESTILO PLANO LIMPIO (Sin sombras pesadas, con borde sutil)
  Widget _buildEmployeeCard({
    required String uid,
    required String name,
    required String rut,
    required String role,
    required bool isPsychologist,
    required bool isActive,
  }) {
    final Color chipColor = isPsychologist ? const Color(0xFFE3F2FD) : const Color(0xFFF3E5F5);
    final Color chipTextColor = isPsychologist ? const Color(0xFF1E88E5) : const Color(0xFF8E24AA);
    final Color stateTextColor = isActive ? const Color(0xFF008744) : const Color(0xFFC62828);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAEAEA), // Borde plano sutil perimetral
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Contenedor del ícono lateral de persona
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF757575),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202124),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          color: chipTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  rut,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: stateTextColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Activo' : 'Desactivado',
                      style: TextStyle(
                        fontSize: 12,
                        color: stateTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Acciones rápidas (Editar / Eliminar)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Editar trabajador',
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF008744), size: 22),
                onPressed: () => _abrirEdicion(uid),
              ),
              IconButton(
                tooltip: 'Eliminar de forma permanente',
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                onPressed: () => _eliminarTrabajador(uid, name),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
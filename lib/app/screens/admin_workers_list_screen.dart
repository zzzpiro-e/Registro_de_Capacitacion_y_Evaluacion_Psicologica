import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/screens/editar_trabajador_admin_screen.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

class AdminWorkersListScreen extends StatefulWidget {
  final String initialRoleFilter;
  final String initialStatusFilter;

  const AdminWorkersListScreen({
    super.key,
    this.initialRoleFilter = 'todos',
    this.initialStatusFilter = 'todos',
  });

  @override
  State<AdminWorkersListScreen> createState() => _AdminWorkersListScreenState();
}

class _AdminWorkersListScreenState extends State<AdminWorkersListScreen> {
  final TextEditingController _searchController = TextEditingController();
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
  
  // FUNCIÓN PARA ELIMINAR TRABAJADOR DE FIRESTORE
  Future<void> _eliminarTrabajador(String uid, String nombreTrabajador) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('¿Eliminar Trabajador?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('¿Estás seguro de que deseas eliminar a $nombreTrabajador? Esto quitará todos sus accesos a la app de inmediato.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmar) {
      try {
        await FirebaseFirestore.instance.collection('trabajadores').doc(uid).delete();
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();
        _mostrarSnackBar('Trabajador eliminado de la base de datos.', Colors.black87);
      } catch (e) {
        _mostrarSnackBar('Error al intentar eliminar: $e', Colors.red);
      }
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _query = '';
      _selectedRoleFilter = 'todos';
      _selectedStatusFilter = 'todos';
      _searchController.clear();
    });
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
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              );
            }

            Widget buildChoice(String label, String value, String current, ValueChanged<String> onChanged) {
              final selected = current == value;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setModalState(() => onChanged(value)),
                selectedColor: const Color(0xFF43A047).withOpacity(0.16),
                labelStyle: TextStyle(
                  color: selected ? const Color(0xFF2E7D32) : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(color: selected ? const Color(0xFF43A047) : Colors.grey.shade300),
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
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                    const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, {'role': 'todos', 'status': 'todos'}),
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white),
                            onPressed: () => Navigator.pop(context, {'role': tempRole, 'status': tempStatus}),
                            child: const Text('Aplicar'),
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

  void _mostrarSnackBar(String mensaje, Color colorFondo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: colorFondo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Lista de Trabajadores',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8),
                    child: Icon(Icons.search, color: Color(0xFF43A047), size: 24),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre, RUT o rol...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                    icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF43A047)),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trabajadores')
                  .orderBy('fechaCreacion', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF43A047)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay trabajadores registrados.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
                }

                final listaTrabajadores = snapshot.data!.docs.where((doc) {
                  final datos = doc.data() as Map<String, dynamic>;
                  final nombre = TextUtils.quitarTildes((datos['nombre'] ?? '').toString());
                  final rut = TextUtils.quitarTildes((datos['rut']?.toString() ?? ''));
                  final rol = (datos['rol'] ?? '').toString().toLowerCase();
                  final bool esActivo = (datos['activo'] ?? true) == true;

                  final coincideBusqueda = _query.isEmpty ||
                      nombre.contains(_query) ||
                      rut.contains(_query) ||
                      rol.contains(_query);

                  final coincideRol = _selectedRoleFilter == 'todos' || rol == _selectedRoleFilter;
                  final coincideEstado = _selectedStatusFilter == 'todos' ||
                      (_selectedStatusFilter == 'activo' && esActivo) ||
                      (_selectedStatusFilter == 'desactivado' && !esActivo);

                  return coincideBusqueda && coincideRol && coincideEstado;
                }).toList();

                if (listaTrabajadores.isEmpty) {
                  return const Center(
                    child: Text('No hay trabajadores para ese filtro.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                  itemCount: listaTrabajadores.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    var doc = listaTrabajadores[index];
                    var datos = doc.data() as Map<String, dynamic>;
                    bool esPsicologo = datos['rol'] == 'psicologo';
                    bool isActive = (datos['activo'] ?? true) == true;
                    String idTrabajador = datos['uid']?.toString() ?? doc.id;
                    
                    return _buildEmployeeCard(
                      uid: idTrabajador,
                      name: datos['nombre'].toString() ?? 'Sin Nombre',
                      rut: datos['rut'].toString() ?? 'Sin RUT',
                      email: datos['email'].toString() ?? 'Sin Correo',
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

  Widget _buildEmployeeCard({
    required String uid,
    required String name,
    required String rut,
    required String email,
    required String role,
    required bool isPsychologist,
    required bool isActive,
  }) {
    final Color themeColor = isPsychologist ? const Color(0xFFE3F2FD) : const Color(0xFFF3E5F5);
    final Color textColor = isPsychologist ? const Color(0xFF1E88E5) : const Color(0xFF8E24AA);
    final Color stateColor = isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final Color stateTextColor = isActive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: themeColor, child: Icon(isPsychologist ? Icons.person_outline : Icons.badge_outlined, color: textColor)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(role, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(rut, style: const TextStyle(fontSize: 13, color: Color(0xFF43A047), fontWeight: FontWeight.w600)),
                Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Rol: $role', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Estado: ${isActive ? 'Activo' : 'Desactivado'}', style: TextStyle(fontSize: 12, color: stateTextColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Editar trabajador',
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF43A047)),
                onPressed: () => _abrirEdicion(uid),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
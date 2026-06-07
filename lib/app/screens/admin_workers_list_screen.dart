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
                selectedColor: const Color(0xFF388E3C).withOpacity(0.16),
                labelStyle: TextStyle(
                  color: selected ? const Color(0xFF388E3C) : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(color: selected ? const Color(0xFF388E3C) : Colors.grey.shade300),
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
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF388E3C), foregroundColor: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          // 🟢 Header Verde RECTO corporativo idéntico al Dashboard
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            decoration: const BoxDecoration(color: Color(0xFF388E3C)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Módulo de Gestión', style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 12),
                Text(
                  'Lista de Trabajadores',
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Barra de búsqueda adaptada visualmente con sombra suave
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.search, color: Color(0xFF388E3C), size: 24),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o RUT...',
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
                    icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF388E3C)),
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
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)));
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
                  final rut = TextUtils.quitarTildes((datos['rut'] ?? '').toString());
                  final rol = (datos['rol'] ?? '').toString().toLowerCase();
                  final bool esActivo = (datos['activo'] ?? true) == true;

                  final coincideBusqueda = _query.isEmpty ||
                      nombre.contains(_query) ||
                      rut.contains(_query);

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
                    String idTrabajador = datos['uid'] ?? doc.id;

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

  // 🟢 Componente de Tarjeta Simplificado y Unificado
  Widget _buildEmployeeCard({
    required String uid,
    required String name,
    required String rut,
    required String role,
    required bool isPsychologist,
    required bool isActive,
  }) {
    // Colores de los chips de Rol (Mismos tonos suaves de la app)
    final Color chipColor = isPsychologist ? const Color(0xFFE3F2FD) : const Color(0xFFF3E5F5);
    final Color chipTextColor = isPsychologist ? const Color(0xFF1E88E5) : const Color(0xFF8E24AA);
    
    // Colores de Estado del Trabajador (Verde/Rojo)
    final Color stateTextColor = isActive ? const Color(0xFF388E3C) : const Color(0xFFC62828);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          // 🟢 Ícono Universal para todas las tarjetas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_outline, color: Colors.black54, size: 28),
          ),
          const SizedBox(width: 14),
          
          // Contenido de Texto Limpio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nombre
                    Expanded(
                      child: Text(
                        name, 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Cuadro/Chip de Rol Interno
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(role, style: TextStyle(color: chipTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // RUT
                Text(rut, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                // Estado Simplificado
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: stateTextColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Activo' : 'Desactivado', 
                      style: TextStyle(fontSize: 12, color: stateTextColor, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lápiz para Editar
          IconButton(
            tooltip: 'Editar trabajador',
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF388E3C)),
            onPressed: () => _abrirEdicion(uid),
          ),
        ],
      ),
    );
  }
}
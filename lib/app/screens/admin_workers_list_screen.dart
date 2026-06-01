import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminWorkersListScreen extends StatefulWidget {
  const AdminWorkersListScreen({super.key});

  @override
  State<AdminWorkersListScreen> createState() => _AdminWorkersListScreenState();
}

class _AdminWorkersListScreenState extends State<AdminWorkersListScreen> {
  
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
        _mostrarSnackBar('Trabajador eliminado de la base de datos.', Colors.black87);
      } catch (e) {
        _mostrarSnackBar('Error al intentar eliminar: $e', Colors.red);
      }
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
                  'Panel de Admin',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12),
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
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, RUT o rol...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF43A047), size: 24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
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

                final listaTrabajadores = snapshot.data!.docs;

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                  itemCount: listaTrabajadores.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    var doc = listaTrabajadores[index];
                    var datos = doc.data() as Map<String, dynamic>;
                    bool esPsicologo = datos['rol'] == 'psicologo';
                    String idTrabajador = datos['uid'] ?? doc.id;

                    return _buildEmployeeCard(
                      uid: idTrabajador,
                      name: datos['nombre'] ?? 'Sin Nombre',
                      rut: datos['rut'] ?? 'Sin RUT',
                      email: datos['email'] ?? 'Sin Correo',
                      phone: (datos['telefono'] != null && datos['telefono'].toString().isNotEmpty) ? datos['telefono'] : 'Sin Teléfono',
                      role: esPsicologo ? 'Psicólogo' : 'RRHH',
                      isPsychologist: esPsicologo,
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
    required String phone,
    required String role,
    required bool isPsychologist,
  }) {
    final Color themeColor = isPsychologist ? const Color(0xFFE3F2FD) : const Color(0xFFF3E5F5);
    final Color textColor = isPsychologist ? const Color(0xFF1E88E5) : const Color(0xFF8E24AA);
    
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
                Text(phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          // 🟢 BOTÓN DE ELIMINAR AGREGADO EN EL EXTREMO DERECHO CARD
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _eliminarTrabajador(uid, name),
          ),
        ],
      ),
    );
  }
}
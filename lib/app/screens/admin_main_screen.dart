import 'package:flutter/material.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 🟢 Banner Superior Verde (Gestión de Trabajadores)
              Container(
                width: double.infinity,
                color: const Color(0xFF43A047), 
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Panel de Administrador',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gestión de Trabajadores',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Total: 4 usuarios',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // 📦 Bloque de contenido del Dashboard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: [
                    
                    // 1️⃣ FILA DE TARJETAS DE ESTADÍSTICAS
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.people_alt_outlined, 
                            value: '4', 
                            label: 'Total', 
                            iconColor: Colors.green
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.psychology_outlined, 
                            value: '2', 
                            label: 'Psicólogos', 
                            iconColor: Colors.blue
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.badge_outlined, 
                            value: '2', 
                            label: 'RRHH', 
                            iconColor: Colors.purple
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 2️⃣ BOTÓN CREAR NUEVO TRABAJADOR (Conectado a la ruta)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          // 🔹 Navegación hacia la pantalla del formulario
                          Navigator.pushNamed(context, 'create_worker'); 
                        },
                        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                        label: const Text(
                          'Crear Nuevo Trabajador',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3️⃣ BUSCADOR
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, RUT o rol...',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4️⃣ LISTADO DE TRABAJADORES
                    _buildEmployeeCard(
                      name: 'Dr. Carlos Méndez',
                      rut: '16.234.567-8',
                      email: 'carlos.mendez@empresa.cl',
                      phone: '+56 9 8765 4321',
                      role: 'Psicólogo',
                      isPsychologist: true,
                    ),
                    const SizedBox(height: 14),
                    
                    _buildEmployeeCard(
                      name: 'María González',
                      rut: '12.345.678-9',
                      email: 'maria.gonzalez@empresa.cl',
                      phone: '+56 9 1234 5678',
                      role: 'RRHH',
                      isPsychologist: false,
                    ),
                    const SizedBox(height: 14),

                    _buildEmployeeCard(
                      name: 'Ana Martínez',
                      rut: '18.987.654-3',
                      email: 'ana.martinez@empresa.cl',
                      phone: '+56 9 5555 6666',
                      role: 'RRHH',
                      isPsychologist: false,
                    ),
                    const SizedBox(height: 14),

                    _buildEmployeeCard(
                      name: 'Dr. Roberto Silva',
                      rut: '15.678.901-2',
                      email: 'roberto.silva@empresa.cl',
                      phone: '+56 9 9999 8888', 
                      role: 'Psicólogo',
                      isPsychologist: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para las tarjetas de estadísticas superiores
  Widget _buildStatCard({
    required IconData icon, 
    required String value, 
    required String label, 
    required Color iconColor
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Widget auxiliar para la tarjeta detallada de los trabajadores
  Widget _buildEmployeeCard({
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: themeColor,
            child: Icon(isPsychologist ? Icons.person_outline : Icons.badge_outlined, color: textColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(role, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(rut, style: const TextStyle(fontSize: 14, color: Color(0xFF43A047), fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(phone, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
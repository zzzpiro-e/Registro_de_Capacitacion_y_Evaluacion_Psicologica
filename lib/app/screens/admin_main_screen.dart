import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/screens/admin_create_screen.dart'; 
import 'package:proyecto_flutter/app/screens/admin_profile_screen.dart';
// 🟢 Importamos tu pantalla de login real
import 'package:proyecto_flutter/app/screens/login_screen.dart'; 

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0; // Controla la pestaña activa

  @override
  Widget build(BuildContext context) {
    // Lista de las pantallas que se mostrarán según el botón presionado abajo
    final List<Widget> _pages = [
      _buildInicioTab(),          // 🏠 Índice 0: Dashboard de Inicio
      const AdminCreateScreen(),  // ➕ Índice 1: Conectado a tu archivo modular 🚀
      _buildTrabajadoresTab(),    // 👥 Índice 2: Vista de Trabajadores con banner curvo
      
      // 👤 Índice 3: Perfil conectado a tu LOGIN REAL 🚀
      AdminProfileScreen(
        onLogout: () {
          // pushAndRemoveUntil borra el historial de navegación para que no puedan volver atrás
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()), 
            (route) => false, 
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: _pages[_currentIndex], // Renderiza la pantalla seleccionada
      ),
      // --- 🟢 BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_alt_1_outlined), activeIcon: Icon(Icons.person_add_alt_1), label: 'Crear'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Trabajadores'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Mi perfil'),
        ],
      ),
    );
  }

  // ==========================================
  // 🏠 PESTAÑA 1: NUEVO INICIO
  // ==========================================
  Widget _buildInicioTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 🟢 Header Verde Curvo de Bienvenida
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
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Bienvenido de vuelta',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Administrador',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sábado, 31 de mayo de 2026', 
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 📊 GRID DE MÉTRICAS 2x2
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildGridStatCard(icon: Icons.groups_outlined, title: 'Total Usuarios', value: '4', color: Colors.green),
                    _buildGridStatCard(icon: Icons.how_to_reg_outlined, title: 'Activos', value: '3', color: Colors.teal),
                    _buildGridStatCard(icon: Icons.psychology_outlined, title: 'Psicólogos', value: '2', color: Colors.blue),
                    _buildGridStatCard(icon: Icons.badge_outlined, title: 'RRHH', value: '2', color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 20),

                // 📈 TARJETA DE RENDIMIENTO MENSUAL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.trending_up, color: Color(0xFF2E7D32)),
                              SizedBox(width: 8),
                              Text('Este Mes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            ],
                          ),
                          const Text('Mayo 2026', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: const [
                          Text(
                            '3 ',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          Text(
                            'nuevos usuarios',
                            style: TextStyle(fontSize: 16, color: Color(0xFF558B2F), fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 👥 PESTAÑA 3: VISTA DE TRABAJADORES
  // ==========================================
  Widget _buildTrabajadoresTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
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
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Panel de Admin',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Lista de Trabajadores',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Total: 4 usuarios registrados',
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              children: [
                Container(
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
                const SizedBox(height: 24),

                _buildEmployeeCard(name: 'Dr. Carlos Méndez', rut: '16.234.567-8', email: 'carlos.mendez@empresa.cl', phone: '+56 9 8765 4321', role: 'Psicólogo', isPsychologist: true),
                const SizedBox(height: 16),
                _buildEmployeeCard(name: 'María González', rut: '12.345.678-9', email: 'maria.gonzalez@empresa.cl', phone: '+56 9 1234 5678', role: 'RRHH', isPsychologist: false),
                const SizedBox(height: 16),
                _buildEmployeeCard(name: 'Ana Martínez', rut: '18.987.654-3', email: 'ana.martinez@empresa.cl', phone: '+56 9 5555 6666', role: 'RRHH', isPsychologist: false),
                const SizedBox(height: 16),
                _buildEmployeeCard(name: 'Dr. Roberto Silva', rut: '15.678.901-2', email: 'roberto.silva@empresa.cl', phone: '+56 9 9999 8888', role: 'Psicólogo', isPsychologist: true),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Auxiliar para las tarjetas del Grid ---
  Widget _buildGridStatCard({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  // --- Widget auxiliar de tarjetas de empleado ---
  Widget _buildEmployeeCard({required String name, required String rut, required String email, required String phone, required String role, required bool isPsychologist}) {
    final Color themeColor = isPsychologist ? const Color(0xFFE3F2FD) : const Color(0xFFF3E5F5);
    final Color textColor = isPsychologist ? const Color(0xFF1E88E5) : const Color(0xFF8E24AA);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(role, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(rut, style: const TextStyle(fontSize: 14, color: Color(0xFF43A047), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                Text(phone, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
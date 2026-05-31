import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  // Recibimos la función desde el MainScreen para manejar la salida
  final VoidCallback onLogout;

  const AdminProfileScreen({
    super.key,
    required this.onLogout, // Obligatorio al instanciar la pantalla
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 🟢 1. Header Verde Curvo de Perfil (Con Escudo Central)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.only(top: 32.0, bottom: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Círculo del Escudo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Administrador del Sistema',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Administrador',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 👤 2. BLOQUE DE INFORMACIÓN PERSONAL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.person_outline, color: Color(0xFF2E7D32), size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Información Personal',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildProfileField(icon: Icons.person_outline, label: 'RUT', value: '11.111.111-1'),
                      const SizedBox(height: 14),
                      _buildProfileField(icon: Icons.mail_outline, label: 'Correo Electrónico', value: 'admin@empresa.cl'),
                      const SizedBox(height: 14),
                      _buildProfileField(icon: Icons.phone_outlined, label: 'Teléfono', value: '+56 9 9999 9999'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ⚙️ 3. BLOQUE DE ACCIONES (Cambiar Contraseña / Cerrar Sesión)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildActionRow(
                        icon: Icons.vpn_key_outlined,
                        title: 'Cambiar Contraseña',
                        color: const Color(0xFF2E7D32),
                        onTap: () {
                          _showChangePasswordBottomSheet(context);
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFEAEAEA)),
                      _buildActionRow(
                        icon: Icons.logout_rounded,
                        title: 'Cerrar Sesión',
                        color: Colors.red.shade700,
                        onTap: onLogout, 
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ℹ️ 4. INFORMACIÓN DEL SISTEMA
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Información del Sistema',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Versión de la aplicación: 1.0.0 (Build 2026)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔐 FUNCIÓN QUE DESPLIEGA EL PANEL DE CAMBIO DE CONTRASEÑA
  void _showChangePasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Icon(Icons.lock_reset_outlined, color: Color(0xFF43A047), size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Actualizar Contraseña',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Por seguridad, introduce tu clave actual antes de registrar la nueva.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  _buildPasswordField(
                    label: 'Contraseña Actual',
                    hint: 'Introduce tu clave vigente',
                  ),
                  const SizedBox(height: 16),

                  _buildPasswordField(
                    label: 'Nueva Contraseña',
                    hint: 'Mínimo 6 caracteres',
                  ),
                  const SizedBox(height: 16),

                  _buildPasswordField(
                    label: 'Confirmar Nueva Contraseña',
                    hint: 'Repite la nueva clave',
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43A047),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contraseña actualizada con éxito (Simulado)'),
                                backgroundColor: Color(0xFF2E7D32),
                              ),
                            );
                          },
                          child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Widget Auxiliar para los campos grises de Información ---
  Widget _buildProfileField({required IconData icon, required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF43A047), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
              suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget Auxiliar para las filas de acciones interactiva ---
  Widget _buildActionRow({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
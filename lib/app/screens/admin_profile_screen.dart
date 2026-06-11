import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminProfileScreen({super.key, required this.onLogout});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _obscureUid = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _actualizarContrasena(BuildContext modalContext) async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _mostrarSnackBar('Por favor, rellena todos los campos', Colors.orange);
      return;
    }
    if (newPassword.length < 6) {
      _mostrarSnackBar(
        'La contraseña debe tener al menos 6 caracteres',
        Colors.orange,
      );
      return;
    }
    if (newPassword != confirmPassword) {
      _mostrarSnackBar('Las contraseñas no coinciden', Colors.red);
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: currentPassword,
      );

      await _currentUser.reauthenticateWithCredential(credential);
      await _currentUser.updatePassword(newPassword);

      Navigator.pop(modalContext);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _mostrarSnackBar(
        '¡Contraseña actualizada con éxito!',
        const Color(0xFF388E3C),
      );
    } on FirebaseAuthException catch (e) {
      _mostrarSnackBar(
        e.code == 'wrong-password'
            ? 'Contraseña actual incorrecta'
            : 'Error: ${e.message}',
        Colors.red,
      );
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

  @override
  Widget build(BuildContext context) {
    String emailAdmin = _currentUser?.email ?? 'admin@sistema.cl';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                decoration: const BoxDecoration(color: Color(0xFF388E3C)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Administrador del Sistema',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Rol: Control Superior',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.person_outline,
                                color: Color(0xFF388E3C),
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Información de la Cuenta',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildProfileField(
                            icon: Icons.mail_outline,
                            label: 'Correo Electrónico',
                            value: emailAdmin,
                          ),
                          const SizedBox(height: 14),
                          _buildUidField(
                            label: 'UID de Administrador',
                            value: _currentUser?.uid ?? 'Sin UID',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildActionRow(
                            icon: Icons.lock_open_outlined,
                            title: 'Cambiar Contraseña',
                            color: const Color(0xFF388E3C),
                            onTap: () =>
                                _showChangePasswordBottomSheet(context),
                          ),
                          const Divider(height: 1, color: Color(0xFFEAEAEA)),
                          _buildActionRow(
                            icon: Icons.logout_rounded,
                            title: 'Cerrar Sesión',
                            color: Colors.red.shade700,
                            onTap: widget.onLogout,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info del Sistema inferior
                    const Text(
                      'Versión de la aplicación: 1.0.0 (Build 2026)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF388E3C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUidField({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Icon(Icons.vpn_key_outlined, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF388E3C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _obscureUid ? '••••••••••••••••••••••••••••' : value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _obscureUid
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureUid = !_obscureUid;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(
                            Icons.lock_reset_outlined,
                            color: Color(0xFF388E3C),
                            size: 26,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Actualizar Contraseña',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPasswordField(
                        label: 'Contraseña Actual *',
                        hint: 'Introduce tu clave vigente',
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        onToggleVisibility: () => setModalState(
                          () => _obscureCurrent = !_obscureCurrent,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildPasswordField(
                        label: 'Nueva Contraseña *',
                        hint: 'Mínimo 6 caracteres',
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        onToggleVisibility: () =>
                            setModalState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 18),
                      _buildPasswordField(
                        label: 'Confirmar Nueva Contraseña *',
                        hint: 'Repite la nueva clave',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        onToggleVisibility: () => setModalState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed: () => Navigator.pop(modalContext),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF388E3C),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () =>
                                  _actualizarContrasena(modalContext),
                              child: const Text(
                                'Guardar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
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
      },
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202124),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAEAEA)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.grey,
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 22,
                ),
                onPressed: onToggleVisibility,
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
    );
  }
}

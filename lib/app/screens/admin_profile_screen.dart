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
  
  bool _isSaving = false;

  static const Color verdeCorporativo = Color(0xFF008744);
  static const Color fondoGrisPantalla = Color(0xFFF9F7FA);
  static const Color rojoBoton = Color(0xFFFF003F);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _actualizarContrasena(BuildContext modalContext, StateSetter setModalState) async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _mostrarSnackBar('Por favor, rellena todos los campos', Colors.orange);
      return;
    }
    if (newPassword.length < 6) {
      _mostrarSnackBar('La contraseña debe tener al menos 6 caracteres', Colors.orange);
      return;
    }
    if (newPassword != confirmPassword) {
      _mostrarSnackBar('Las contraseñas no coinciden', rojoBoton);
      return;
    }

    setModalState(() => _isSaving = true);
    setState(() => _isSaving = true);

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: currentPassword,
      );

      await _currentUser.reauthenticateWithCredential(credential);
      await _currentUser.updatePassword(newPassword);

      if (mounted) {
        Navigator.pop(modalContext);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _mostrarSnackBar('¡Contraseña actualizada con éxito!', verdeCorporativo);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Ocurrió un error inesperado';
      if (e.code == 'wrong-password') {
        errorMsg = 'La contraseña actual es incorrecta';
      } else {
        errorMsg = e.message ?? errorMsg;
      }
      _mostrarSnackBar(errorMsg, rojoBoton);
    } finally {
      if (mounted) {
        setModalState(() => _isSaving = false);
        setState(() => _isSaving = false);
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
    String emailAdmin = _currentUser?.email ?? 'admin@sistema.cl';

    return Scaffold(
      backgroundColor: fondoGrisPantalla,
      appBar: AppBar(
        backgroundColor: fondoGrisPantalla,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 16),
          child: Text(
            'Perfil Admin',
            style: TextStyle(color: Color(0xFF202124), fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: verdeCorporativo,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Administrador', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Control Superior', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Información de la Cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    _buildDataField(icon: Icons.mail_outlined, label: 'Correo Electrónico', value: emailAdmin),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFF1F1F1))),
                    _buildUidField(label: 'UID Administrador', value: _currentUser?.uid ?? 'Sin UID'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Seguridad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isSaving ? null : () => _showChangePasswordBottomSheet(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_open_outlined, color: verdeCorporativo, size: 22),
                      const SizedBox(width: 14),
                      const Expanded(child: Text('Cambiar Contraseña', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF202124)))),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rojoBoton,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSaving ? null : widget.onLogout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    // Declaramos la variable de estado local del modal
    String estadoClaveActual = 'vacio'; // 'vacio', 'verificando', 'valido', 'invalido'

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: !_isSaving,
      enableDrag: !_isSaving,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            
            // Función interna para gatillar la verificación con Firebase
            Future<void> verificarClaveActual() async {
              final texto = _currentPasswordController.text.trim();
              if (texto.isEmpty) return;

              setModalState(() => estadoClaveActual = 'verificando');
              
              try {
                AuthCredential credential = EmailAuthProvider.credential(
                  email: _currentUser!.email!,
                  password: texto,
                );
                // Intento silencioso de reautenticación
                await _currentUser!.reauthenticateWithCredential(credential);
                setModalState(() => estadoClaveActual = 'valido');
              } catch (e) {
                setModalState(() => estadoClaveActual = 'invalido');
              }
            }

            final int newPasswordLength = _newPasswordController.text.length;
            final bool isLengthValid = newPasswordLength >= 6;
            final bool doPasswordsMatch = _newPasswordController.text == _confirmPasswordController.text && _newPasswordController.text.isNotEmpty;
            final bool puedeGuardar = estadoClaveActual == 'valido' && isLengthValid && doPasswordsMatch && !_isSaving;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(color: const Color(0xFFEAEAEA), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.lock_reset_outlined, color: verdeCorporativo, size: 24),
                        SizedBox(width: 8),
                        Text('Actualizar Contraseña', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // ── CAMPO 1: Contraseña Actual ──
                    _buildPasswordField(
                      label: 'Contraseña Actual *',
                      hint: 'Introduce tu clave vigente',
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      enabled: !_isSaving,
                      textInputAction: TextInputAction.next,
                      // Cambiado a submisión/cambio de foco directo del teclado nativo
                      onSubmitted: (_) => verificarClaveActual(),
                      onChanged: (text) {
                        if (estadoClaveActual != 'vacio') {
                          setModalState(() => estadoClaveActual = 'vacio');
                        }
                      },
                      onToggleVisibility: () => setModalState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    
                    const SizedBox(height: 6),
                    // Feedback visual debajo de la clave actual
                    if (estadoClaveActual == 'verificando') ...[
                      Row(
                        children: const [
                          SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: verdeCorporativo)),
                          SizedBox(width: 8),
                          Text('Verificando con el servidor...', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ] else if (estadoClaveActual == 'valido') ...[
                      Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, size: 14, color: verdeCorporativo),
                          SizedBox(width: 6),
                          Text('Contraseña correcta', style: TextStyle(fontSize: 11, color: verdeCorporativo, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ] else if (estadoClaveActual == 'invalido') ...[
                      Row(
                        children: const [
                          Icon(Icons.error_outline_rounded, size: 14, color: rojoBoton),
                          SizedBox(width: 6),
                          Text('La contraseña es incorrecta', style: TextStyle(fontSize: 11, color: rojoBoton, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ] else ...[
                      const Text('Presiona "Siguiente" o enter en el teclado para verificar.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],

                    const SizedBox(height: 16),
                    
                    // ── CAMPO 2: Nueva Contraseña ──
                    _buildPasswordField(
                      label: 'Nueva Contraseña *',
                      hint: 'Introduce la nueva clave',
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      enabled: !_isSaving && estadoClaveActual == 'valido', // Congelado hasta verificar la clave anterior
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setModalState(() {}),
                      onToggleVisibility: () => setModalState(() => _obscureNew = !_obscureNew),
                    ),
                    if (_newPasswordController.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(isLengthValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 14, color: isLengthValid ? verdeCorporativo : Colors.orange),
                          const SizedBox(width: 6),
                          Text('Mínimo 6 caracteres (llevas $newPasswordLength)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isLengthValid ? verdeCorporativo : Colors.orange)),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // ── CAMPO 3: Confirmar Contraseña ──
                    _buildPasswordField(
                      label: 'Confirmar Nueva Contraseña *',
                      hint: 'Repite la nueva clave',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      enabled: !_isSaving && isLengthValid,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setModalState(() {}),
                      onSubmitted: (_) {
                        if (puedeGuardar) _actualizarContrasena(modalContext, setModalState);
                      },
                      onToggleVisibility: () => setModalState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    if (_confirmPasswordController.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(doPasswordsMatch ? Icons.check_circle_rounded : Icons.error_outline_rounded, size: 14, color: doPasswordsMatch ? verdeCorporativo : rojoBoton),
                          const SizedBox(width: 6),
                          Text(doPasswordsMatch ? 'Las contraseñas coinciden perfectamente' : 'Las contraseñas aún no coinciden', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: doPasswordsMatch ? verdeCorporativo : rojoBoton)),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: const BorderSide(color: Color(0xFFEAEAEA)),
                            ),
                            onPressed: _isSaving ? null : () => Navigator.pop(modalContext),
                            child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: puedeGuardar ? verdeCorporativo : Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: puedeGuardar ? () => _actualizarContrasena(modalContext, setModalState) : null,
                            child: _isSaving
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Guardar', style: TextStyle(color: puedeGuardar ? Colors.white : Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 14)),
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
  }

  Widget _buildDataField({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 4.0), child: Icon(icon, color: verdeCorporativo, size: 22)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: verdeCorporativo, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Color(0xFF202124), fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUidField({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 4.0), child: Icon(Icons.vpn_key_outlined, color: verdeCorporativo, size: 22)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: verdeCorporativo, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(_obscureUid ? '••••••••••••••••••••••••••••' : value, style: const TextStyle(color: Color(0xFF202124), fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(_obscureUid ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 20),
          onPressed: () => setState(() => _obscureUid = !_obscureUid),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    bool enabled = true,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: enabled ? const Color(0xFF5F6368) : Colors.grey.shade400)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            enabled: enabled,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            style: TextStyle(fontSize: 14, color: enabled ? Colors.black87 : Colors.grey),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
              suffixIcon: IconButton(
                icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 18),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}
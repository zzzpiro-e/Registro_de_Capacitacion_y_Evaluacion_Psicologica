import 'package:flutter/material.dart';

import '../admin_worker_palette.dart';

class AdminCreateWorkerForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController rutController;
  final TextEditingController correoController;
  final TextEditingController telefonoController;
  final TextEditingController claveController;
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const AdminCreateWorkerForm({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.rutController,
    required this.correoController,
    required this.telefonoController,
    required this.claveController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AdminWorkerPalette.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Crear Trabajador',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AdminWorkerPalette.border),
                    ),
                    child: const Text(
                      'Complete todos los campos para crear un nuevo usuario en el sistema',
                      style: TextStyle(
                        color: AdminWorkerPalette.primaryGreenDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: nombreController,
                    label: 'Nombre Completo',
                    hintText: 'Ej: Juan Pérez González',
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    controller: rutController,
                    label: 'RUT',
                    hintText: 'Ej: 12.345.678-9',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el RUT';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    controller: correoController,
                    label: 'Correo Electrónico',
                    hintText: 'Ej: usuario@empresa.cl',
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) {
                        return 'Ingresa el correo electrónico';
                      }
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    controller: telefonoController,
                    label: 'Teléfono',
                    hintText: 'Ej: +56 9 1234 5678',
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el teléfono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'RRHH', child: Text('RRHH')),
                      DropdownMenuItem(
                        value: 'Psicólogo',
                        child: Text('Psicólogo'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onRoleChanged(value);
                      }
                    },
                    decoration: _inputDecoration(label: 'Rol'),
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    controller: claveController,
                    label: 'Clave Provisoria',
                    hintText: 'Mínimo 8 caracteres',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa una clave provisoria';
                      }
                      if (value.length < 8) {
                        return 'Debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'El usuario deberá cambiar esta contraseña en su primer inicio de sesión',
                    style: TextStyle(
                      color: AdminWorkerPalette.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.save_rounded, size: 22),
              label: const Text(
                'Crear Trabajador',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminWorkerPalette.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AdminWorkerPalette.textMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AdminWorkerPalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AdminWorkerPalette.primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.textInputAction,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: AdminWorkerPalette.textMuted),
        labelStyle: const TextStyle(color: AdminWorkerPalette.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AdminWorkerPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AdminWorkerPalette.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AdminWorkerPalette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AdminWorkerPalette.danger),
        ),
      ),
    );
  }
}

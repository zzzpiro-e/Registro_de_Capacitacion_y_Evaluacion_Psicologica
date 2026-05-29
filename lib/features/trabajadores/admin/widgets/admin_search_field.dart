import 'package:flutter/material.dart';

import '../admin_worker_palette.dart';

class AdminSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const AdminSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, RUT o rol...',
        hintStyle: const TextStyle(color: AdminWorkerPalette.textMuted),
        prefixIcon: const Icon(Icons.search_rounded),
        prefixIconColor: AdminWorkerPalette.textMuted,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 18,
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
      ),
    );
  }
}

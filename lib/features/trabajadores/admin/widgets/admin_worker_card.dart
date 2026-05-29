import 'package:flutter/material.dart';

import '../../../../app/utils/text_utils.dart';
import '../admin_worker_palette.dart';
import '../trabajador_admin.dart';

class AdminWorkerCard extends StatelessWidget {
  final TrabajadorAdmin worker;

  const AdminWorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final normalizedRole = TextUtils.quitarTildes(worker.rol);
    final isPsicologo = normalizedRole.contains('psicologo');
    final roleColor = isPsicologo
        ? AdminWorkerPalette.roleBlue
        : AdminWorkerPalette.rolePurple;
    final roleSoftColor = isPsicologo
        ? AdminWorkerPalette.roleBlueSoft
        : AdminWorkerPalette.rolePurpleSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AdminWorkerPalette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: roleSoftColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: roleColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  worker.rut,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AdminWorkerPalette.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  worker.correo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  worker.telefono,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: roleSoftColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              worker.rol,
              style: TextStyle(
                color: roleColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

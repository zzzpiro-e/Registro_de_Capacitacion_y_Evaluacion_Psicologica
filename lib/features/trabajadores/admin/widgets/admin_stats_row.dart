import 'package:flutter/material.dart';

import '../admin_worker_palette.dart';

class AdminStatsRow extends StatelessWidget {
  final int total;
  final int psicologos;
  final int rrhh;

  const AdminStatsRow({
    super.key,
    required this.total,
    required this.psicologos,
    required this.rrhh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(
            title: 'Total',
            value: total,
            icon: Icons.groups_rounded,
            iconColor: AdminWorkerPalette.primaryGreen,
            backgroundColor: AdminWorkerPalette.primaryGreenSoft,
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: 'Psicólogos',
            value: psicologos,
            icon: Icons.psychology_alt_rounded,
            iconColor: AdminWorkerPalette.roleBlue,
            backgroundColor: AdminWorkerPalette.roleBlueSoft,
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: 'RRHH',
            value: rrhh,
            icon: Icons.badge_rounded,
            iconColor: AdminWorkerPalette.rolePurple,
            backgroundColor: AdminWorkerPalette.rolePurpleSoft,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AdminWorkerPalette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminWorkerPalette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

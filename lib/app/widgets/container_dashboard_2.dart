import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/screens/capacitaciones_screen.dart';

// Constantes
const _verdeFirebase = Color(0xFF2E7D32);
const _naranja = Color(0xFFFF9800);
const _verdeClaro = Color(0xFF4CAF50);
const _azulGris = Colors.blueGrey;

class ContainerDashboardDos extends StatelessWidget {
  const ContainerDashboardDos({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _TotalEmpleadosCard(),
          SizedBox(height: 18),
          _CapacitacionesSection(),
          SizedBox(height: 36),
        ],
      ),
    );
  }
}

// Widget separado para Total Empleados (evita reconstrucciones)
class _TotalEmpleadosCard extends StatelessWidget {
  const _TotalEmpleadosCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('empleados').snapshots(),
      builder: (context, snapshot) {
        final total = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return InkWell(
          onTap: () => Navigator.pushNamed(context, 'empleados'),
          borderRadius: BorderRadius.circular(22),
          child: _StatCard(
            icon: Icons.groups_outlined,
            iconColor: _verdeFirebase,
            title: 'Total Empleados',
            value: total.toString(),
          ),
        );
      },
    );
  }
}

// Widget separado para la sección de capacitaciones
class _CapacitacionesSection extends StatelessWidget {
  const _CapacitacionesSection();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('capacitaciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _CapacitacionesLoading();
        }

        final docs = snapshot.data!.docs;
        
        final pendientes = docs.where((doc) {
          final estado = (doc['estado'] ?? '').toString().trim().toLowerCase();
          return estado == 'pendiente';
        }).length;

        final realizadas = docs.where((doc) {
          final estado = (doc['estado'] ?? '').toString().trim().toLowerCase();
          return estado == 'realizada';
        }).length;

        final totales = docs.length;

        return Column(
          children: [
            _CapacitacionCard(
              icon: Icons.school_outlined,
              iconColor: _naranja,
              title: 'Capacitaciones Pendientes',
              value: pendientes.toString(),
              filtro: 'pendiente',
            ),
            const SizedBox(height: 18),
            _CapacitacionCard(
              icon: Icons.check_circle_outline,
              iconColor: _verdeClaro,
              title: 'Capacitaciones Realizadas',
              value: realizadas.toString(),
              filtro: 'realizada',
            ),
            const SizedBox(height: 18),
            _CapacitacionCard(
              icon: Icons.list_alt_outlined,
              iconColor: _azulGris,
              title: 'Capacitaciones Totales',
              value: totales.toString(),
              filtro: 'todas',
            ),
          ],
        );
      },
    );
  }
}

// Widget de carga para capacitaciones
class _CapacitacionesLoading extends StatelessWidget {
  const _CapacitacionesLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _StatCard(
          icon: Icons.school_outlined,
          iconColor: _naranja,
          title: 'Capacitaciones Pendientes',
          value: '...',
        ),
        SizedBox(height: 18),
        _StatCard(
          icon: Icons.check_circle_outline,
          iconColor: _verdeClaro,
          title: 'Capacitaciones Realizadas',
          value: '...',
        ),
        SizedBox(height: 18),
        _StatCard(
          icon: Icons.list_alt_outlined,
          iconColor: _azulGris,
          title: 'Capacitaciones Totales',
          value: '...',
        ),
      ],
    );
  }
}

// Tarjeta de capacitación con navegación
class _CapacitacionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String filtro;

  const _CapacitacionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.filtro,
  });

  void _onTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CapacitacionesPage(filtroInicial: filtro),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(22),
      child: _StatCard(
        icon: icon,
        iconColor: iconColor,
        title: title,
        value: value,
      ),
    );
  }
}

// Widget base de tarjeta estadística (reutilizable)
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
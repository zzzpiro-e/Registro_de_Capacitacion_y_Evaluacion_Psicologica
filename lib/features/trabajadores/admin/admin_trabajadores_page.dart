import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/utils/text_utils.dart';
import 'admin_worker_palette.dart';
import 'trabajador_admin.dart';
import 'widgets/admin_create_worker_form.dart';
import 'widgets/admin_dashboard_header.dart';
import 'widgets/admin_search_field.dart';
import 'widgets/admin_stats_row.dart';
import 'widgets/admin_worker_card.dart';

enum AdminViewState { dashboard, crearTrabajador }

class AdminTrabajadoresPage extends StatefulWidget {
  const AdminTrabajadoresPage({super.key});

  @override
  State<AdminTrabajadoresPage> createState() => _AdminTrabajadoresPageState();
}

class _AdminTrabajadoresPageState extends State<AdminTrabajadoresPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();

  final List<TrabajadorAdmin> _workers = [
    const TrabajadorAdmin(
      nombreCompleto: 'Dr. Carlos Méndez',
      rut: '12.345.678-9',
      correo: 'carlos.mendez@empresa.cl',
      telefono: '+56 9 1234 5678',
      rol: 'Psicólogo',
      claveProvisoria: '********',
    ),
    const TrabajadorAdmin(
      nombreCompleto: 'María Torres Vega',
      rut: '13.456.789-0',
      correo: 'maria.torres@empresa.cl',
      telefono: '+56 9 8765 4321',
      rol: 'RRHH',
      claveProvisoria: '********',
    ),
    const TrabajadorAdmin(
      nombreCompleto: 'Paula Rojas Castro',
      rut: '15.789.456-2',
      correo: 'paula.rojas@empresa.cl',
      telefono: '+56 9 4567 8912',
      rol: 'Psicólogo',
      claveProvisoria: '********',
    ),
    const TrabajadorAdmin(
      nombreCompleto: 'Roberto Sánchez Díaz',
      rut: '16.987.654-3',
      correo: 'roberto.sanchez@empresa.cl',
      telefono: '+56 9 2345 6789',
      rol: 'RRHH',
      claveProvisoria: '********',
    ),
    const TrabajadorAdmin(
      nombreCompleto: 'Ana Fernández Mora',
      rut: '18.234.567-1',
      correo: 'ana.fernandez@empresa.cl',
      telefono: '+56 9 3456 7891',
      rol: 'Psicólogo',
      claveProvisoria: '********',
    ),
    const TrabajadorAdmin(
      nombreCompleto: 'Javiera Morales Ríos',
      rut: '19.876.543-7',
      correo: 'javiera.morales@empresa.cl',
      telefono: '+56 9 9876 5432',
      rol: 'RRHH',
      claveProvisoria: '********',
    ),
  ];

  AdminViewState _viewState = AdminViewState.dashboard;
  String _query = '';
  String _selectedRole = 'RRHH';

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  List<TrabajadorAdmin> get _filteredWorkers {
    final normalizedQuery = TextUtils.quitarTildes(_query.trim());
    if (normalizedQuery.isEmpty) {
      return List.unmodifiable(_workers);
    }

    return _workers.where((worker) {
      final haystack = TextUtils.quitarTildes(
        '${worker.nombreCompleto} ${worker.rut} ${worker.correo} ${worker.telefono} ${worker.rol}',
      );
      return haystack.contains(normalizedQuery);
    }).toList();
  }

  int get _psicologosCount {
    return _workers.where((worker) {
      return TextUtils.quitarTildes(worker.rol).contains('psicologo');
    }).length;
  }

  int get _rrhhCount {
    return _workers.where((worker) {
      return TextUtils.quitarTildes(worker.rol).contains('rrhh');
    }).length;
  }

  void _openCreateView() {
    setState(() {
      _viewState = AdminViewState.crearTrabajador;
    });
  }

  void _goToDashboard() {
    setState(() {
      _viewState = AdminViewState.dashboard;
    });
  }

  void _clearForm() {
    _nombreController.clear();
    _rutController.clear();
    _correoController.clear();
    _telefonoController.clear();
    _claveController.clear();
    _selectedRole = 'RRHH';
    _formKey.currentState?.reset();
  }

  void _submitWorker() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _workers.insert(
        0,
        TrabajadorAdmin(
          nombreCompleto: _nombreController.text.trim(),
          rut: _rutController.text.trim(),
          correo: _correoController.text.trim(),
          telefono: _telefonoController.text.trim(),
          rol: _selectedRole,
          claveProvisoria: _claveController.text.trim(),
        ),
      );
      _viewState = AdminViewState.dashboard;
    });

    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trabajador creado correctamente'),
        backgroundColor: AdminWorkerPalette.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AdminWorkerPalette.primaryGreenDark,
        foregroundColor: Colors.white,
        title: const Text('Administración'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
        ],
      ),
      backgroundColor: AdminWorkerPalette.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _viewState == AdminViewState.dashboard
            ? SafeArea(
                key: const ValueKey('dashboard_view'),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    AdminDashboardHeader(totalWorkers: _workers.length),
                    const SizedBox(height: 16),
                    AdminStatsRow(
                      total: _workers.length,
                      psicologos: _psicologosCount,
                      rrhh: _rrhhCount,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _openCreateView,
                        icon: const Icon(Icons.add_rounded, size: 22),
                        label: const Text(
                          'Crear Nuevo Trabajador',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
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
                    const SizedBox(height: 16),
                    AdminSearchField(
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_filteredWorkers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AdminWorkerPalette.border),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.manage_search_rounded,
                              color: AdminWorkerPalette.primaryGreen,
                              size: 40,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No hay trabajadores que coincidan con la búsqueda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AdminWorkerPalette.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._filteredWorkers.map(
                        (worker) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AdminWorkerCard(worker: worker),
                        ),
                      ),
                  ],
                ),
              )
            : AdminCreateWorkerForm(
                key: const ValueKey('create_view'),
                formKey: _formKey,
                nombreController: _nombreController,
                rutController: _rutController,
                correoController: _correoController,
                telefonoController: _telefonoController,
                claveController: _claveController,
                selectedRole: _selectedRole,
                onRoleChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                onBack: _goToDashboard,
                onSubmit: _submitWorker,
              ),
      ),
    );
  }
}

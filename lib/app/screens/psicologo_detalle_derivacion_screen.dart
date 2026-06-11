import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../widgets/container_detalle_trabajador.dart';
import '../widgets/container_detalle_caso.dart';
import 'package:proyecto_flutter/app/services/auditoria_service.dart';

class PsicologoDetalleDerivacionScreen extends StatefulWidget {
  final Map<String, dynamic> derivacion;

  const PsicologoDetalleDerivacionScreen({
    super.key,
    required this.derivacion,
  });

  @override
  State<PsicologoDetalleDerivacionScreen> createState() => _PsicologoDetalleDerivacionScreenState();
}

class _PsicologoDetalleDerivacionScreenState extends State<PsicologoDetalleDerivacionScreen> {
  late String _estadoActual;
  bool _estaSubiendo = false; 

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.derivacion['estado'] ?? 'Pendiente';
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return const Color(0xFFFFF3CD);
      case 'En Proceso': return const Color(0xFFD0E2FF);
      case 'Completado': return const Color(0xFFDFFFD6);
      default: return Colors.grey.shade200;
    }
  }

  Color _colorTextoEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return const Color(0xFFB8860B);
      case 'En Proceso': return const Color(0xFF0056B3);
      case 'Completado': return const Color(0xFF2E7D32);
      default: return Colors.black54;
    }
  }

  Future<void> _persistirEstadoEnFirebase(String nuevoEstado) async {
    try {
      String documentoId = widget.derivacion['id'] ?? '';
      if (documentoId.isEmpty) {
        final String rutSocio = widget.derivacion['rut'] ?? '';
        documentoId = rutSocio.replaceAll('.', '').replaceAll('-', '').trim();
      }

      if (documentoId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('empleados')
            .doc(documentoId)
            .update({'estado': nuevoEstado});

        // 📝 REGISTRAR EN AUDITORÍA
        final String nombreEmpleado = widget.derivacion['nombre'] ?? 'Empleado';
        await AuditoriaService.psicologoActualizoDerivacion(
          nombreEmpleado: nombreEmpleado,
          estadoNuevo: nuevoEstado,
        );

        setState(() {
          _estadoActual = nuevoEstado;
          widget.derivacion['estado'] = nuevoEstado; 
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar estado en la base de datos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _actualizarEstado(String nuevoEstado) async {
    Navigator.pop(context); 
    await _persistirEstadoEnFirebase(nuevoEstado);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a "$nuevoEstado" en la base de datos'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    }
  }

  Future<void> _seleccionarYSubirInforme() async {
    if (_estaSubiendo) return;

    setState(() {
      _estaSubiendo = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final String nombreArchivo = result.files.single.name; 
        String documentoId = widget.derivacion['id'] ?? '';
        if (documentoId.isEmpty) {
          final String rutSocio = widget.derivacion['rut'] ?? '';
          documentoId = rutSocio.replaceAll('.', '').replaceAll('-', '').trim();
        }

        if (documentoId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('empleados')
              .doc(documentoId)
              .update({
                'fichaPsicologica': 'Informe adjunto: $nombreArchivo',
                'estado': 'Completado'
              });

          // 📝 REGISTRAR EN AUDITORÍA
          final String nombreEmpleado = widget.derivacion['nombre'] ?? 'Empleado';
          await AuditoriaService.psicologoActualizoDerivacion(
            nombreEmpleado: nombreEmpleado,
            estadoNuevo: 'Completado (Con Informe)',
          );

          setState(() {
            _estadoActual = 'Completado';
            widget.derivacion['estado'] = 'Completado';
            widget.derivacion['fichaPsicologica'] = 'Informe adjunto: $nombreArchivo';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Informe "$nombreArchivo" subido y caso completado con éxito.'),
                backgroundColor: const Color(0xFF2E7D32),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selección de archivo cancelada.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar el archivo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _estaSubiendo = false;
        });
      }
    }
  }

  void _mostrarMenuEstados() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Modificar Estado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _construirOpcionEstado('Pendiente', Icons.hourglass_empty, const Color(0xFFB8860B)),
              const Divider(),
              _construirOpcionEstado('En Proceso', Icons.autorenew, const Color(0xFF0056B3)),
              const Divider(),
              _construirOpcionEstado('Completado', Icons.check_circle_outline, const Color(0xFF2E7D32)),
            ],
          ),
        );
      },
    );
  }

  Widget _construirOpcionEstado(String estado, IconData icon, Color color) {
    final bool esActivo = _estadoActual == estado;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(estado, style: TextStyle(fontWeight: esActivo ? FontWeight.bold : FontWeight.w500, color: color)),
      trailing: esActivo ? Icon(Icons.check, color: color) : null,
      onTap: () => _actualizarEstado(estado),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _estadoActual);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text(
            'Detalle de Derivación',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32), size: 20),
            onPressed: () => Navigator.pop(context, _estadoActual),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          decoration: BoxDecoration(
                            color: _colorEstado(_estadoActual),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _estadoActual,
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: _colorTextoEstado(_estadoActual),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ContainerDetalleTrabajador(datos: widget.derivacion),
                      const SizedBox(height: 16),

                      ContainerDetalleCaso(datos: widget.derivacion),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_estadoActual == 'Pendiente') {
                        await _persistirEstadoEnFirebase('En Proceso');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Atención iniciada con éxito'), backgroundColor: Color(0xFF2E7D32)),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('El caso ya se encuentra $_estadoActual'), backgroundColor: Colors.grey.shade700),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow_outlined, color: Colors.white),
                    label: const Text('Iniciar Atención', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  OutlinedButton.icon(
                    onPressed: _estaSubiendo ? null : _mostrarMenuEstados,
                    icon: const Icon(Icons.edit_note_outlined, color: Color(0xFF2E7D32)),
                    label: const Text('Cambiar Estado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, color: Colors.black87),
                    label: const Text('Generar Comprobante PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ElevatedButton.icon(
                    onPressed: _estaSubiendo ? null : _seleccionarYSubirInforme,
                    icon: _estaSubiendo 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.assignment_turned_in_outlined, color: Colors.white),
                    label: Text(
                      _estaSubiendo ? 'Cargando Archivo...' : 'Subir Informe Psicológico', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
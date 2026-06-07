import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'container_comprobante_boton.dart';

class ContainerDetalleAcciones extends StatefulWidget {
  final Map<String, dynamic> derivacion;
  final String estadoActual;
  final Function(String, Map<String, dynamic>) onActualizarCaso;

  const ContainerDetalleAcciones({
    super.key,
    required this.derivacion,
    required this.estadoActual,
    required this.onActualizarCaso,
  });

  @override
  State<ContainerDetalleAcciones> createState() => _ContainerDetalleAccionesState();
}

class _ContainerDetalleAccionesState extends State<ContainerDetalleAcciones> {
  bool _estaSubiendo = false;

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

  // Alerta de confirmación exclusiva para cuando se selecciona "Completado" en el menú
  Future<bool> _mostrarAdvertenciaCompletado() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    '¿Finalizar Derivación?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text(
                'Al cambiar el estado a "Completado", el trabajador se archivará en el historial. '
                'Ya no podrás modificar su estado ni subir nuevos documentos, solo visualizar sus informes previos.',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Sí, Completar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
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

        final Map<String, dynamic> copiaDatos = Map<String, dynamic>.from(widget.derivacion);
        copiaDatos['estado'] = nuevoEstado;
        
        widget.onActualizarCaso(nuevoEstado, copiaDatos);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar estado: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _seleccionarYSubirInforme() async {
    if (_estaSubiendo) return;

    setState(() => _estaSubiendo = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, 
      );

      if (result != null && result.files.single.bytes != null) {
        final platformFile = result.files.single;
        final String nombreArchivo = platformFile.name;
        final Uint8List archivoBytes = platformFile.bytes!;

        String documentoId = widget.derivacion['id'] ?? '';
        if (documentoId.isEmpty) {
          final String rutSocio = widget.derivacion['rut'] ?? '';
          documentoId = rutSocio.replaceAll('.', '').replaceAll('-', '').trim();
        }

        if (documentoId.isEmpty) throw 'RUT del trabajador no disponible.';

        final String timestampUnico = DateTime.now().millisecondsSinceEpoch.toString();
        final String rutaArchivoSupabase = '$documentoId/${timestampUnico}_$nombreArchivo';

        await Supabase.instance.client.storage
            .from('informes_psicologicos')
            .uploadBinary(
              rutaArchivoSupabase, 
              archivoBytes,
              fileOptions: const FileOptions(
                contentType: 'application/pdf',
                upsert: false,
              ),
            );

        final String fechaFormateada = DateFormat('dd/MM/yyyy').format(DateTime.now());
        final Map<String, dynamic> nuevoInformeObjeto = {
          'nombre_archivo': nombreArchivo,
          'fecha_subida': fechaFormateada,
          'fecha_subida_raw': Timestamp.now(),
          'ruta_archivo': rutaArchivoSupabase,
          'es_supabase': true,
        };

        // NOTA: Mantenemos el estado actual del widget en vez de forzar 'Completado'
        await FirebaseFirestore.instance
            .collection('empleados')
            .doc(documentoId)
            .update({
              'fichaPsicologica': 'Informe adjunto: $nombreArchivo',
              'urlPdf': rutaArchivoSupabase,
              'informes': FieldValue.arrayUnion([nuevoInformeObjeto]),
            });

        final Map<String, dynamic> copiaDatos = Map<String, dynamic>.from(widget.derivacion);
        // Preservamos el estado en el que venía el caso (generalmente 'En Proceso')
        copiaDatos['estado'] = widget.estadoActual; 
        copiaDatos['fichaPsicologica'] = 'Informe adjunto: $nombreArchivo';
        copiaDatos['urlPdf'] = rutaArchivoSupabase;
        
        if (copiaDatos['informes'] == null) {
          copiaDatos['informes'] = [];
        }
        (copiaDatos['informes'] as List).add(nuevoInformeObjeto);

        // Notificamos el cambio manteniendo el estado actual
        widget.onActualizarCaso(widget.estadoActual, copiaDatos);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Informe añadido con éxito! Puedes seguir subiendo más.'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir a Supabase: $e'), 
            backgroundColor: Colors.red.shade800, 
            behavior: SnackBarBehavior.floating
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _estaSubiendo = false);
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
              _construirOpcionEstado('Pendiente', Icons.hourglass_empty),
              const Divider(),
              _construirOpcionEstado('En Proceso', Icons.autorenew),
              const Divider(),
              _construirOpcionEstado('Completado', Icons.check_circle_outline),
            ],
          ),
        );
      },
    );
  }

  Widget _construirOpcionEstado(String estado, IconData icon) {
    final bool esActivo = widget.estadoActual == estado;
    final Color colorContexto = _colorTextoEstado(estado);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _colorEstado(estado),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: colorContexto)
      ),
      title: Text(estado, style: TextStyle(fontWeight: esActivo ? FontWeight.bold : FontWeight.w500, color: colorContexto)),
      trailing: esActivo ? Icon(Icons.check, color: colorContexto) : null,
      onTap: () async {
        Navigator.pop(context);
        
        if (estado == 'Completado') {
          bool confirmar = await _mostrarAdvertenciaCompletado();
          if (!confirmar) return; 
        }
        
        _persistirEstadoEnFirebase(estado);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool yaEstaCompletado = widget.estadoActual == 'Completado';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              if (widget.estadoActual == 'Pendiente') {
                await _persistirEstadoEnFirebase('En Proceso');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El caso ya se encuentra ${widget.estadoActual}'), backgroundColor: Colors.grey.shade700),
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
          
          ContainerComprobanteBoton(derivacion: widget.derivacion),
          
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
          ElevatedButton.icon(
            onPressed: (_estaSubiendo || yaEstaCompletado) ? null : _seleccionarYSubirInforme,
            icon: _estaSubiendo 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.assignment_turned_in_outlined, color: Colors.white),
            label: Text(
              _estaSubiendo ? 'Cargando Archivo...' : 'Subir Informe Psicológico', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: yaEstaCompletado ? Colors.grey : const Color(0xFF4CAF50),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
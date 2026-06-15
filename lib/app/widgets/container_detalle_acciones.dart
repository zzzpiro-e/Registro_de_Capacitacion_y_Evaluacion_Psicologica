import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'container_comprobante_boton.dart';
import 'package:proyecto_flutter/app/services/auditoria_service.dart';

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
  State<ContainerDetalleAcciones> createState() =>
      _ContainerDetalleAccionesState();
}

class _ContainerDetalleAccionesState extends State<ContainerDetalleAcciones> {
  bool _estaSubiendo = false;
  bool _mostrarMenuAcciones = false;

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return const Color(0xFFFFF3CD);
      case 'En Proceso':
        return const Color(0xFFD0E2FF);
      case 'Completado':
        return const Color(0xFFDFFFD6);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _colorTextoEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return const Color(0xFFB8860B);
      case 'En Proceso':
        return const Color(0xFF0056B3);
      case 'Completado':
        return const Color(0xFF2E7D32);
      default:
        return Colors.black54;
    }
  }

  Future<bool> _mostrarAdvertenciaCompletado() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                '¿Finalizar Derivación?',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Sí, Completar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

        final String nombreEmpleado = widget.derivacion['nombre'] ?? 'Empleado';
        await AuditoriaService.psicologoActualizoDerivacion(
          nombreEmpleado: nombreEmpleado,
          estadoNuevo: nuevoEstado,
        );

        final Map<String, dynamic> copiaDatos = Map<String, dynamic>.from(
          widget.derivacion,
        );
        copiaDatos['estado'] = nuevoEstado;
        widget.onActualizarCaso(nuevoEstado, copiaDatos);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarYSubirInforme() async {
    if (_estaSubiendo) return;

    final listadoInformesActuales = widget.derivacion['informes'] as List?;
    if (listadoInformesActuales != null &&
        listadoInformesActuales.length >= 4) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Límite alcanzado: Máximo 4 informes por derivación.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.amber.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _estaSubiendo = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final platformFile = result.files.single;

        const int maxBytes = 5 * 1024 * 1024;
        if (platformFile.size > maxBytes) {
          if (mounted) {
            final double tamanoEnMB = platformFile.size / (1024 * 1024);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'El archivo supera el límite de 5 MB. (Peso actual: ${tamanoEnMB.toStringAsFixed(2)} MB)',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          setState(() => _estaSubiendo = false);
          return;
        }

        final String nombreArchivo = platformFile.name;
        final Uint8List archivoBytes = platformFile.bytes!;

        String documentoId = widget.derivacion['id'] ?? '';
        if (documentoId.isEmpty) {
          final String rutSocio = widget.derivacion['rut'] ?? '';
          documentoId = rutSocio.replaceAll('.', '').replaceAll('-', '').trim();
        }

        if (documentoId.isEmpty) throw 'RUT del trabajador no disponible.';

        final String timestampUnico = DateTime.now().millisecondsSinceEpoch
            .toString();
        final String rutaArchivoSupabase =
            '$documentoId/${timestampUnico}_$nombreArchivo';

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

        final String fechaFormateada = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.now());
        final Map<String, dynamic> nuevoInformeObjeto = {
          'nombre_archivo': nombreArchivo,
          'fecha_subida': fechaFormateada,
          'fecha_subida_raw': Timestamp.now(),
          'ruta_archivo': rutaArchivoSupabase,
          'es_supabase': true,
        };

        await FirebaseFirestore.instance
            .collection('empleados')
            .doc(documentoId)
            .update({
              'fichaPsicologica': 'Informe adjunto: $nombreArchivo',
              'urlPdf': rutaArchivoSupabase,
              'informes': FieldValue.arrayUnion([nuevoInformeObjeto]),
            });

        final Map<String, dynamic> copiaDatos = Map<String, dynamic>.from(
          widget.derivacion,
        );
        copiaDatos['estado'] = widget.estadoActual;
        copiaDatos['fichaPsicologica'] = 'Informe adjunto: $nombreArchivo';
        copiaDatos['urlPdf'] = rutaArchivoSupabase;

        if (copiaDatos['informes'] == null) copiaDatos['informes'] = [];
        (copiaDatos['informes'] as List).add(nuevoInformeObjeto);

        widget.onActualizarCaso(widget.estadoActual, copiaDatos);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Informe añadido con éxito!'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _estaSubiendo = false);
    }
  }

  void _mostrarMenuEstados() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Modificar Estado',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorContexto),
      ),
      title: Text(
        estado,
        style: TextStyle(
          fontWeight: esActivo ? FontWeight.bold : FontWeight.w500,
          color: colorContexto,
        ),
      ),
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
    final Map<String, dynamic> datosMapeadosParaPdf = Map<String, dynamic>.from(
      widget.derivacion,
    );
    datosMapeadosParaPdf['id_documento'] = widget.derivacion['id'] ?? 'N/A';

    final listadoInformesActuales = widget.derivacion['informes'] as List?;
    final bool alcanzoLimitePdfs =
        listadoInformesActuales != null && listadoInformesActuales.length >= 4;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _mostrarMenuAcciones
                ? Container(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (widget.estadoActual == 'Pendiente') {
                              await _persistirEstadoEnFirebase('En Proceso');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'El caso ya se encuentra ${widget.estadoActual}',
                                  ),
                                  backgroundColor: Colors.grey.shade700,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.play_arrow_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Iniciar Atención',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ContainerComprobanteBoton(
                          derivacion: datosMapeadosParaPdf,
                        ),
                        const SizedBox(height: 10),

                        OutlinedButton.icon(
                          onPressed: _estaSubiendo ? null : _mostrarMenuEstados,
                          icon: const Icon(
                            Icons.edit_note_outlined,
                            color: Color(0xFF2E7D32),
                          ),
                          label: const Text(
                            'Cambiar Estado',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF2E7D32),
                              width: 1.5,
                            ),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        ElevatedButton.icon(
                          onPressed: (_estaSubiendo || yaEstaCompletado)
                              ? null
                              : _seleccionarYSubirInforme,
                          icon: _estaSubiendo
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.assignment_turned_in_outlined,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _estaSubiendo
                                ? 'Cargando Archivo...'
                                : alcanzoLimitePdfs
                                ? 'Límite alcanzado (4/4 PDFs)'
                                : 'Subir Informe Psicológico',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yaEstaCompletado
                                ? Colors.grey
                                : alcanzoLimitePdfs
                                ? Colors.orange.shade800
                                : const Color(0xFF4CAF50),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 24, thickness: 1),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _mostrarMenuAcciones = !_mostrarMenuAcciones;
                });
              },
              icon: Icon(
                _mostrarMenuAcciones
                    ? Icons.keyboard_arrow_down
                    : Icons.layers_outlined,
                color: Colors.white,
                size: 22,
              ),
              label: Text(
                _mostrarMenuAcciones ? 'Ocultar Opciones' : 'Acciones del Caso',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ContainerDetalleCaso extends StatefulWidget {
  final Map<String, dynamic> datos;
  final Function(Map<String, dynamic>)? onInformeEliminado; 

  const ContainerDetalleCaso({
    super.key,
    required this.datos,
    this.onInformeEliminado,
  });

  @override
  State<ContainerDetalleCaso> createState() => _ContainerDetalleCasoState();
}

class _ContainerDetalleCasoState extends State<ContainerDetalleCaso> {
  // Copia local mutable para controlar el estado en tiempo real
  late Map<String, dynamic> _datosLocales;

  @override
  void initState() {
    super.initState();
    _datosLocales = Map<String, dynamic>.from(widget.datos);
  }

  @override
  void didUpdateWidget(covariant ContainerDetalleCaso oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si los datos externos cambian desde el padre, actualizamos la copia local
    _datosLocales = Map<String, dynamic>.from(widget.datos);
  }

  void _abrirVisorPdf(BuildContext context, String rutaOUrl, String nombreArchivo, {bool esSupabase = false}) async {
    if (rutaOUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El archivo "$nombreArchivo" no tiene una referencia válida.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
    );

    try {
      String urlFinal = rutaOUrl;

      if (esSupabase) {
        final String urlFirmada = await Supabase.instance.client.storage
            .from('informes_psicologicos')
            .createSignedUrl(rutaOUrl, 60);
        
        urlFinal = urlFirmada;
      }

      final response = await http.get(Uri.parse(urlFinal));
      if (response.statusCode != 200) throw 'Error al descargar el informe desde el servidor web.';

      final dir = await getTemporaryDirectory();
      final archivoLocal = File('${dir.path}/$nombreArchivo');
      await archivoLocal.writeAsBytes(response.bodyBytes);

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        Navigator.pushNamed(
          context, 
          'visor_pdf', 
          arguments: {
            'rutaLocal': archivoLocal.path,
            'nombreArchivo': nombreArchivo,
          },
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el archivo de forma interna: $e'), 
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _eliminarInformeDirecto(BuildContext context, Map<String, dynamic> informeObjeto) async {
    final bool confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar documento?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que deseas eliminar el archivo "${informeObjeto['nombre_archivo']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    try {
      String documentoId = _datosLocales['id'] ?? '';
      if (documentoId.isEmpty) {
        final String rutSocio = _datosLocales['rut'] ?? '';
        documentoId = rutSocio.replaceAll('.', '').replaceAll('-', '').trim();
      }

      final String rutaArchivoSupabase = informeObjeto['ruta_archivo'] ?? '';

      // 1. Borrar de Supabase Storage
      if (rutaArchivoSupabase.isNotEmpty && (informeObjeto['es_supabase'] ?? false)) {
        await Supabase.instance.client.storage
            .from('informes_psicologicos')
            .remove([rutaArchivoSupabase]);
      }

      // 2. Borrar de la lista en Firestore
      await FirebaseFirestore.instance
          .collection('empleados')
          .doc(documentoId)
          .update({
            'informes': FieldValue.arrayRemove([informeObjeto]),
          });

      // 3. Reajustar campos principales de la ficha de forma síncrona en Firestore
      final List informesRestantes = List.from(_datosLocales['informes'] ?? []);
      informesRestantes.removeWhere((element) => element['ruta_archivo'] == rutaArchivoSupabase);

      if (informesRestantes.isEmpty) {
        await FirebaseFirestore.instance.collection('empleados').doc(documentoId).update({
          'fichaPsicologica': '',
          'urlPdf': '',
        });
      } else {
        final ultimo = informesRestantes.last;
        await FirebaseFirestore.instance.collection('empleados').doc(documentoId).update({
          'fichaPsicologica': 'Informe adjunto: ${ultimo['nombre_archivo']}',
          'urlPdf': ultimo['ruta_archivo'],
        });
      }

      // 🛠️ CAMBIO CLAVE: Cambiamos el estado local de forma reactiva con setState interno
      setState(() {
        if (_datosLocales['informes'] != null) {
          (_datosLocales['informes'] as List).removeWhere((inf) => inf['ruta_archivo'] == rutaArchivoSupabase);
        }
        
        if (_datosLocales['urlPdf'] == rutaArchivoSupabase || _datosLocales['url_pdf'] == rutaArchivoSupabase) {
          if (informesRestantes.isEmpty) {
            _datosLocales['fichaPsicologica'] = '';
            _datosLocales['urlPdf'] = '';
            _datosLocales['url_pdf'] = '';
          } else {
            final ultimo = informesRestantes.last;
            _datosLocales['fichaPsicologica'] = 'Informe adjunto: ${ultimo['nombre_archivo']}';
            _datosLocales['urlPdf'] = ultimo['ruta_archivo'];
            _datosLocales['url_pdf'] = ultimo['ruta_archivo'];
          }
        }
      });

      if (context.mounted) Navigator.pop(context); // Quitar Loader

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento eliminado con éxito'), backgroundColor: Colors.black87),
        );
      }

      if (widget.onInformeEliminado != null) {
        widget.onInformeEliminado!(_datosLocales);
      }

    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Quitar Loader
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _obtenerFechaFormateada(dynamic fechaFormato) {
    if (fechaFormato is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(fechaFormato.toDate());
    }
    if (fechaFormato is DateTime) {
      return DateFormat('dd/MM/yyyy').format(fechaFormato);
    }
    if (fechaFormato is String && fechaFormato.isNotEmpty) {
      String limpio = fechaFormato.toLowerCase().trim();
      if (limpio == 'hoy') {
        return DateFormat('dd/MM/yyyy').format(DateTime.now());
      }
      final parseada = DateTime.tryParse(fechaFormato);
      if (parseada != null) {
        return DateFormat('dd/MM/yyyy').format(parseada);
      }
      return fechaFormato;
    }
    return 'No especificada';
  }

  @override
  Widget build(BuildContext context) {
    final String estadoActual = _datosLocales['estado'] ?? 'Pendiente';
    final bool yaEstaCompletado = estadoActual == 'Completado';

    final List<Map<String, dynamic>> informesOrdenados = [];

    if (_datosLocales['informes'] != null) {
      final List informesRaw = _datosLocales['informes'];
      informesOrdenados.addAll(List<Map<String, dynamic>>.from(informesRaw));
    } 
    
    if (_datosLocales['fichaPsicologica'] != null && _datosLocales['fichaPsicologica'].toString().isNotEmpty) {
      final String nombreLimpio = _datosLocales['fichaPsicologica'].toString().replaceAll('Informe adjunto: ', '');
      
      bool yaExiste = informesOrdenados.any((inf) => inf['nombre_archivo'] == nombreLimpio);
      
      if (!yaExiste) {
        dynamic rawFecha = _datosLocales['derivacionFecha'] ?? _datosLocales['fecha'];
        DateTime fechaObtenida;

        if (rawFecha is Timestamp) {
          fechaObtenida = rawFecha.toDate();
        } else if (rawFecha is DateTime) {
          fechaObtenida = rawFecha;
        } else if (rawFecha is String && rawFecha.toLowerCase().trim() == 'hoy') {
          fechaObtenida = DateTime.now();
        } else if (rawFecha is String) {
          fechaObtenida = DateTime.tryParse(rawFecha) ?? DateTime.now();
        } else {
          fechaObtenida = DateTime.now();
        }

        String stringFechaSubida = _obtenerFechaFormateada(_datosLocales['derivacionFecha'] ?? _datosLocales['fecha'] ?? 'hoy');

        informesOrdenados.add({
          'nombre_archivo': nombreLimpio,
          'fecha_subida': stringFechaSubida,
          'fecha_subida_raw': fechaObtenida, 
          'ruta_archivo': _datosLocales['urlPdf'] ?? _datosLocales['url_pdf'] ?? '', 
          'es_supabase': false,
        });
      }
    }

    informesOrdenados.sort((a, b) {
      final DateTime fechaA = a['fecha_subida_raw'] is DateTime 
          ? a['fecha_subida_raw'] 
          : (a['fecha_subida_raw'] is Timestamp 
              ? (a['fecha_subida_raw'] as Timestamp).toDate() 
              : DateTime.now());
          
      final DateTime fechaB = b['fecha_subida_raw'] is DateTime 
          ? b['fecha_subida_raw'] 
          : (b['fecha_subida_raw'] is Timestamp 
              ? (b['fecha_subida_raw'] as Timestamp).toDate() 
              : DateTime.now());
          
      return fechaB.compareTo(fechaA);
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined, color: Color(0xFF2E7D32), size: 24),
              SizedBox(width: 10),
              Text(
                'Detalles de la Derivación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fecha de Derivación', 
                style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                _obtenerFechaFormateada(_datosLocales['derivacionFecha'] ?? _datosLocales['fecha'] ?? 'hoy'),
                style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          const Text(
            'Informes y Documentos Adjuntos',
            style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          if (informesOrdenados.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No hay informes psicológicos adjuntos.',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
              ),
            )
          else
            ...informesOrdenados.map((informe) {
              final String urlArchivo = informe['ruta_archivo'] ?? '';
              final String nombreDelPdf = informe['nombre_archivo'] ?? 'Archivo_Sin_Nombre.pdf';
              final bool esSupa = informe['es_supabase'] ?? false;
              final String fechaSubida = informe['fecha_subida'] ?? 'No especificada';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: Color(0xFFC62828), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombreDelPdf,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Subido: $fechaSubida',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
          ),
                        ],
                      ),
                    ),
                    
                    if (!yaEstaCompletado)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _eliminarInformeDirecto(context, informe),
                      ),

                    IconButton(
                      icon: const Icon(Icons.open_in_new, color: Color(0xFF2E7D32)),
                      onPressed: () => _abrirVisorPdf(context, urlArchivo, nombreDelPdf, esSupabase: esSupa),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
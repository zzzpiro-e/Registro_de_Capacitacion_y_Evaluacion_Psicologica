import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ContainerDetalleCaso extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ContainerDetalleCaso({
    super.key,
    required this.datos,
  });

  // Metodo para descargar el archivo PDF, generar la URL firmada de Supabase si corresponde
  // y abrir el archivo descargado en el visor nativo de la aplicacion.
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

    // Despliegue del indicador de carga mientras se procesa el archivo.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
    );

    try {
      String urlFinal = rutaOUrl;

      // Obtencion de la URL firmada temporal si el archivo esta alojado en el bucket de Supabase.
      if (esSupabase) {
        final String urlFirmada = await Supabase.instance.client.storage
            .from('informes_psicologicos')
            .createSignedUrl(rutaOUrl, 60);
        
        urlFinal = urlFirmada;
      }

      // Descarga de los bytes del archivo a traves de una peticion HTTP.
      final response = await http.get(Uri.parse(urlFinal));
      if (response.statusCode != 200) throw 'Error al descargar el informe desde el servidor web.';

      // Escritura del archivo de forma local en el directorio temporal del dispositivo.
      final dir = await getTemporaryDirectory();
      final archivoLocal = File('${dir.path}/$nombreArchivo');
      await archivoLocal.writeAsBytes(response.bodyBytes);

      // Cierre del indicador de carga de manera segura.
      if (context.mounted) Navigator.pop(context);

      // Redireccion al visor PDF nativo pasando la ruta del archivo local obtenido en cache.
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

  /// Formateador seguro que intercepta 'hoy' y calcula el día real del calendario
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
      // Intenta parsear por si viene una cadena tipo ISO (ej: 2026-06-06)
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
    // Lista local destinada a unificar y ordenar los documentos recuperados de la base de datos.
    final List<Map<String, dynamic>> informesOrdenados = [];

    // Validacion e incorporacion del arreglo estructurado de informes historicos.
    if (datos['informes'] != null) {
      final List informesRaw = datos['informes'];
      informesOrdenados.addAll(List<Map<String, dynamic>>.from(informesRaw));
    } 
    
    // Validacion, parseo y extraccion del documento unico basado en la estructura clasica del documento.
    if (datos['fichaPsicologica'] != null && datos['fichaPsicologica'].toString().isNotEmpty) {
      final String nombreLimpio = datos['fichaPsicologica'].toString().replaceAll('Informe adjunto: ', '');
      
      bool yaExiste = informesOrdenados.any((inf) => inf['nombre_archivo'] == nombreLimpio);
      
      if (!yaExiste) {
        // Evaluamos la fecha cruda para guardarla como un DateTime puro y real en informesOrdenados
        dynamic rawFecha = datos['derivacionFecha'] ?? datos['fecha'];
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

        // Usamos el formateador interno para pasarle un string amigable al campo 'fecha_subida'
        String stringFechaSubida = _obtenerFechaFormateada(datos['derivacionFecha'] ?? datos['fecha'] ?? 'hoy');

        informesOrdenados.add({
          'nombre_archivo': nombreLimpio,
          'fecha_subida': stringFechaSubida,
          'fecha_subida_raw': fechaObtenida, // Garantizado un objeto DateTime real
          'ruta_archivo': datos['urlPdf'] ?? datos['url_pdf'] ?? '', 
          'es_supabase': false,
        });
      }
    }

    // Ordenamiento de la lista final de informes por fecha de subida real (de más reciente a más antigua)
    informesOrdenados.sort((a, b) {
      final DateTime fechaA = a['fecha_subida_raw'] is DateTime 
          ? a['fecha_subida_raw'] 
          : (a['fecha_subida_raw'] is Timestamp 
              ? (a['fecha_subida_raw'] as Timestamp).toDate() 
              : DateTime.now());
          
      final DateTime fechaB = b['fecha_subida_raw'] is DateTime 
          ? a['fecha_subida_raw'] 
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
          // Seccion del encabezado del contenedor de detalles.
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
          
          // Despliegue de la fecha de derivacion obtenida en tiempo real y formateada.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fecha de Derivación', 
                style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                _obtenerFechaFormateada(datos['derivacionFecha'] ?? datos['fecha'] ?? 'hoy'),
                style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // Seccion informativa encargada de listar los archivos adjuntos.
          const Text(
            'Informes y Documentos Adjuntos',
            style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Validacion del estado de la coleccion de documentos. Despliega un indicador textual si esta vacia.
          if (informesOrdenados.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No hay informes psicológicos adjuntos.',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
              ),
            )
          else
            // Generacion dinamica de las tarjetas visuales basadas en la informacion procesada de los PDFs.
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
                    // Contenedor del icono del formato PDF.
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: Color(0xFFC62828), size: 24),
                    ),
                    const SizedBox(width: 14),
                    // Detalle del nombre y la fecha de subida del documento.
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
                    // Boton de accion que invoca el metodo de descarga y despliegue del visor in-app.
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
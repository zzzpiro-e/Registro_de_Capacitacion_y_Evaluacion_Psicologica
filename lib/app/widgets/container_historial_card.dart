import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ContainerHistorialCard extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ContainerHistorialCard({
    super.key,
    required this.datos,
  });

  // 🚀 VISOR IN-APP: Generación de URL firmada, descarga a caché y apertura interna
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

    // 🔄 Desplegamos un indicador de carga asíncrono para que el usuario sepa que se está procesando
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
    );

    try {
      String urlFinal = rutaOUrl;

      // 1. Si el archivo está alojado en Supabase, solicitamos el enlace firmado temporal
      if (esSupabase) {
        final String urlFirmada = await Supabase.instance.client.storage
            .from('informes_psicologicos')
            .createSignedUrl(rutaOUrl, 60);
        
        urlFinal = urlFirmada;
      }

      // 2. Descargamos el archivo binario mediante una petición HTTP rápida
      final response = await http.get(Uri.parse(urlFinal));
      if (response.statusCode != 200) throw 'Error al descargar el informe desde el servidor web.';

      // 3. Escribimos los bytes de manera local en el directorio temporal del dispositivo
      final dir = await getTemporaryDirectory();
      final archivoLocal = File('${dir.path}/$nombreArchivo');
      await archivoLocal.writeAsBytes(response.bodyBytes);

      // 4. Cerramos el diálogo de carga de forma segura
      if (context.mounted) Navigator.pop(context);

      // 5. Redirigimos a la pantalla visora nativa inyectando los argumentos requeridos
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
      // Si ocurre un error, removemos el loader antes de alertar con el SnackBar
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

  // Método modular para abrir la bandeja inferior de informes adjuntos
  void _mostrarListaInformes(BuildContext context) {
    final List<Map<String, dynamic>> informesOrdenados = [];

    // Validamos si tiene un arreglo estructurado de informes recurrentes
    if (datos['informes'] != null) {
      final List informesRaw = datos['informes'];
      informesOrdenados.addAll(List<Map<String, dynamic>>.from(informesRaw));
    } 
    
    // Si no tiene el arreglo pero sí el campo individual clásico visible en Firestore, lo mapeamos
    if (datos['fichaPsicologica'] != null && datos['fichaPsicologica'].toString().isNotEmpty) {
      final String nombreLimpio = datos['fichaPsicologica'].toString().replaceAll('Informe adjunto: ', '');
      
      bool yaExiste = informesOrdenados.any((inf) => inf['nombre_archivo'] == nombreLimpio);
      
      if (!yaExiste) {
        informesOrdenados.add({
          'nombre_archivo': nombreLimpio,
          'fecha_subida': datos['fecha'] ?? 'Hoy',
          'fecha_subida_raw': datos['derivacionFecha'] is Timestamp 
              ? (datos['derivacionFecha'] as Timestamp).toDate() 
              : DateTime.now(),
          'ruta_archivo': datos['urlPdf'] ?? datos['url_pdf'] ?? '', 
          'es_supabase': false, // Si es el campo clásico antiguo, asumimos que no viene de Supabase
        });
      }
    }

    // Ordenamos cronológicamente: El más reciente arriba
    informesOrdenados.sort((a, b) {
      final DateTime fechaA = a['fecha_subida_raw'] is Timestamp 
          ? (a['fecha_subida_raw'] as Timestamp).toDate() 
          : (a['fecha_subida_raw'] ?? DateTime.now());
          
      final DateTime fechaB = b['fecha_subida_raw'] is Timestamp 
          ? (b['fecha_subida_raw'] as Timestamp).toDate() 
          : (b['fecha_subida_raw'] ?? DateTime.now());
          
      return fechaB.compareTo(fechaA);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Informes de ${datos['nombre']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Historial de archivos PDF subidos (Más recientes primero)',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                
                if (informesOrdenados.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.picture_as_pdf_outlined, color: Colors.grey.shade400, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No hay informes psicológicos adjuntos.',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: informesOrdenados.length,
                      itemBuilder: (context, index) {
                        final informe = informesOrdenados[index];
                        final String urlArchivo = informe['ruta_archivo'] ?? '';
                        final String nombreDelPdf = informe['nombre_archivo'] ?? 'Archivo_Sin_Nombre.pdf';
                        final bool esSupa = informe['es_supabase'] ?? false; // Captura reactiva del flag

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
                                      'Subido: ${informe['fecha_subida']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // 🟢 MODIFICACIÓN: El botón del modal ahora gatilla el visor In-App nativo
                              IconButton(
                                icon: const Icon(Icons.open_in_new, color: Color(0xFF2E7D32)),
                                onPressed: () => _abrirVisorPdf(context, urlArchivo, nombreDelPdf, esSupabase: esSupa),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color verdePrincipal = const Color(0xFF2E7D32);
    final Color verdeBotonVer = const Color(0xFF1B5E20);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: verdePrincipal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  datos['nombre'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            'RUT: ${datos['rut'] ?? ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            datos['motivo'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 14),
              const SizedBox(width: 6),
              Text(
                'Evaluado el ${datos['fecha'] ?? ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarListaInformes(context),
                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.white),
                  label: const Text('Ver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeBotonVer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 🟢 MODIFICACIÓN: El botón "Descargar" rápido de la tarjeta también descarga y abre In-App de forma segura
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final String urlDescargaDirecta = datos['urlPdf'] ?? datos['url_pdf'] ?? '';
                    final String nombreDoc = datos['fichaPsicologica'] ?? 'informe.pdf';
                    // Evaluamos si el string de la URL contiene el patrón de carpetas de Supabase para forzar el flag de renderizado
                    final bool esSupa = urlDescargaDirecta.contains('/') && !urlDescargaDirecta.startsWith('http');
                    _abrirVisorPdf(context, urlDescargaDirecta, nombreDoc, esSupabase: esSupa);
                  },
                  icon: Icon(Icons.download_outlined, size: 18, color: verdeBotonVer),
                  label: Text('Descargar', style: TextStyle(color: verdeBotonVer, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: verdeBotonVer, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
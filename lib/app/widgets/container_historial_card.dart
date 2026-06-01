import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ContainerHistorialCard extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ContainerHistorialCard({
    super.key,
    required this.datos,
  });

  /// Método para abrir el enlace del PDF en el navegador o visor del dispositivo
  void _abrirVisorPdf(BuildContext context, String urlString, String nombreArchivo) async {
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El archivo "$nombreArchivo" no tiene una URL de descarga válida.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir la URL';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el PDF: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // Método modular para abrir la bandeja inferior de informes adjuntos
  void _mostrarListaInformes(BuildContext context) {
    // Construimos la lista final combinando la estructura real detectada en la base de datos
    final List<Map<String, dynamic>> informesOrdenados = [];

    // 1. Validamos si tiene un arreglo estructurado de informes recurrentes
    if (datos['informes'] != null) {
      final List informesRaw = datos['informes'];
      informesOrdenados.addAll(List<Map<String, dynamic>>.from(informesRaw));
    } 
    
    // 2. Si no tiene el arreglo pero sí el campo individual clásico visible en Firestore, lo mapeamos
    if (datos['fichaPsicologica'] != null && datos['fichaPsicologica'].toString().isNotEmpty) {
      // Limpiamos el prefijo de texto estático si es que viene formateado
      final String nombreLimpio = datos['fichaPsicologica'].toString().replaceAll('Informe adjunto: ', '');
      
      // Evitamos duplicar si por casualidad ya está en el arreglo superior
      bool yaExiste = informesOrdenados.any((inf) => inf['nombre_archivo'] == nombreLimpio);
      
      if (!yaExiste) {
        informesOrdenados.add({
          'nombre_archivo': nombreLimpio,
          'fecha_subida': datos['fecha'] ?? 'Hoy',
          // Firebase inyecta marcas de tiempo como Timestamp, manejamos el fallback seguro
          'fecha_subida_raw': datos['derivacionFecha'] is Timestamp 
              ? (datos['derivacionFecha'] as Timestamp).toDate() 
              : DateTime.now(),
          'ruta_archivo': datos['urlPdf'] ?? datos['url_pdf'] ?? '', // Atrapamos el enlace de Firebase Storage
        });
      }
    }

    // Ordenamos dinámicamente: El más reciente arriba basándonos en el DateTime o Timestamp normalizado
    informesOrdenados.sort((a, b) {
      final DateTime fechaA = a['fecha_subida_raw'] is Timestamp 
          ? (a['fecha_subida_raw'] as Timestamp).toDate() 
          : (a['fecha_subida_raw'] ?? DateTime.now());
          
      final DateTime fechaB = b['fecha_subida_raw'] is Timestamp 
          ? (b['fecha_subida_raw'] as Timestamp).toDate() 
          : (b['fecha_subida_raw'] ?? DateTime.now());
          
      return fechaB.compareTo(fechaA); // b comparado con a genera el orden descendente (más nuevo primero)
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
                // Línea decorativa superior del modal
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
                
                // Título descriptivo con el nombre del trabajador
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
                
                // Condicional: Si no hay archivos, renderizamos un aviso centrado
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
                  // Listado dinámico con scroll adaptativo
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: informesOrdenados.length,
                      itemBuilder: (context, index) {
                        final informe = informesOrdenados[index];
                        final String urlArchivo = informe['ruta_archivo'] ?? '';
                        final String nombreDelPdf = informe['nombre_archivo'] ?? 'Archivo_Sin_Nombre.pdf';

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
                              // Icono descriptivo de PDF
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.picture_as_pdf, color: Color(0xFFC62828), size: 24),
                              ),
                              const SizedBox(width: 14),
                              
                              // Detalles del archivo (Nombre y Tiempo de carga)
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
                              
                              // Botón de acción rápida para abrir y visualizar el PDF real
                              IconButton(
                                icon: const Icon(Icons.open_in_new, color: Color(0xFF2E7D32)),
                                onPressed: () => _abrirVisorPdf(context, urlArchivo, nombreDelPdf),
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
    // Paleta institucional
    final Color verdePrincipal = const Color(0xFF2E7D32); // Verde oscuro para textos/bordes
    final Color verdeBotonVer = const Color(0xFF1B5E20);  // Verde sólido para el botón "Ver"

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
          // Nombre con Icono de Usuario
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

          // RUT
          Text(
            'RUT: ${datos['rut'] ?? ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),

          // Motivo / Tipo de Informe
          Text(
            datos['motivo'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),

          // Fecha de Evaluación
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

          // Botones de Acción de la Tarjeta
          Row(
            children: [
              // Botón "Ver" (¡CONECTADO E INTELIGENTE!)
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
              
              // Botón "Descargar" (Abre directo el PDF del último documento disponible)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final String urlDescargaDirecta = datos['urlPdf'] ?? datos['url_pdf'] ?? '';
                    final String nombreDoc = datos['fichaPsicologica'] ?? 'informe.pdf';
                    _abrirVisorPdf(context, urlDescargaDirecta, nombreDoc);
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
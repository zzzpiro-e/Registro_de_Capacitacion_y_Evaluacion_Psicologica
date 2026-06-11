import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Importante para formatear la fecha de forma limpia
import '../services/informes_descarga_service.dart';
import '../widgets/container_historial_header.dart';
import '../widgets/container_fila_informe.dart';

class HistorialInformesScreen extends StatelessWidget {
  const HistorialInformesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final archivoService = ArchivoService();

    final datos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<Map<String, dynamic>> informesOrdenados = [];

    if (datos['informes'] != null) {
      final List informesRaw = datos['informes'];
      informesOrdenados.addAll(List<Map<String, dynamic>>.from(informesRaw));
    } 

    if (datos['fichaPsicologica'] != null && datos['fichaPsicologica'].toString().isNotEmpty) {
      final String nombreLimpio = datos['fichaPsicologica'].toString().replaceAll('Informe adjunto: ', '');
      bool yaExiste = informesOrdenados.any((inf) => inf['nombre_archivo'] == nombreLimpio);
      
      if (!yaExiste) {
        // 🔹 CORRECCIÓN: Validamos y formateamos la fecha de subida para que SIEMPRE sea un String legible
        String fechaSubidaString = 'Hoy';
        if (datos['fechaDerivacion'] is Timestamp) {
          fechaSubidaString = DateFormat('dd/MM/yyyy').format((datos['fechaDerivacion'] as Timestamp).toDate());
        } else if (datos['fecha'] != null) {
          fechaSubidaString = datos['fecha'].toString();
        }

        informesOrdenados.add({
          'nombre_archivo': nombreLimpio,
          'fecha_subida': fechaSubidaString, // 🔹 Ahora garantizamos que es un String y no romperá el widget
          'fecha_subida_raw': datos['derivacionFecha'] is Timestamp 
              ? (datos['derivacionFecha'] as Timestamp).toDate() 
              : DateTime.now(),
          'ruta_archivo': datos['urlPdf'] ?? datos['url_pdf'] ?? '', 
          'es_supabase': false,
        });
      }
    }

    informesOrdenados.sort((a, b) {
      final DateTime fechaA = a['fecha_subida_raw'] is Timestamp ? (a['fecha_subida_raw'] as Timestamp).toDate() : (a['fecha_subida_raw'] ?? DateTime.now());
      final DateTime fechaB = b['fecha_subida_raw'] is Timestamp ? (b['fecha_subida_raw'] as Timestamp).toDate() : (b['fecha_subida_raw'] ?? DateTime.now());
      return fechaB.compareTo(fechaA);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Informes Psicológicos', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerHistorialHeader(
                nombre: datos['nombre'] ?? 'Colaborador', 
                rut: datos['rut'] ?? 'Sin RUT',
              ),
              const SizedBox(height: 20),
              const Text('Documentos Adjuntos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),

              Expanded(
                child: informesOrdenados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.picture_as_pdf_outlined, color: Colors.grey.shade400, size: 54),
                            const SizedBox(height: 12),
                            Text('No se registran informes cargados.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: informesOrdenados.length,
                        itemBuilder: (context, index) {
                          final informe = informesOrdenados[index];
                          final String urlArchivo = informe['ruta_archivo'] ?? '';
                          final String nombreDelPdf = informe['nombre_archivo'] ?? 'Informe_Psicologico.pdf';
                          final bool esSupa = informe['es_supabase'] ?? false;

                          // 🔹 CONTROL DE SEGURIDAD EXTRA: Si por alguna razón externa aún se colara un Timestamp, lo parseamos aquí
                          String fechaMuestra = 'Hoy';
                          if (informe['fecha_subida'] is Timestamp) {
                            fechaMuestra = DateFormat('dd/MM/yyyy').format((informe['fecha_subida'] as Timestamp).toDate());
                          } else if (informe['fecha_subida'] != null) {
                            fechaMuestra = informe['fecha_subida'].toString();
                          }

                          return ContainerInformeRow(
                            nombreArchivo: nombreDelPdf,
                            fechaSubida: fechaMuestra, // Enviamos estrictamente el String mapeado de forma segura
                            onVisualizar: () => archivoService.abrirVisorPdf(context, urlArchivo, nombreDelPdf, esSupa),
                            onDescargar: () => archivoService.descargarPdfAlTelefono(context, urlArchivo, nombreDelPdf, esSupa),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
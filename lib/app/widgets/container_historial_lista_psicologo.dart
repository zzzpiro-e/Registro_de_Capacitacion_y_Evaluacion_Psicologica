// Archivo: container_historial_lista_psicologo.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/informes_descarga_service.dart';
import 'container_fila_informe.dart';

class ContainerHistorialListaPsicologo extends StatelessWidget {
  final List<Map<String, dynamic>> informes;
  final ArchivoService archivoService;

  const ContainerHistorialListaPsicologo({
    super.key,
    required this.informes,
    required this.archivoService,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: informes.length,
      itemBuilder: (context, index) {
        final informe = informes[index];
        final String urlArchivo = informe['ruta_archivo'] ?? '';
        final String nombreDelPdf = informe['nombre_archivo'] ?? 'Informe_Psicologico.pdf';
        final bool esSupa = informe['es_supabase'] ?? false;

        // Control de seguridad y casteo de tipos para la fecha de muestra
        String fechaMuestra = 'Hoy';
        if (informe['fecha_subida'] is Timestamp) {
          fechaMuestra = DateFormat('dd/MM/yyyy').format((informe['fecha_subida'] as Timestamp).toDate());
        } else if (informe['fecha_subida'] != null) {
          fechaMuestra = informe['fecha_subida'].toString();
        }

        return ContainerInformeRow(
          nombreArchivo: nombreDelPdf,
          fechaSubida: fechaMuestra,
          onVisualizar: () => archivoService.abrirVisorPdf(context, urlArchivo, nombreDelPdf, esSupa),
          onDescargar: () => archivoService.descargarPdfAlTelefono(context, urlArchivo, nombreDelPdf, esSupa),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import '../services/comprobante_pdf_service.dart';

class ComprobantePreviewScreen extends StatelessWidget {
  const ComprobantePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final File archivoTemporal = args['archivoTemporal'] as File;
    final String rutTrabajador = args['rut'] ?? 'comprobante';

    final pdfService = ComprobantePdfService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa Comprobante', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PDFView(
        filePath: archivoTemporal.path,
        enableSwipe: true,
        autoSpacing: true,
        pageFling: true,
      ),
      // Botón flotante para confirmar la descarga una vez revisada la estructura
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B5E20),
        onPressed: () async {
          await pdfService.descargarArchivoAAlmacenamiento(context, archivoTemporal, rutTrabajador);
          if (context.mounted) Navigator.pop(context); // Volvemos al detalle
        },
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text('Descargar PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class VisorPdfScreen extends StatelessWidget {
  const VisorPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibimos los argumentos de la ruta de forma segura
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String rutaLocal = args['rutaLocal'] ?? '';
    final String nombreArchivo = args['nombreArchivo'] ?? 'Documento PDF';

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreArchivo, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: rutaLocal.isEmpty || !File(rutaLocal).existsSync()
          ? const Center(child: Text('Error: No se pudo cargar el archivo local.'))
          : PDFView(
              filePath: rutaLocal,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {
                debugPrint("Error al renderizar PDF: $error");
              },
            ),
    );
  }
}
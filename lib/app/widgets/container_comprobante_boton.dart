import 'package:flutter/material.dart';
import 'dart:io';
import '../services/comprobante_pdf_service.dart';

class ContainerComprobanteBoton extends StatelessWidget {
  final Map<String, dynamic> derivacion;

  const ContainerComprobanteBoton({
    super.key,
    required this.derivacion,
  });

  @override
  Widget build(BuildContext context) {
    final pdfService = ComprobantePdfService();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          // Generamos el archivo de forma asíncrona en la caché temporal
          File? archivoTemporal = await pdfService.generarTemporalComprobante(context, derivacion);
          
          // Si se generó bien, saltamos a la pantalla de previsualización
          if (archivoTemporal != null && context.mounted) {
            Navigator.pushNamed(
              context, 
              'comprobante_preview',
              arguments: {
                'archivoTemporal': archivoTemporal,
                'rut': derivacion['rut'] ?? 'comprobante'
              }
            );
          }
        },
        icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFE65100), size: 20),
        label: const Text(
          'Generar Comprobante PDF', 
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE65100))
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE65100), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
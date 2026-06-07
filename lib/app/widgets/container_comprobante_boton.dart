import 'package:flutter/material.dart';
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
        onPressed: () => pdfService.generarYDescargarComprobante(context, derivacion),
        icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFE65100), size: 20),
        label: const Text(
          'Generar Comprobante PDF', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))
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
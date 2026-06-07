import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:intl/intl.dart';

class ComprobantePdfService {
  
  Future<void> generarYDescargarComprobante(BuildContext context, Map<String, dynamic> datosDerivacion) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
    );

    try {
      final String nombreTrabajador = datosDerivacion['nombre'] ?? 'Colaborador Sin Nombre';
      final String rutTrabajador = datosDerivacion['rut'] ?? 'Sin RUT';
      final String cargoTrabajador = datosDerivacion['cargo'] ?? 'No especificado';
      final String areaTrabajador = datosDerivacion['area'] ?? 'No especificada';
      final String motivoDerivacion = datosDerivacion['motivo'] ?? 'No especificado';
      final String profesionalResponsable = datosDerivacion['psicologoEmail'] ?? 'psicologo@empresa.cl';
      
      final DateTime ahora = DateTime.now();
      final String fechaComprobante = DateFormat('dd/MM/yyyy').format(ahora);
      final String horaComprobante = DateFormat('HH:mm').format(ahora);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'SISTEMA CORPORATIVO DE SALUD LABORAL',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                    ),
                    pw.Text(
                      'ID-DERIV: ${datosDerivacion['id_documento'] ?? 'N/A'}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2, color: PdfColors.green900),
                pw.SizedBox(height: 24),

                // Título Principal
                pw.Center(
                  child: pw.Text(
                    'COMPROBANTE OFICIAL DE DERIVACIÓN CLÍNICA',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                  ),
                ),
                pw.SizedBox(height: 30),

                // Datos del trabajador
                pw.Text('1. INFORMACIÓN DEL TRABAJADOR', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfRow('Nombre Completo:', nombreTrabajador),
                      _buildPdfRow('RUT:', rutTrabajador),
                      _buildPdfRow('Cargo Laboral:', cargoTrabajador),
                      _buildPdfRow('Área / Departamento:', areaTrabajador),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // Detalles de la Atención Psicológica
                pw.Text('2. DETALLES DE LA SOLICITUD', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfRow('Motivo Clínico:', motivoDerivacion),
                      _buildPdfRow('Estado de Atención:', datosDerivacion['estado'] ?? 'En Proceso'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // Metadatos de Auditoría y Responsabilidad
                pw.Text('3. CONTROL DE AUDITORÍA', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfRow('Fecha Emisión:', fechaComprobante),
                      _buildPdfRow('Hora Emisión:', '$horaComprobante hrs'),
                      _buildPdfRow('Profesional a Cargo:', profesionalResponsable),
                    ],
                  ),
                ),
                pw.Spacer(),

                // Pie de página legal con firma electrónica simulada
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Container(width: 180, child: pw.Divider(thickness: 1, color: PdfColors.grey400)),
                      pw.SizedBox(height: 4),
                      pw.Text('Firma Electrónica Autorizada', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Este documento sirve como comprobante físico y digital de la derivación realizada en los sistemas internos de RRHH. Exclusivo para uso institucional.',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Compilamos los bytes y ruteamos el archivo a la carpeta /Download de Android
      final String rutLimpio = rutTrabajador.replaceAll('.', '').replaceAll('-', '').trim();
      final String nombreFinalComprobante = 'comprobante_derivacion_$rutLimpio.pdf';
      
      final Directory directorioDescargas = Directory('/storage/emulated/0/Download');
      final File archivoFisico = File('${directorioDescargas.path}/$nombreFinalComprobante');
      
      // Escribimos permanentemente el PDF en el almacenamiento externo
      await archivoFisico.writeAsBytes(await pdf.save());

      // Registrar evento de generación de documento (Logs de auditoría)
      debugPrint('🚨 [AUDITORÍA]: Evento de generación de comprobante registrado con éxito.');
      debugPrint('📄 Archivo: $nombreFinalComprobante creado el $fechaComprobante a las $horaComprobante por $profesionalResponsable.');

      if (context.mounted) Navigator.pop(context);

      // Informamos el éxito total al usuario
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Comprobante PDF guardado con éxito en la carpeta Descargas!'),
            backgroundColor: const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Quitamos el loader si explota
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar el comprobante PDF: $e'), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }

  // Helper estático para alinear las filas dentro del PDF de manera elegante
  pw.Widget _buildPdfRow(String etiqueta, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(etiqueta, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700, fontSize: 11)),
          ),
          pw.Expanded(
            child: pw.Text(valor, style: const pw.TextStyle(color: PdfColors.grey900, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
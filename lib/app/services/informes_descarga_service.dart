import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ArchivoService {
  Future<void> abrirVisorPdf(BuildContext context, String rutaOUrl, String nombreArchivo, bool esSupabase) async {
    bool loadingAbierto = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
    ).then((_) => loadingAbierto = false);

    try {
      String urlFinal = rutaOUrl;
      if (esSupabase) {
        urlFinal = await Supabase.instance.client.storage.from('informes_psicologicos').createSignedUrl(rutaOUrl, 60);
      }

      final response = await http.get(Uri.parse(urlFinal));
      if (response.statusCode != 200) throw 'Error al descargar el archivo del servidor.';

      final dir = await getTemporaryDirectory();
      final archivoLocal = File('${dir.path}/$nombreArchivo');
      await archivoLocal.writeAsBytes(response.bodyBytes);

      if (loadingAbierto && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        loadingAbierto = false;
      }

      if (context.mounted) {
        Navigator.pushNamed(context, 'visor_pdf', arguments: {'rutaLocal': archivoLocal.path, 'nombreArchivo': nombreArchivo});
      }
    } catch (e) {
      if (loadingAbierto && context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al abrir: $e'), backgroundColor: Colors.red.shade800));
      }
    }
  }

  Future<void> descargarPdfAlTelefono(BuildContext context, String rutaOUrl, String nombreArchivo, bool esSupabase) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
    );

    try {
      String urlFinal = rutaOUrl;
      if (esSupabase) {
        urlFinal = await Supabase.instance.client.storage.from('informes_psicologicos').createSignedUrl(rutaOUrl, 60);
      }

      final response = await http.get(Uri.parse(urlFinal));
      if (response.statusCode != 200) throw 'No se pudo obtener el archivo.';

      Directory? directorioDescargas;
      if (Platform.isAndroid) {
        directorioDescargas = Directory('/storage/emulated/0/Download');
        if (!await directorioDescargas.exists()) {
          final listaDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
          if (listaDirs != null && listaDirs.isNotEmpty) {
            directorioDescargas = listaDirs.first;
          }
        }
      } else {
        directorioDescargas = await getApplicationDocumentsDirectory();
      }

      final String rutaDestinoFinal = '${directorioDescargas.path}/$nombreArchivo';
      final File archivoFisico = File(rutaDestinoFinal);
      await archivoFisico.writeAsBytes(response.bodyBytes);

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Descargado con éxito en: Carpeta Descargas/$nombreArchivo'),
            backgroundColor: const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el archivo: $e'), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }
}
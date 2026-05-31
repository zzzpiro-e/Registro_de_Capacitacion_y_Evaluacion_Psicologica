import 'package:flutter/foundation.dart'; // Necesario para Uint8List
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener 'intl' en tu pubspec.yaml para formatear la fecha
import '../services/derivaciones_services.dart';

class PsicologoDetalleDerivacionScreen extends StatefulWidget {
  final Map<String, dynamic> derivacion;

  const PsicologoDetalleDerivacionScreen({super.key, required this.derivacion});

  @override
  State<PsicologoDetalleDerivacionScreen> createState() => _PsicologoDetalleDerivacionScreenState();
}

class _PsicologoDetalleDerivacionScreenState extends State<PsicologoDetalleDerivacionScreen> {
  bool _estaSubiendo = false;
  late String _estadoActual;

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.derivacion['estado'] ?? 'Pendiente';
  }

  // Función que maneja la selección e inyección del archivo PDF al servicio (Web Friendly)
  Future<void> _seleccionarYSubirInforme() async {
    if (_estaSubiendo) return;

    setState(() {
      _estaSubiendo = true;
    });

    try {
      // Configuramos el selector para capturar exclusivamente archivos PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // CRUCIAL: Fuerza la carga de los bytes en memoria para que funcione en Web
      );

      // En entorno Web evaluamos los bytes ya que la propiedad 'path' es inaccesible
      if (result != null && result.files.single.bytes != null) {
        final String nombre = result.files.single.name;
        final String idDocumento = widget.derivacion['id_documento'] ?? '';
        
        // Evitamos la excepción de la Web: si 'path' es nulo, usamos el nombre como fallback seguro
        final String ruta = result.files.single.path ?? nombre; 
        
        // Aquí tienes los bytes del archivo listos por si en el futuro deseas subirlos a Firebase Storage
        final Uint8List datosBytes = result.files.single.bytes!;

        // Inyectamos el registro interactuando con el backend de Firestore
        await DerivacionService.agregarInformePDF(
          idDocumento: idDocumento,
          nombreArchivo: nombre,
          fechaSubida: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
          rutaLocal: ruta, 
        );

        // Cambiamos el estado de la derivación a "Completado" automáticamente tras subir el PDF
        if (idDocumento.isNotEmpty) {
          await DerivacionService.actualizarEstado(idDocumento, 'Completado');
        }

        // Actualizamos el estado de la UI localmente
        setState(() {
          _estadoActual = 'Completado';
          widget.derivacion['estado'] = 'Completado';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Informe "$nombre" subido y asociado correctamente.'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selección de archivo cancelada.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el archivo: $e'), 
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _estaSubiendo = false;
        });
      }
    }
  }

  // Estilos de color dinámicos según el estado de la derivación
  Color _colorTextoEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return const Color(0xFFB8860B);
      case 'En Proceso':
        return const Color(0xFF0056B3);
      case 'Completado':
        return const Color(0xFF2E7D32);
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Derivación'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Empleado: ${widget.derivacion['nombre'] ?? 'Desconocido'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('RUT: ${widget.derivacion['rut'] ?? 'Sin RUT'}'),
                    const SizedBox(height: 8),
                    Text('Cargo: ${widget.derivacion['cargo'] ?? 'Sin Cargo'}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Estado actual: '),
                        Text(
                          _estadoActual,
                          style: TextStyle(color: _colorTextoEstado(_estadoActual), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: _estaSubiendo
                  ? const CircularProgressIndicator(color: Color(0xFF2E7D32))
                  : ElevatedButton.icon(
                      onPressed: _estadoActual == 'Completado' ? null : _seleccionarYSubirInforme,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Subir Informe Psicológico (PDF)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
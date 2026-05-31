import 'package:flutter/material.dart';

class ContainerHistorialCard extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ContainerHistorialCard({
    super.key,
    required this.datos,
  });

  // Método modular para abrir la bandeja inferior de informes adjuntos
  void _mostrarListaInformes(BuildContext context) {
    // Recuperamos la lista de informes y creamos una copia para ordenarla de forma segura
    final List informesRaw = datos['informes'] ?? [];
    
    // Duplicamos la lista para no alterar el orden directo del servicio por accidente
    final List<Map<String, dynamic>> informesOrdenados = List<Map<String, dynamic>>.from(informesRaw);

    // Ordenamos dinámicamente: El más reciente arriba basándonos en el DateTime raw
    informesOrdenados.sort((a, b) {
      final DateTime fechaA = a['fecha_subida_raw'] ?? DateTime.now();
      final DateTime fechaB = b['fecha_subida_raw'] ?? DateTime.now();
      return fechaB.compareTo(fechaA); // b comparado con a genera el orden descendente
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
                  'Historial de archivos PDF subidos',
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
                                      informe['nombre_archivo'] ?? 'Archivo_Sin_Nombre.pdf',
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
                                      'Subido el: ${informe['fecha_subida']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Botón de acción rápida para emular la lectura del PDF
                              IconButton(
                                icon: const Icon(Icons.open_in_new, color: Color(0xFF2E7D32)),
                                onPressed: () {
                                  // Aquí se inyectará el visor de PDF nativo en el futuro utilizando la 'ruta_archivo'
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Abriendo: ${informe['nombre_archivo']}'),
                                      backgroundColor: const Color(0xFF1B5E20),
                                    ),
                                  );
                                },
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
              // Botón "Ver" (¡AHORA CONECTADO AL PANEL DE PDFs!)
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
              
              // Botón "Descargar" (Delineado)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implementar lógica de descarga de PDF global si fuera necesario
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
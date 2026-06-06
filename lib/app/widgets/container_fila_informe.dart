import 'package:flutter/material.dart';

class ContainerInformeRow extends StatelessWidget {
  final String nombreArchivo;
  final String fechaSubida;
  final VoidCallback onVisualizar;
  final VoidCallback onDescargar;

  const ContainerInformeRow({
    super.key,
    required this.nombreArchivo,
    required this.fechaSubida,
    required this.onVisualizar,
    required this.onDescargar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE), 
              borderRadius: BorderRadius.circular(10)
            ),
            child: const Icon(Icons.picture_as_pdf, color: Color(0xFFC62828), size: 26),
          ),
          const SizedBox(width: 14),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreArchivo, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)
                ),
                const SizedBox(height: 4),
                Text(
                  'Cargado el: $fechaSubida', 
                  style: const TextStyle(fontSize: 12, color: Colors.black54)
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.visibility, color: Color(0xFF2E7D32)),
            onPressed: onVisualizar,
          ),

          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF1B5E20)),
            onPressed: onDescargar,
          ),
        ],
      ),
    );
  }
}
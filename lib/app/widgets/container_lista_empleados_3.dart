import 'package:flutter/material.dart';

// Constantes fuera de la clase
const _verdeFirebase = Color(0xFF2E7D32);
const _verdeClaro = Color(0xFFE8F5E9);

class ContainerListaEmpleadosTres extends StatelessWidget {
  final List<Map<String, dynamic>> empleados;

  const ContainerListaEmpleadosTres({super.key, required this.empleados});

  String _formatearRut(String rut) {
    if (rut.isEmpty) return 'Sin RUT';
    
    final valor = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
    if (valor.length < 2) return valor;
    
    final cuerpo = valor.substring(0, valor.length - 1);
    final dv = valor.substring(valor.length - 1).toUpperCase();
    
    // Formateo más eficiente
    final buffer = StringBuffer();
    int contador = 0;
    
    for (int i = cuerpo.length - 1; i >= 0; i--) {
      buffer.write(cuerpo[i]);
      contador++;
      if (contador == 3 && i > 0) {
        buffer.write('.');
        contador = 0;
      }
    }
    
    return '${buffer.toString().split('').reversed.join()}-$dv';
  }

  String _getNombreCompleto(Map<String, dynamic> empleado) {
    final nombres = empleado['nombres'] ?? '';
    final apellidos = empleado['apellidos'] ?? '';
    final nombreCompleto = '$nombres $apellidos'.trim();
    return nombreCompleto.isEmpty ? 'Sin nombre' : nombreCompleto;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: empleados.length,
      itemBuilder: (context, index) {
        final empleado = empleados[index];
        final nombreCompleto = _getNombreCompleto(empleado);
        final rutMostrado = _formatearRut(empleado['rut'] ?? '');
        final empleadoId = empleado['id'] as String?;

        return _EmpleadoTile(
          nombreCompleto: nombreCompleto,
          rutMostrado: rutMostrado,
          empleadoId: empleadoId,
        );
      },
    );
  }
}

// Widget separado para mejor rendimiento (evita reconstrucciones innecesarias)
class _EmpleadoTile extends StatelessWidget {
  final String nombreCompleto;
  final String rutMostrado;
  final String? empleadoId;

  const _EmpleadoTile({
    required this.nombreCompleto,
    required this.rutMostrado,
    this.empleadoId,
  });

  void _onTap(BuildContext context) {
    if (empleadoId != null) {
      Navigator.pushNamed(
        context,
        'perfil_empleado',
        arguments: empleadoId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const _AvatarIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreCompleto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rutMostrado,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de avatar separado y con const
class _AvatarIcon extends StatelessWidget {
  const _AvatarIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: _verdeClaro,
        shape: BoxShape.circle, // 👈 Más eficiente que borderRadius
      ),
      child: const Icon(
        Icons.person_outline,
        color: _verdeFirebase,
        size: 28,
      ),
    );
  }
}
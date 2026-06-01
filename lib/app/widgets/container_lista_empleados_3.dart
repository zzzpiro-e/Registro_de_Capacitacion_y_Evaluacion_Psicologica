import 'package:flutter/material.dart';

class ContainerListaEmpleadosTres extends StatelessWidget {
  final List<Map<String, dynamic>> empleados;

  const ContainerListaEmpleadosTres({super.key, required this.empleados});

  // Función interna para formatear el RUT
  String _formatearRut(String rut) {
    String valor = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
    if (valor.length < 2) return valor;
    String cuerpo = valor.substring(0, valor.length - 1);
    String dv = valor.substring(valor.length - 1).toUpperCase();
    String cuerpoFormateado = "";
    int contador = 0;
    for (int i = cuerpo.length - 1; i >= 0; i--) {
      cuerpoFormateado = cuerpo[i] + cuerpoFormateado;
      contador++;
      if (contador == 3 && i > 0) {
        cuerpoFormateado = ".$cuerpoFormateado";
        contador = 0;
      }
    }
    return "$cuerpoFormateado-$dv";
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: empleados.length,
      itemBuilder: (context, index) {
        final empleado = empleados[index];

        final nombres = empleado['nombres'] ?? '';
        final apellidos = empleado['apellidos'] ?? '';
        final rutOriginal = empleado['rut'] ?? '';
        final rutMostrado = rutOriginal.isNotEmpty
            ? _formatearRut(rutOriginal)
            : 'Sin RUT';

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              'perfil_empleado',
              arguments: empleado['id'],
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$nombres $apellidos".trim().isEmpty
                            ? "Sin nombre"
                            : "$nombres $apellidos",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rutMostrado,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

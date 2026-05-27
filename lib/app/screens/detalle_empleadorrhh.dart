import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleEmpleadoRRHH extends StatelessWidget {
  final String rut;

  const DetalleEmpleadoRRHH({
    super.key,
    required this.rut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        title: const Text("Detalle Empleado"),
        backgroundColor: const Color(0xFF4CAF50),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('empleados')
            .doc(rut)
            .get(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.data() == null) {
            return const Center(
              child: Text("Empleado no encontrado"),
            );
          }

          final empleado =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          return Column(
            children: [

              // ======================
              // INFO EMPLEADO
              // ======================
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    )
                  ],
                ),

                child: Column(
                  children: [

                    const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF4CAF50),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${empleado['nombres'] ?? ''} ${empleado['apellidos'] ?? ''}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text("RUT: ${empleado['rut'] ?? rut}"),
                    Text("Estado: ${empleado['estado'] ?? 'Sin estado'}"),
                    Text("Salario: ${empleado['salario'] ?? 'Sin salario'}"),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Capacitaciones",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ======================
              // CAPACITACIONES
              // ======================
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('capacitaciones')
                      .where('rut', isEqualTo: rut)
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No tiene capacitaciones"),
                      );
                    }

                    final caps = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: caps.length,

                      itemBuilder: (context, index) {

                        final cap = caps[index].data()
                            as Map<String, dynamic>;

                        final estado =
                            cap['estado'] ?? 'pendiente';

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(18),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.05),
                                blurRadius: 6,
                              )
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Row(
                                children: [

                                  Icon(
                                    Icons.school,
                                    color: estado ==
                                            'completada'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      cap['titulo'] ??
                                          'Sin título',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text("Estado: $estado"),
                              Text(
                                  "Fecha: ${cap['fecha'] ?? 'Sin fecha'}"),
                              Text(
                                  "Descripción: ${cap['descripcion'] ?? 'Sin descripción'}"),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
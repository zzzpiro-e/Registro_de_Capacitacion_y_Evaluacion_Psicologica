import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CapacitacionesRRHH extends StatefulWidget {
  final String? estadoInicial;

  const CapacitacionesRRHH({
    super.key,
    this.estadoInicial,
  });

  @override
  State<CapacitacionesRRHH> createState() =>
      _CapacitacionesRRHHState();
}

class _CapacitacionesRRHHState
    extends State<CapacitacionesRRHH> {
  String filtro = "Todas";

  @override
  void initState() {
    super.initState();
    filtro = widget.estadoInicial ?? "Todas";
  }

  @override
  Widget build(BuildContext context) {
    Query query =
        FirebaseFirestore.instance.collection('capacitaciones');

    if (filtro != "Todas") {
      query = query.where('estado', isEqualTo: filtro);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        title: const Text("Capacitaciones"),
        backgroundColor: const Color(0xFF4CAF50),
      ),

      body: Column(
        children: [

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip("Todas"),
                _filterChip("Pendiente"),
                _filterChip("Proceso"),
                _filterChip("Completada"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                      child: Text("Sin capacitaciones"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final cap = docs[index].data()
                        as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            cap['titulo'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Estado: ${cap['estado']}"),
                          Text("Rut: ${cap['rut']}"),
                          Text("Fecha: ${cap['fecha']}"),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value) {
    final isSelected = filtro == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(value),
        selected: isSelected,
        selectedColor: const Color(0xFF4CAF50),
        onSelected: (_) {
          setState(() {
            filtro = value;
          });
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// 📌 PANTALLA MONOLÍTICA - Ingeniería Civil Informática
///
/// Esta pantalla contiene TODO el código sin separación de componentes.
/// Sirve como REFERENCIA de cómo NO organizar el código.
///
/// ❌ PROBLEMAS:
/// - Código duplicado (bloques de texto repetidos).
/// - Difícil de mantener y reutilizar.
/// - Violación del principio DRY.
/// - Componentes fuertemente acoplados.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ingeniería Civil Informática'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ❌ ENCABEZADO (NO REUTILIZABLE)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sedes: Valparaíso, Santiago',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.mail_outline,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            /// ❌ BOTONES (NO REUTILIZABLE)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description,
                            size: 20,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Malla',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.facebook,
                            size: 20,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Facebook',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat,
                            size: 20,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Discord',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ❌ BLOQUE DE TEXTO #1 (DUPLICADO LUEGO)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenidos a la carrera de Ingeniería Civil Informática',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Te presentamos el programa académico más innovador de Chile, '
                    'con énfasis en tecnología, investigación y desarrollo de software.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            /// ❌ BLOQUE DE TEXTO #2 (DUPLICADO - ESTRUCTURA IDÉNTICA)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'La Agenda Digital 2020 en Educación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nuestro programa se alinea con los objetivos de transformación digital, '
                    'preparando profesionales capacitados para enfrentar los desafíos del siglo XXI.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            /// ❌ BLOQUE DE TEXTO #3 (DUPLICADO - MÁS REPETICIÓN)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metodología de Enseñanza Innovadora',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Combinamos teoría con práctica a través de laboratorios, proyectos reales '
                    'y colaboración con la industria tecnológica mundial.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            /// ❌ IMAGEN SIN COMPONENTE REUTILIZABLE
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

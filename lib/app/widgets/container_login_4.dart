import 'package:flutter/material.dart';

class ContainerCuatroLogin extends StatelessWidget {
  const ContainerCuatroLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Text(
                'Sistema de Gestión de Recursos Humanos',
                style: TextStyle(
                  color: Color(0xFF558B2F),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Versión 1.0.0 - 2026',
                style: TextStyle(
                  color: Color(0xFF558B2F),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_crear_capacitacion.dart';

class CrearCapacitacionScreen extends StatelessWidget {
  const CrearCapacitacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ContainerCrearCapacitacionUno(),
              SizedBox(height: 16),
              ContainerCrearCapacitacionDos(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ContainerUno extends StatefulWidget {
  final int tipoLogin; // 1, 2 o 3

  const ContainerUno({super.key, required this.tipoLogin});

  @override
  State<ContainerUno> createState() => _ContainerUnoState();
}

class _ContainerUnoState extends State<ContainerUno> {
  late String titulo;
  late String subtitulo;
  late IconData icono;
  late Color colorFondo;

  @override
  void initState() {
    super.initState();

    // Configuración dinámica según el tipo de login
    switch (widget.tipoLogin) {
      case 1:
        titulo = "Sistema RRHH";
        subtitulo = "Gestión de Recursos Humanos";
        icono = Icons.groups_2_outlined;
        colorFondo = const Color(0xFF43A047); // Verde
        break;
      case 2:
        titulo = "Sistema RRHH";
        subtitulo = "Gestión de Administrador";
        icono = Icons.admin_panel_settings;
        colorFondo = Colors.blue; // Azul
        break;
      case 3:
        titulo = "Sistema Médico";
        subtitulo = "Gestión de Psicólogo";
        icono = Icons.psychology;
        colorFondo = Colors.red; // Rojo
        break;
      default:
        titulo = "Sistema";
        subtitulo = "Login";
        icono = Icons.lock_outline;
        colorFondo = Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth, // 🔹 ocupa todo el ancho físico del dispositivo
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      color: colorFondo,
      child: Column(
        children: [
          // Ícono principal
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icono,
              color: Colors.white,
              size: 70,
            ),
          ),
          const SizedBox(height: 36),
          // Título
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Subtítulo
          Text(
            subtitulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}


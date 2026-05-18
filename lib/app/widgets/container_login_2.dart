import 'package:flutter/material.dart';

class ContainerDosLogin extends StatefulWidget {
  final int tipoLogin; // 1, 2 o 3

  const ContainerDosLogin({super.key, required this.tipoLogin});

  @override
  State<ContainerDosLogin> createState() => _ContainerDosLoginState();
}

class _ContainerDosLoginState extends State<ContainerDosLogin> {
  late String titulo;
  late String subtitulo;
  late Color colorTexto;

  @override
  void initState() {
    super.initState();

    // Configuración dinámica según el tipo de login
    switch (widget.tipoLogin) {
      case 1:
        titulo = "Bienvenido";
        subtitulo = "Ingresa tus credenciales para continuar";
        colorTexto = const Color(0xFF558B2F); // Verde
        break;
      case 2:
        titulo = "Acceso Administrativo";
        subtitulo = "Introduce tu usuario y clave";
        colorTexto = Colors.blue; // Azul
        break;
      case 3:
        titulo = "Acceso Psicólogo";
        subtitulo = "Verifica tus datos para ingresar";
        colorTexto = Colors.red; // Rojo
        break;
      default:
        titulo = "Login";
        subtitulo = "Accede al sistema";
        colorTexto = Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorTexto,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

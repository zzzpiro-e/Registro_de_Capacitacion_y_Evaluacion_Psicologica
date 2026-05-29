import 'package:flutter/material.dart';
import 'package:proyecto_flutter/widgets/widgets.dart';

/// ✅ PANTALLA REFACTORIZADA - Ingeniería Civil Informática
///
/// Esta es la versión LIMPIA y MODULAR de HomeScreen.
/// Implementa principios de arquitectura limpia:
/// - Separación de responsabilidades
/// - Reutilización de componentes (DRY)
/// - Componentes pequeños y testables
/// - Código mantenible y escalable

class Home2Screen extends StatelessWidget {
  const Home2Screen({super.key});

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
            /// ✅ COMPONENTE REUTILIZABLE: HeaderTitleWidget
            const HeaderTitleWidget(
              title: 'Bienvenido',
              subtitle: 'Sedes: Valparaíso, Santiago',
              showMailIcon: true,
            ),

            /// ✅ COMPONENTE REUTILIZABLE: ActionButtonsRow
            ActionButtonsRow(
              buttons: [
                {'icon': Icons.description, 'label': 'Malla'},
                {'icon': Icons.facebook, 'label': 'Facebook'},
                {'icon': Icons.chat, 'label': 'Discord'},
              ],
              onButtonPressed: (index) {
                // Callback para manejar el presionar de botones
                debugPrint('Botón presionado: $index');
              },
            ),

            /// ✅ COMPONENTE REUTILIZABLE: CustomTextBlock (SIN ÉNFASIS)
            const CustomTextBlock(
              title: 'Bienvenidos a la carrera de Ingeniería Civil Informática',
              description:
                  'Te presentamos el programa académico más innovador de Chile, '
                  'con énfasis en tecnología, investigación y desarrollo de software.',
              isHighlighted: false,
            ),

            /// ✅ COMPONENTE REUTILIZABLE: CustomTextBlock (CON ÉNFASIS)
            const CustomTextBlock(
              title: 'La Agenda Digital 2020 en Educación',
              description:
                  'Nuestro programa se alinea con los objetivos de transformación digital, '
                  'preparando profesionales capacitados para enfrentar los desafíos del siglo XXI.',
              isHighlighted: true,
              textColor: Colors.blue,
            ),

            /// ✅ COMPONENTE REUTILIZABLE: CustomTextBlock (SIN ÉNFASIS)
            const CustomTextBlock(
              title: 'Metodología de Enseñanza Innovadora',
              description:
                  'Combinamos teoría con práctica a través de laboratorios, proyectos reales '
                  'y colaboración con la industria tecnológica mundial.',
              isHighlighted: false,
            ),

            /// ✅ COMPONENTE REUTILIZABLE: FooterImageWidget
            const FooterImageWidget(
              imagePath: 'assets/lab_image.png',
              height: 200,
              borderRadius: 12,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

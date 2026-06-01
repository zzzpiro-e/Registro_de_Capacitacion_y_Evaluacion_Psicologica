import 'package:flutter/material.dart';

class CreateWorkerScreen extends StatefulWidget {
  const CreateWorkerScreen({super.key});

  @override
  State<CreateWorkerScreen> createState() => _CreateWorkerScreenState();
}

class _CreateWorkerScreenState extends State<CreateWorkerScreen> {
  final _nameController = TextEditingController();
  final _rutController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'RRHH'; // Valor por defecto del Dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF43A047)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear Trabajador',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Informativo Superior
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Text(
                'Complete todos los campos para crear un nuevo usuario en el sistema',
                style: TextStyle(color: Color(0xFF43A047), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),

            // Campo Nombre
            _buildFieldTitle('Nombre Completo'),
            _buildTextField(hint: 'Ej: Juan Pérez González', controller: _nameController),
            const SizedBox(height: 18),

            // Campo RUT
            _buildFieldTitle('RUT'),
            _buildTextField(hint: '12.345.678-9', controller: _rutController),
            const SizedBox(height: 18),

            // Campo Correo
            _buildFieldTitle('Correo Electrónico'),
            _buildTextField(hint: 'usuario@empresa.cl', controller: _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 18),

            // Campo Teléfono
            _buildFieldTitle('Teléfono'),
            _buildTextField(hint: '+56 9 1234 5678', controller: _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 18),

            // Campo Rol (Dropdown)
            _buildFieldTitle('Rol'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCCCCCC)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: <String>['RRHH', 'Psicólogo', 'Administrador'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Campo Clave Provisoria
            _buildFieldTitle('Clave Provisoria'),
            _buildTextField(hint: 'Mínimo 8 caracteres', controller: _passwordController, obscureText: true),
            const SizedBox(height: 6),
            const Text(
              'El usuario deberá cambiar esta contraseña en su primer inicio de sesión',
              style: TextStyle(color: Color(0xFF43A047), fontSize: 12),
            ),
            const SizedBox(height: 32),

            // Botón Crear Trabajador
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () {
                  // Aquí conectaremos luego la lógica para guardar en Firebase
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Guardando trabajador...')),
                  );
                },
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text(
                  'Crear Trabajador',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildFieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        // 🟢 Cambiado Colors.black80 por Colors.black87
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
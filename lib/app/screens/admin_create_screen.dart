import 'package:flutter/material.dart';

class AdminCreateScreen extends StatefulWidget {
  const AdminCreateScreen({super.key});

  @override
  State<AdminCreateScreen> createState() => _AdminCreateScreenState();
}

class _AdminCreateScreenState extends State<AdminCreateScreen> {
  // Controladores para capturar el texto de cada campo
  final _nombreController = TextEditingController();
  final _rutController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _claveController = TextEditingController();
  
  // Rol seleccionado por defecto en el Dropdown
  String _selectedRole = 'RRHH'; 

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32), size: 20),
          onPressed: () {
            // Acción opcional para volver
          },
        ),
        title: const Text(
          'Crear Trabajador',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 Tarjeta informativa superior
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: const Text(
                'Complete todos los campos para crear un nuevo usuario en el sistema',
                style: TextStyle(color: Color(0xFF43A047), fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // Campos del Formulario
            _buildInputField(label: 'Nombre Completo', hint: 'Ej: Juan Pérez González', controller: _nombreController),
            const SizedBox(height: 20),
            
            _buildInputField(label: 'RUT', hint: '12.345.678-9', controller: _rutController),
            const SizedBox(height: 20),
            
            _buildInputField(label: 'Correo Electrónico', hint: 'usuario@empresa.cl', controller: _correoController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            
            _buildInputField(label: 'Teléfono', hint: '+56 9 1234 5678', controller: _telefonoController, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),

            // 🔽 Dropdown de Selección de Rol
            const Text('Rol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  items: <String>['RRHH', 'Psicólogo', 'Administrador'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 16)),
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
            const SizedBox(height: 20),

            _buildInputField(label: 'Clave Provisoria', hint: 'Mínimo 8 caracteres', controller: _claveController, isObscure: true),
            const SizedBox(height: 8),
            const Text(
              'El usuario deberá cambiar esta contraseña en su primer inicio de sesión',
              style: TextStyle(color: Color(0xFF43A047), fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),

            // 💾 Botón Crear Trabajador
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  // Aquí irá la lógica de Firebase en el futuro 🚀
                  print('Creando a: ${_nombreController.text} con el rol $_selectedRole');
                },
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text(
                  'Crear Trabajador',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir los inputs idénticos a tu diseño
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isObscure,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
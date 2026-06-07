import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

class ContainerListaEmpleadosDos extends StatefulWidget {
  final Function(String) onSearch;

  const ContainerListaEmpleadosDos({super.key, required this.onSearch});

  @override
  State<ContainerListaEmpleadosDos> createState() => _ContainerListaEmpleadosDosState();
}

class _ContainerListaEmpleadosDosState extends State<ContainerListaEmpleadosDos> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  bool _esSoloLetras(String valor) => RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(valor);
  bool _esSoloNumeros(String valor) => RegExp(r'^[0-9]+$').hasMatch(valor);
  bool _esRutValido(String valor) => RegExp(r'^[0-9]{7,9}$').hasMatch(valor);

  void _validarYBuscar(String valor) {
    valor = valor.trim();

    if (valor.isEmpty) {
      setState(() => _errorText = null);
      widget.onSearch('');
      return;
    }

    if (_esSoloLetras(valor)) {
      setState(() => _errorText = null);
      widget.onSearch(TextUtils.quitarTildes(valor));
    } else if (_esSoloNumeros(valor)) {
      if (_esRutValido(valor)) {
        setState(() => _errorText = null);
        widget.onSearch(valor);
      } else {
        setState(() => _errorText = 'Formato de RUT inválido (sin puntos ni guion)');
      }
    } else {
      setState(() => _errorText = 'No mezcles letras, números ni símbolos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o RUT...',
                    border: InputBorder.none,
                  ),
                  onChanged: _validarYBuscar,
                ),
              ),
            ],
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
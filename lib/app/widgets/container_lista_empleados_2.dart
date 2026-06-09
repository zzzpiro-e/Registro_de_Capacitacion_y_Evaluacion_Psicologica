import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

// Constantes fuera de la clase
const _verdeFirebase = Color(0xFF2E7D32);
const _mensajeRutInvalido = 'Formato de RUT inválido (sin puntos ni guion)';
const _mensajeMezcla = 'No mezcles letras, números ni símbolos';

class ContainerListaEmpleadosDos extends StatefulWidget {
  final Function(String) onSearch;

  const ContainerListaEmpleadosDos({super.key, required this.onSearch});

  @override
  State<ContainerListaEmpleadosDos> createState() => _ContainerListaEmpleadosDosState();
}

class _ContainerListaEmpleadosDosState extends State<ContainerListaEmpleadosDos> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  // Expresiones regulares como constantes
  static final RegExp _soloLetras = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  static final RegExp _soloNumeros = RegExp(r'^[0-9]+$');
  static final RegExp _rutValido = RegExp(r'^[0-9]{7,9}$');

  bool get _tieneError => _errorText != null;

  void _validarYBuscar(String valor) {
    valor = valor.trim();

    if (valor.isEmpty) {
      _limpiarErrorYBuscar('');
      return;
    }

    if (_soloLetras.hasMatch(valor)) {
      _limpiarErrorYBuscar(TextUtils.quitarTildes(valor));
    } else if (_soloNumeros.hasMatch(valor)) {
      if (_rutValido.hasMatch(valor)) {
        _limpiarErrorYBuscar(valor);
      } else {
        _mostrarError(_mensajeRutInvalido);
      }
    } else {
      _mostrarError(_mensajeMezcla);
    }
  }

  void _limpiarErrorYBuscar(String query) {
    if (_tieneError) {
      setState(() => _errorText = null);
    }
    widget.onSearch(query);
  }

  void _mostrarError(String mensaje) {
    setState(() => _errorText = mensaje);
    widget.onSearch('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 👈 Importante: solo usa el espacio necesario
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: _verdeFirebase),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o RUT...',
                    border: InputBorder.none,
                    isDense: true, // 👈 Reduce altura del TextField
                  ),
                  onChanged: _validarYBuscar,
                ),
              ),
            ],
          ),
          if (_tieneError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, bottom: 8),
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
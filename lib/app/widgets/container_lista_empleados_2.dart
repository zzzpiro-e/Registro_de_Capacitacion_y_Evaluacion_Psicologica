import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_flutter/app/utils/text_utils.dart';

// Constantes fuera de la clase
const _verdeFirebase = Color(0xFF2E7D32);

class ContainerListaEmpleadosDos extends StatefulWidget {
  final void Function(String) onSearch;

  const ContainerListaEmpleadosDos({super.key, required this.onSearch});

  @override
  State<ContainerListaEmpleadosDos> createState() =>
      _ContainerListaEmpleadosDosState();
}

class _ContainerListaEmpleadosDosState
    extends State<ContainerListaEmpleadosDos> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  // Expresiones regulares
  static final RegExp _soloLetras =
      RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  static final RegExp _soloRut =
      RegExp(r'^[0-9.kK-]+$'); // números + puntos + guion + K/k

  bool get _tieneError => _errorText != null;

  void _validarYBuscar(String valor) {
    valor = valor.trim();

    if (valor.isEmpty) {
      _limpiarErrorYBuscar('');
      return;
    }

    if (_soloLetras.hasMatch(valor)) {
      if (valor.length <= 70) {
        _limpiarErrorYBuscar(TextUtils.quitarTildes(valor));
      } else {
        _mostrarError('Máximo 70 letras');
      }
    } else if (_soloRut.hasMatch(valor)) {
      final soloNumeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
      if (soloNumeros.length <= 9) {
        _limpiarErrorYBuscar(valor);
      } else {
        _mostrarError('Máximo 9 dígitos numéricos');
      }
    } else {
      _mostrarError('No mezcles letras, números ni símbolos');
    }
  }

  void _limpiarErrorYBuscar(String query) async {
    if (_tieneError) {
      setState(() => _errorText = null);
    }
    setState(() => _isLoading = true);

    try {
      // 👇 Aquí llamas a tu lógica de búsqueda
      widget.onSearch(query);
    } catch (e) {
      // 👇 Si hay error de red u otra excepción
      _mostrarError('Error de conexión durante la búsqueda');
      return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    setState(() {
      _errorText = mensaje;
      _isLoading = false;
    });
    // 👇 En vez de mostrar todos los empleados, enviamos un valor especial
    widget.onSearch('lo ingresado en el buscador');
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: _verdeFirebase),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.kK-]|[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final soloNumeros =
                          newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                      if (soloNumeros.length > 9) {
                        _mostrarError('Máximo 9 dígitos numéricos');
                        return oldValue;
                      }
                      if (newValue.text.length > 70 &&
                          _soloLetras.hasMatch(newValue.text)) {
                        _mostrarError('Máximo 70 letras');
                        return oldValue;
                      }
                      return newValue;
                    }),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Buscar por RUT o nombres y apellidos',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: _validarYBuscar,
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _verdeFirebase,
                  ),
                ),
            ],
          ),
          if (_tieneError)
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, left: 8, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorText!,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

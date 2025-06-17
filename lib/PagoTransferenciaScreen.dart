import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resrevacion_canchas/ComprobanteTransferenciaPage.dart';
import 'dart:math';

class PagoTransferenciaScreen extends StatefulWidget {
  final Map<String, dynamic> reserva;

  const PagoTransferenciaScreen({super.key, required this.reserva});

  @override
  State<PagoTransferenciaScreen> createState() => _PagoTransferenciaScreenState();
}

class _PagoTransferenciaScreenState extends State<PagoTransferenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cuentaOrigenController = TextEditingController();
  final _cuentaDestinoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();

  late final String _fechaActual;
  late final String _horaActual;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fechaActual = DateFormat('dd/MM/yyyy').format(now);
    _horaActual = DateFormat('hh:mm a').format(now);
  }

  String _generarNumeroComprobante() {
    final random = Random();
    return (10000000 + random.nextInt(90000000)).toString();
  }

  String _formatearMonto(String text) {
    try {
      double value = double.parse(text);
      final formatter = NumberFormat.currency(symbol: 'L ', decimalDigits: 2); // Separado
      return formatter.format(value);
    } catch (e) {
      return text;
    }
  }

  String? _validarCuenta(String? value) {
    if (value == null || value.isEmpty) return 'Campo obligatorio';
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(value)) return 'Solo números permitidos';
    if (value.length < 8 || value.length > 20) return 'Debe tener entre 8 y 20 dígitos';
    return null;
  }

  bool _validarPaso(int step) {
    switch (step) {
      case 0:
        return _validarCuenta(_cuentaOrigenController.text) == null &&
            _validarCuenta(_cuentaDestinoController.text) == null;
      case 1:
        return (_descripcionController.text.isNotEmpty) &&
            (num.tryParse(_montoController.text.replaceAll(',', '')) != null &&
                num.parse(_montoController.text.replaceAll(',', '')) > 0);
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _onStepContinue() {
    if (_currentStep == 2) {
      if (_formKey.currentState!.validate()) {
        final numeroComprobante = _generarNumeroComprobante();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transferencia realizada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComprobanteTransferenciaScreen(
                reserva: widget.reserva,
                cuentaOrigen: _cuentaOrigenController.text,
                cuentaDestino: _cuentaDestinoController.text,
                descripcion: _descripcionController.text,
                fecha: _fechaActual,
                hora: _horaActual,
                monto: _formatearMonto(_montoController.text),
                numeroComprobante: numeroComprobante,
              ),
            ),
          );
        });
      }
    } else {
      if (_validarPaso(_currentStep)) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, complete correctamente los campos')),
        );
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.orange[800]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: Colors.orange[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Pago por Transferencia',
          style: TextStyle(color: Colors.white), // Title text color set to white
        ),
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(color: Colors.white), // Back button color set to white
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 2;
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isLastStep ? 'Confirmar Transferencia' : 'Siguiente',
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Text color set to white
                      ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 15),
                    ElevatedButton( // Changed from OutlinedButton to ElevatedButton
                      onPressed: details.onStepCancel,
                      style: ElevatedButton.styleFrom( // Using ElevatedButton.styleFrom
                        backgroundColor: Colors.blue[800], // Set background color to blue
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Atrás', style: TextStyle(fontSize: 16, color: Colors.white)), // Text color set to white
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Datos de las cuentas'),
              subtitle: const Text('Cuenta Origen y Destino'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _cuentaOrigenController,
                    decoration: _inputDecoration('Cuenta Origen', 'Ej: 1234567890', Icons.account_balance),
                    keyboardType: TextInputType.number,
                    maxLength: 20,
                    validator: _validarCuenta,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _cuentaDestinoController,
                    decoration: _inputDecoration('Cuenta Destino', 'Ej: 0987654321', Icons.account_balance_wallet),
                    keyboardType: TextInputType.number,
                    maxLength: 20,
                    validator: _validarCuenta,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Detalles de la transferencia'),
              subtitle: const Text('Descripción y monto'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _descripcionController,
                    decoration: _inputDecoration('Descripción', 'Concepto de la transferencia', Icons.description),
                    maxLength: 100,
                    validator: (value) => (value == null || value.isEmpty) ? 'Ingrese una descripción' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _montoController,
                    decoration: _inputDecoration('Monto (L)', 'Ej: 1500.00', Icons.attach_money),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese monto';
                      final n = num.tryParse(value.replaceAll(',', ''));
                      if (n == null || n <= 0) return 'Monto inválido';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Confirmación'),
              subtitle: const Text('Revise antes de enviar'),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cuenta Origen: ${_cuentaOrigenController.text}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Cuenta Destino: ${_cuentaDestinoController.text}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Descripción: ${_descripcionController.text}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Monto: ${_formatearMonto(_montoController.text)}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('Fecha: $_fechaActual', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('Hora: $_horaActual', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // Customizing stepper theme for blue numbers
          connectorColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) return Colors.blue[800]!;
              return Colors.grey;
            },
          ),
          stepIconBuilder: (context, state) {
            if (state == StepState.indexed) {
              return CircleAvatar(
                backgroundColor: Colors.blue[800], // Set step circle color to blue
                child: Text(
                  (_currentStep == 0) ? '1' : (_currentStep == 1 ? '2' : '3'), // Manually set numbers for clarity
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }
            return null; // Let the default builder handle other states (e.g., complete)
          },
        ),
      ),
    );
  }
}

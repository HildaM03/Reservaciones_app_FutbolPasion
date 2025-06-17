import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComprobanteTransferenciaScreen extends StatefulWidget {
  final Map<String, dynamic> reserva;
  final String cuentaOrigen;
  final String cuentaDestino;
  final String descripcion;
  final String fecha;
  final String hora;
  final String monto;
  final String numeroComprobante;

  const ComprobanteTransferenciaScreen({
    super.key,
    required this.reserva,
    required this.cuentaOrigen,
    required this.cuentaDestino,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.monto,
    required this.numeroComprobante,
  });

  @override
  State<ComprobanteTransferenciaScreen> createState() => _ComprobanteTransferenciaScreenState();
}

class _ComprobanteTransferenciaScreenState extends State<ComprobanteTransferenciaScreen> {
  bool _isSaved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSaved) {
      _guardarPagoEnFirestore();
      _isSaved = true;
    }
  }

  void _guardarPagoEnFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('pago').add({
        'cuentaOrigen': widget.cuentaOrigen,
        'cuentaDestino': widget.cuentaDestino,
        'descripcion': widget.descripcion,
        'fecha': widget.fecha,
        'hora': widget.hora,
        'monto': widget.monto,
        'numeroComprobante': widget.numeroComprobante,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // You can add a print or show a snackbar if you want to handle errors
      print('Error al guardar el pago: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    const valueStyle = TextStyle(fontSize: 18);

    return Scaffold(
      appBar: AppBar(
        // Removed the title 'Comprobante' and the implicit back button
        automaticallyImplyLeading: false, // This removes the back button
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 6,
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 64)),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Transferencia Exitosa',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
                  ),
                ),
                const SizedBox(height: 24),
                _buildRow('Comprobante:', widget.numeroComprobante, labelStyle, valueStyle),
                _buildRow('Cuenta origen:', widget.cuentaOrigen, labelStyle, valueStyle),
                _buildRow('Cuenta destino:', widget.cuentaDestino, labelStyle, valueStyle),
                _buildRow('Descripción:', widget.descripcion, labelStyle, valueStyle),
                _buildRow('Fecha:', widget.fecha, labelStyle, valueStyle),
                _buildRow('Hora:', widget.hora, labelStyle, valueStyle),
                _buildRow('Monto:', 'L ${widget.monto}', labelStyle, valueStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: labelStyle)),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }
}
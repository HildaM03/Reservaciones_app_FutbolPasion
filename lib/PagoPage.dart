import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PagoPage extends StatefulWidget {
  @override
  _PagoPageState createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  String metodoPago = 'Transferencia';
  final _formKey = GlobalKey<FormState>();

  // Campos nuevos
  String cuentaOrigen = '';
  String cuentaDestino = '';
  String numeroComprobante = '';

  // Campos ya existentes
  String nombreTitular = '';
  String monto = '';
  String detalle = '';

  void _guardarPagoEnFirebase() async {
    try {
      await FirebaseFirestore.instance.collection('pago').add({
        'metodo': metodoPago,
        'cuenta_origen': cuentaOrigen,
        'cuenta_destino': cuentaDestino,
        'comprobante': numeroComprobante,
        'titular': nombreTitular,
        'monto': monto,
        'detalle': detalle,
        'fecha': Timestamp.now(),
      });
      _mostrarTicket();
    } catch (e) {
      print('Error al guardar en Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el pago')),
      );
    }
  }

  void _mostrarTicket() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ticket de Pago'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Método: $metodoPago'),
              if (metodoPago == 'Transferencia') ...[
                Text('Cuenta Origen: $cuentaOrigen'),
                Text('Cuenta Destino: $cuentaDestino'),
                Text('Número de Comprobante: $numeroComprobante'),
                Text('Titular: $nombreTitular'),
                Text('Monto: \$${monto}'),
                Text('Detalle: $detalle'),
              ],
              Text('Fecha: ${DateTime.now()}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar ticket
              Navigator.of(context).pop(); // Volver a pantalla anterior
            },
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmarPago() {
    if (_formKey.currentState!.validate()) {
      _guardarPagoEnFirebase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago registrado exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago de Reserva'),
        backgroundColor: Colors.green.shade600,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecciona el método de pago:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: metodoPago,
              items: ['Transferencia', 'Efectivo']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => metodoPago = val!),
            ),
            SizedBox(height: 20),
            metodoPago == 'Transferencia'
                ? Form(
                    key: _formKey,
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Cuenta de Origen',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => cuentaOrigen = val,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Ingresa la cuenta de origen'
                                  : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Cuenta de Destino',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => cuentaDestino = val,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Ingresa la cuenta de destino'
                                  : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Número de Comprobante',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => numeroComprobante = val,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Ingresa el número de comprobante'
                                  : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Nombre del titular',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => nombreTitular = val,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Ingresa el nombre del titular'
                                  : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Monto a transferir',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => monto = val,
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Ingresa el monto' : null,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Detalle o descripción',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => detalle = val,
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Ingresa un detalle' : null,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _confirmarPago,
                              child: Text('Confirmar Pago'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debe cancelar en la oficina.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _guardarPagoEnFirebase();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pago registrado en modo efectivo')),
                            );
                          },
                          child: Text('Confirmar Pago en Efectivo'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
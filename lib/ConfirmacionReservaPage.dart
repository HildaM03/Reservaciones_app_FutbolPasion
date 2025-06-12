import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfirmacionReservaPage extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final DateTime fecha;
  final String horario;
  final String precio;

  const ConfirmacionReservaPage({
    super.key,
    required this.cancha,
    required this.fecha,
    required this.horario,
    required this.precio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Reserva'),
        backgroundColor: const Color(0xFFD4534E),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recuadro de información de la cancha
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Confirma la información de tu reserva',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4534E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Cancha', '"${cancha['nombre']}"'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Jugadores', cancha['jugadores']),
                  const SizedBox(height: 12),
                  _buildInfoRow('Precio hora', 'L. $precio'),
                ],
              ),
            ),

            // Recuadro de fecha y horario
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha seleccionada:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4534E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(fecha),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Horario seleccionado:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4534E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    horario,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Recuadro del total
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total a pagar:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFD4534E),
                    ),
                  ),
                  Text(
                    'L. $precio',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Botones
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD4534E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'REGRESAR',
                        style: TextStyle(
                          color: Color(0xFFD4534E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4534E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _confirmReservation(context),
                      child: const Text(
                        'CONFIRMAR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4534E),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final days = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
    final months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return '${days[date.weekday % 7]}. ${date.day} ${months[date.month - 1]}. ${date.year}';
  }

  Future<void> _confirmReservation(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para confirmar una reserva.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verificar si ya existe una reserva para la misma cancha, fecha y horario
      final query = await FirebaseFirestore.instance
          .collection('reservas')
          .where('cancha', isEqualTo: cancha['nombre'])
          .where('fecha', isEqualTo: fecha.toIso8601String())
          .where('horario', isEqualTo: horario)
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta cancha ya ha sido reservada en este horario.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Obtener nombre desde Firestore
      String nombreCompleto = user.displayName ?? 'Sin nombre';
      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (userDoc.exists) {
        nombreCompleto = userDoc.data()?['nombreCompleto'] ?? nombreCompleto;
      }

      final reserva = {
        'nombre': nombreCompleto,
        'correo': user.email,
        'cancha': cancha['nombre'],
        'jugadores': cancha['jugadores'],
        'precio': 'L. $precio',
        'fecha': fecha.toIso8601String(),
        'horario': horario,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('reservas').add(reserva);

      Navigator.popUntil(context, (route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reserva confirmada con éxito!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al confirmar reserva: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

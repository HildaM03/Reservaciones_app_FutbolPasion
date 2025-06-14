import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resrevacion_canchas/Reserva_exitosa_page.dart';

class ConfirmacionReservaPage extends StatefulWidget {
  final Map<String, dynamic> cancha;
  final Map<String, dynamic> complejo;
  final DateTime fecha;
  final String horario;
  final String precio;

  const ConfirmacionReservaPage({
    super.key,
    required this.cancha,
    required this.complejo,
    required this.fecha,
    required this.horario,
    required this.precio,
  });

  @override
  State<ConfirmacionReservaPage> createState() => _ConfirmacionReservaPageState();
}

class _ConfirmacionReservaPageState extends State<ConfirmacionReservaPage> {
  static const Color mainColor = Color(0xFF26A69A); // Verde jade
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFAFAFA);
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: Text(widget.complejo['nombre']),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionTitle('📝 Confirma la informacionn de la Reserva'),
            _buildCard([
              _infoRow(Icons.location_city, 'Complejo', widget.complejo['nombre']),
              _infoRow(Icons.sports_soccer, 'Cancha', widget.cancha['nombre']),
              _infoRow(Icons.group, 'Jugadores', widget.cancha['jugadores']),
              _infoRow(Icons.attach_money, 'Precio por hora', widget.precio),
            ]),
            const SizedBox(height: 10),
            _buildSectionTitle('📅 Fecha y Horario'),
            _buildCard([
              _infoRow(Icons.calendar_today, 'Fecha', _formatDate(widget.fecha)),
              _infoRow(Icons.access_time, 'Horario', widget.horario),
            ]),
            const SizedBox(height: 10),
            _buildSectionTitle('💵 Total a Pagar'),
            _buildCard([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor),
                  ),
                  Text(
                    widget.precio,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor),
                  ),
                ],
              )
            ]),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: mainColor,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: mainColor),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: mainColor),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: mainColor),
            label: const Text('REGRESAR', style: TextStyle(color: mainColor)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: mainColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _confirmReservation(context),
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_circle, color: Colors.white),
            label: Text(
              _isLoading ? 'CONFIRMANDO...' : 'CONFIRMAR',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
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
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para confirmar una reserva.'), backgroundColor: Colors.red),
        );
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('reservas')
          .where('cancha', isEqualTo: widget.cancha['nombre'])
          .where('fecha', isEqualTo: widget.fecha.toIso8601String())
          .where('horario', isEqualTo: widget.horario)
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta cancha ya ha sido reservada en este horario.'), backgroundColor: Colors.redAccent),
        );
        return;
      }

      String nombreCompleto = user.displayName ?? 'Sin nombre';
      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (userDoc.exists) {
        nombreCompleto = userDoc.data()?['nombreCompleto'] ?? nombreCompleto;
      }

      final reserva = {
        'complejo': widget.complejo['nombre'],
        'cancha': widget.cancha['nombre'],
        'jugadores': widget.cancha['jugadores'],
        'precio': widget.precio,
        'fecha': widget.fecha.toIso8601String(),
        'horario': widget.horario,
        'nombre': nombreCompleto,
        'correo': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'complejoTelefono': widget.complejo['telefono'],
        'complejoUbicacion': widget.complejo['ubicacion'],
      };

      await FirebaseFirestore.instance.collection('reservas').add(reserva);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReservaExitosaPage(reserva: reserva),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar reserva: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

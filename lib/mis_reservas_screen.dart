import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  late final User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión para ver tus reservas')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: Color(0xFF0D47A1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservas')
            .where('correo', isEqualTo: user!.email)
            // No usamos orderBy aquí para evitar conflicto si no indexa por 'fecha'
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes reservas registradas'));
          }

          // Convertimos y parseamos la fecha para cada reserva
          final reservas = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final fecha = data['fecha'] is Timestamp
                ? (data['fecha'] as Timestamp).toDate()
                : DateTime.tryParse(data['fecha'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);

            return {
              'data': data,
              'fecha': fecha,
            };
          }).toList();

          // Ordenamos la lista por fecha descendente
          reservas.sort((a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final data = reservas[index]['data'] as Map<String, dynamic>;
              final fecha = reservas[index]['fecha'] as DateTime;

              return _buildReservaCard(
                complejo: data['complejo'] ?? 'Sin nombre',
                cancha: data['cancha'] ?? 'Sin cancha',
                fecha: fecha,
                horario: data['horario'] ?? 'Sin horario',
                precio: data['precio'] ?? 'L. 0',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReservaCard({
    required String complejo,
    required String cancha,
    required DateTime fecha,
    required String horario,
    required String precio,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  complejo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6F00),
                  ),
                ),
                Text(
                  precio,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Cancha: $cancha'),
            const SizedBox(height: 8),
            Text('Fecha: ${_formatDate(fecha)}'),
            const SizedBox(height: 8),
            Text('Horario: $horario'),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB'];
    final months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return '${days[date.weekday % 7]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

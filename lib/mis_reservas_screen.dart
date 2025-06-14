import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
        body: Center(
          child: Text('Debes iniciar sesión para ver tus reservas'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D47A1).withOpacity(0.1),
              const Color(0xFFFF6F00).withOpacity(0.05),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reservas')
              .where('correo', isEqualTo: user!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1))),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No tienes reservas registradas', style: TextStyle(color: Colors.black)),
              );
            }

            final reservas = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final fecha = data['fecha'] is Timestamp
                  ? (data['fecha'] as Timestamp).toDate()
                  : DateTime.tryParse(data['fecha'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
              String precio = data['precio'] ?? '0';
              precio = precio.replaceAll('L.', '').replaceAll('L', '').trim();
              precio = 'L $precio';
              return {'data': {...data, 'precio': precio}, 'fecha': fecha, 'docId': doc.id};
            }).toList();

            reservas.sort((a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final data = reservas[index]['data'] as Map<String, dynamic>;
                final fecha = reservas[index]['fecha'] as DateTime;
                final docId = reservas[index]['docId'] as String;

                return _buildReservaCard(
                  complejo: data['complejo'] ?? 'Sin nombre',
                  cancha: data['cancha'] ?? 'Sin cancha',
                  fecha: fecha,
                  horario: data['horario'] ?? 'Sin horario',
                  precio: data['precio'] ?? 'L 0',
                  docId: docId,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReservaCard({
    required String complejo,
    required String cancha,
    required DateTime fecha,
    required String horario,
    required String precio,
    required String docId,
  }) {
    final now = DateTime.now();
    final diferenciaDias = fecha.difference(DateTime(now.year, now.month, now.day)).inDays;

    String etiqueta = '';
    Color colorEtiqueta = Colors.transparent;
    IconData iconoEtiqueta = Icons.event;

    if (diferenciaDias == 0) {
  etiqueta = '🎯 Hoy';
  colorEtiqueta = Colors.orange;
} else if (diferenciaDias == 1) {
  etiqueta = '⏳ Mañana';
  colorEtiqueta = Colors.blue;
} else if (diferenciaDias <= 3) {
  etiqueta = '📆 En ${diferenciaDias} días';
  colorEtiqueta = Colors.green;
} else if (diferenciaDias <= 7) {
  etiqueta = '📅 Esta semana';
  colorEtiqueta = Colors.yellowAccent;
} else if (diferenciaDias > 7) {
  etiqueta = '🚀Futura';
  colorEtiqueta = Colors.purple;
}


    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stadium, color: const Color(0xFFFF6F00), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    complejo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
                if (etiqueta.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEtiqueta.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      etiqueta,
                      style: TextStyle(
                        color: colorEtiqueta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(Icons.sports_soccer, color: Colors.blue.shade700),
                    const SizedBox(height: 16),
                    Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
                    const SizedBox(height: 16),
                    Icon(Icons.access_time, color: Colors.blue.shade700),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cancha,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatDate(fecha),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        horario,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Confirmada',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        precio,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

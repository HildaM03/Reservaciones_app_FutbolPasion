import 'package:flutter/material.dart';
import 'package:resrevacion_canchas/ReservaPage.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleComplejoPage extends StatefulWidget {
  final Map<String, dynamic> complejo;

  const DetalleComplejoPage({super.key, required this.complejo});

  @override
  State<DetalleComplejoPage> createState() => _DetalleComplejoPageState();
}

class _DetalleComplejoPageState extends State<DetalleComplejoPage> {
  List<Map<String, dynamic>> canchasDisponibles = [];
  List<Map<String, dynamic>> canchasReservadas = [];

  @override
  void initState() {
    super.initState();
    canchasDisponibles = List.from(widget.complejo['canchas'] ?? []);
    canchasReservadas = [];
  }

  void _abrirEnMaps(String coordenadas) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$coordenadas';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir Google Maps';
    }
  }

  void _reservarCancha(Map<String, dynamic> cancha) {
    setState(() {
      canchasDisponibles.removeWhere((c) => c['nombre'] == cancha['nombre']);
      canchasReservadas.add({...cancha, 'fechaReserva': DateTime.now()});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.complejo['nombre']),
        backgroundColor: const Color(0xFFD4534E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.complejo['imagen'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(widget.complejo['imagen']),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.complejo['ubicacion'] ?? 'Ubicación no disponible')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.blue),
                const SizedBox(width: 8),
                Text(widget.complejo['telefono'] ?? 'Teléfono no disponible'),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.complejo['coordenadas'] != null)
              GestureDetector(
                onTap: () => _abrirEnMaps(widget.complejo['coordenadas']),
                child: const Text(
                  'Ver en Google Maps',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
            const SizedBox(height: 16),

            // Canchas disponibles
            const Text(
              'Canchas disponibles:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...canchasDisponibles.map<Widget>((cancha) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(cancha['nombre']),
                  subtitle: Text('Jugadores: ${cancha['jugadores']}\nPrecio: ${cancha['precio']}'),
                  onTap: () async {
                    final reservaExitosa = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservaPage(cancha: cancha),
                      ),
                    );
                    if (reservaExitosa == true) {
                      _reservarCancha(cancha);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cancha reservada con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              );
            }).toList(),

            // Canchas reservadas
            if (canchasReservadas.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Canchas reservadas:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ...canchasReservadas.map<Widget>((cancha) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.red[50],
                  child: ListTile(
                    title: Text(
                      cancha['nombre'],
                      style: const TextStyle(color: Colors.red),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jugadores: ${cancha['jugadores']}'),
                        Text('Precio: ${cancha['precio']}'),
                        if (cancha['fechaReserva'] != null)
                          Text(
                            'Reservado: ${cancha['fechaReserva'].toString().substring(0, 16)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.check_circle, color: Colors.red),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
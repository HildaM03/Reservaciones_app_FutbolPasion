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

  // Colores azul y naranja
  final Color azulOscuro = Color(0xFF0D47A1);
  final Color naranjaOscuro = Color(0xFFFF6F00);
  final Color azulClaro = Color(0xFF42A5F5);

  @override
  void initState() {
    super.initState();
    canchasDisponibles = List.from(widget.complejo['canchas'] ?? []);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.complejo['nombre'],
          style: const TextStyle(color: Colors.white), // Title text color set to white
        ),
        backgroundColor: naranjaOscuro,
        iconTheme: const IconThemeData(color: Colors.white), // Back button color set to white
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
                Icon(Icons.location_on, color: azulOscuro),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.complejo['ubicacion'] ?? 'Ubicación no disponible')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: naranjaOscuro),
                const SizedBox(width: 8),
                Text(widget.complejo['telefono'] ?? 'Teléfono no disponible'),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.complejo['coordenadas'] != null)
              GestureDetector(
                onTap: () => _abrirEnMaps(widget.complejo['coordenadas']),
                child: Text(
                  'Ver en Google Maps',
                  style: TextStyle(
                    color: azulClaro,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Canchas disponibles
            Text(
              'Canchas disponibles:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: azulOscuro,
              ),
            ),
            const SizedBox(height: 8),
            ...canchasDisponibles.map<Widget>((cancha) {
              return Card(
                color: Colors.grey[600],
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    cancha['nombre'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Jugadores: ${cancha['jugadores']}\nPrecio: ${cancha['precio']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    final reservaExitosa = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservaPage(
                          cancha: cancha,
                          complejo: widget.complejo, // Pasamos el complejo completo
                        ),
                      ),
                    );
                    if (reservaExitosa == true) {
                      _reservarCancha(cancha);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cancha reservada con éxito'),
                          backgroundColor: naranjaOscuro,
                        ),
                      );
                    }
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:resrevacion_canchas/detalle_complejo_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplejosPage extends StatelessWidget {
  final List<Map<String, dynamic>> complejos = [
    {
      'nombre': 'SportMania',
      'telefono': '9495-5555',
      'ubicacion':
          '1ra Avenida, entre 10 y 12 Calle N.O., Barrio Las Acacias, San Pedro Sula, Honduras',
      'coordenadas': '15.514816582124888,-88.02116407116452',
      'imagen':
          'https://scontent.fsap12-1.fna.fbcdn.net/v/t39.30808-6/322876158_554170996568371_4651767928234651329_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=QnpxfVFthpsQ7kNvwHFM5W5&_nc_oc=AdnS1_D57YvjZ-H_gT5-8AE0ww99yvDgWFbpattthXcNL2s0fdKTdvQWITtpgBhAZgY&_nc_zt=23&_nc_ht=scontent.fsap12-1.fna&_nc_gid=AHf7rHn9-cdzGRBT-iB4yw&oh=00_AfMkBmf6pTRN0oOkYgNII9-2xn9cqYOHg20J7iYm2OtwAw&oe=6858BCD0',
      'canchas': [
        {'nombre': 'Cancha 1', 'jugadores': '8 vs 8', 'precio': '800 Lps / hora'},
        {'nombre': 'Cancha 2', 'jugadores': '8 vs 8', 'precio': '800 Lps / hora'},
        {'nombre': 'Cancha 3', 'jugadores': '8 vs 8', 'precio': '800 Lps / hora'},
        {'nombre': 'Cancha 4', 'jugadores': '7 vs 7', 'precio': '700 Lps / hora'},
        {'nombre': 'Cancha 5', 'jugadores': '7 vs 7', 'precio': '700 Lps / hora'},
        {'nombre': 'Cancha 6', 'jugadores': '7 vs 7', 'precio': '700 Lps / hora'},
        {'nombre': 'Cancha 7', 'jugadores': '7 vs 7', 'precio': '700 Lps / hora'},
        {'nombre': 'Cancha 8', 'jugadores': '5 vs 5', 'precio': '500 Lps / hora'},
        {'nombre': 'Cancha 9', 'jugadores': '5 vs 5', 'precio': '500 Lps / hora'},
        {'nombre': 'Cancha 10', 'jugadores': '5 vs 5', 'precio': '500 Lps / hora'},
      ]
    },
    {
      'nombre': 'Canchas Maracana Palenque',
      'telefono': '8768-5305',
      'ubicacion': 'Sector Palenque, San Pedro Sula, Honduras',
      'coordenadas': '15.54221, -88.02114',
      'imagen': 'https://graph.facebook.com/1240228296026868/picture?type=large',
      'canchas': [
        {'nombre': 'Cancha 1', 'jugadores': '7 vs 7', 'precio': '700 Lps / hora'},
        {'nombre': 'Cancha 2', 'jugadores': '7 vs 7', 'precio': '700 Lps / hora'},
        {'nombre': 'Cancha 3', 'jugadores': '7 vs 7', 'precio': '700 Lps / hora'},
      ]
    },
    {
      'nombre': 'Canchas De Futbol Taki Take Sports',
      'telefono': '9794-9697',
      'ubicacion': 'San Pedro Sula, Honduras',
      'coordenadas': '15.53668,-88.01277',
      'imagen': 'https://lh3.googleusercontent.com/gps-cs-s/AC9h4novAzBFrEcJdnW-MouOeIEaOZpriBxYbUp66FwzP0l5c70G8zekzO6-neIKbNdbe6uppVJMNaBDvhGgSWqn0QpZmZd_rjEcsCIgrWVorSd0K0In-2R-v2wha7w-Ppt7KgxLlHx4=w426-h240-k-no',
      'canchas': [
        {'nombre': 'Cancha 1', 'jugadores': '5 vs 5', 'precio': '450 Lps / hora'},
        {'nombre': 'Cancha 2', 'jugadores': '5 vs 5', 'precio': '450 Lps / hora'},
      ]
    },
    {
      'nombre': 'Complejo Deportivo Alberto Chedrani',
      'telefono': 'N/A',
      'ubicacion': '14 Avenida NO, San Pedro Sula, Cortes',
      'coordenadas': '15.51178,-88.03444',
      'imagen': 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=500',
      'canchas': [
        {'nombre': 'Cancha 1', 'jugadores': '6 vs 6', 'precio': '600 Lps / hora'},
      ]
    },
    {
      'nombre': 'Complejo Deportivo Emil Martínez',
      'telefono': '+504 9923-4324',
      'ubicacion': '21 Avenida NO, San Pedro Sula 21102, Honduras',
      'coordenadas': '15.51819, -88.03705',
      'imagen': 'https://th.bing.com/th/id/OIP.AWKFogBT8gEjfjxK_gWskQHaEK',
      'canchas': [
        {'nombre': 'Cancha 1', 'jugadores': '5 vs 5', 'precio': '500 Lps / hora'},
        {'nombre': 'Cancha 2', 'jugadores': '5 vs 5', 'precio': '500 Lps / hora'},
        {'nombre': 'Cancha 3', 'jugadores': '7 vs 7', 'precio': '750 Lps / hora'},
      ]
    },
    {
      'nombre': 'Complejo Deportivo Juan Lindo',
      'telefono': 'N/A',
      'ubicacion': 'GX93+CW2, C. Juan Lindo, San Pedro Sula 21102, Honduras',
      'coordenadas': '15.51876, -88.04524',
      'imagen': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=500',
      'canchas': [
        {'nombre': 'Cancha 1', 'jugadores': '8 vs 8', 'precio': '800 Lps / hora'},
        {'nombre': 'Cancha 2', 'jugadores': '7 vs 7', 'precio': '700 Lps / hora'},
      ]
    },
    {
      'nombre': 'Cancha Patria Marathon',
      'telefono': 'N/A',
      'ubicacion': '13 Calle SO, San Pedro Sula, Cortes',
      'coordenadas': '15.49412,-88.02863',
      'imagen': 'https://http2.mlstatic.com/D_NQ_NP_291905-MLM25083015044_102016-V.jpg',
      'canchas': [
        {'nombre': 'Cancha 1', 'jugadores': '8 vs 8', 'precio': '800 Lps / hora'},
        {'nombre': 'Cancha 2', 'jugadores': '6 vs 6', 'precio': '600 Lps / hora'},
      ]
    },
  ];

  void _openMaps(String coordenadas) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$coordenadas';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complejos Deportivos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: complejos.length,
        itemBuilder: (context, index) {
          final complejo = complejos[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetalleComplejoPage(complejo: complejo),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      complejo['imagen'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complejo['nombre'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6F00),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (complejo['ubicacion'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ubicación:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(complejo['ubicacion'],
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 8),
                            ],
                          ),
                        if (complejo['coordenadas'].isNotEmpty)
                          GestureDetector(
                            onTap: () => _openMaps(complejo['coordenadas']),
                            child: const Text(
                              'Ver en Google Maps',
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              complejo['telefono'] == 'N/A'
                                  ? 'Teléfono no disponible'
                                  : 'Tel: ${complejo['telefono']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

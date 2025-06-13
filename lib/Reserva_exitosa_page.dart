import 'package:flutter/material.dart';

class ReservaExitosaPage extends StatelessWidget {
  final Map<String, dynamic> reserva;

  const ReservaExitosaPage({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {
    // Formatear la fecha
    final fecha = reserva['fecha'] != null 
        ? DateTime.parse(reserva['fecha']) 
        : null;
    final fechaFormateada = fecha != null ? _formatDate(fecha) : 'No especificada';
    final horario = reserva['horario']?.toString() ?? 'No especificado';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FD), // Fondo azul muy claro
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                
                // Icono de confirmación
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Título del complejo (azul)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[800]!.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    reserva['complejo']?.toString() ?? 'Centro Deportivo CanchasGT',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Tarjeta de detalles de reserva
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Fila Cancha
                        _buildDetailRow(
                          icon: Icons.sports_soccer,
                          label: 'Cancha',
                          value: '"${reserva['cancha']?.toString() ?? 'No especificada'}"',
                        ),
                        
                        const Divider(color: Colors.grey, height: 24),
                        
                        // Fila Jugadores
                        _buildDetailRow(
                          icon: Icons.people,
                          label: 'Jugadores',
                          value: reserva['jugadores']?.toString() ?? 'No especificado',
                        ),
                        
                        const Divider(color: Colors.grey, height: 24),
                        
                        // Fila Fecha
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Fecha',
                          value: fechaFormateada,
                        ),
                        
                        const Divider(color: Colors.grey, height: 24),
                        
                        // Fila Horario
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Horario',
                          value: horario,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Mensaje de éxito
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    '¡Reserva confirmada con éxito!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Botón ACEPTAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      shadowColor: Colors.blue[900],
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text(
                      'ACEPTAR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
    final months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return '${days[date.weekday % 7]}. ${date.day} ${months[date.month - 1]}. ${date.year}';
  }
}
import 'package:flutter/material.dart';
import 'package:resrevacion_canchas/ConfirmacionReservaPage.dart';

class ReservaPage extends StatefulWidget {
  final Map<String, dynamic> cancha;

  const ReservaPage({super.key, required this.cancha});

  @override
  State<ReservaPage> createState() => _ReservaPageState();
}

class _ReservaPageState extends State<ReservaPage> {
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _horarios = [
    '8:00-9:00 AM',
    '9:00-10:00 AM',
    '10:00-11:00 AM',
    '11:00-12:00 PM',
    '12:00-1:00 PM',
    '1:00-2:00 PM',
    '2:00-3:00 PM',
    '3:00-4:00 PM',
    '4:00-5:00 PM',
    '5:00-6:00 PM',
    '6:00-7:00 PM',
    '7:00-8:00 PM',
    '8:00-9:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar ${widget.cancha['nombre']}'),
        backgroundColor: const Color(0xFFD4534E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la cancha
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cancha "${widget.cancha['nombre']}"',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Jugadores: ${widget.cancha['jugadores']}'),
                    const SizedBox(height: 8),
                    Text('Precio: ${widget.cancha['precio']}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Selector de fecha (opcional)
            const Text(
              'Selecciona una fecha:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate == null
                          ? 'Seleccionar Fecha'
                          : _formatDate(_selectedDate!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Horarios disponibles (siempre visibles)
            const Text(
              'Horarios disponibles:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _horarios.length,
              itemBuilder: (context, index) {
                final horario = _horarios[index];
                final isSelected = _selectedTime == horario;

                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = horario),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.transparent : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.green, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        horario,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // Botón Continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4534E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _validateAndContinue,
                child: const Text('CONTINUAR', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }

  void _validateAndContinue() {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un horario')),
      );
      return;
    }

    final fechaFinal = _selectedDate ?? DateTime.now();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmacionReservaPage(
          cancha: widget.cancha,
          fecha: fechaFinal,
          horario: _selectedTime!,
          precio: widget.cancha['precio'].toString().split(' ')[0],
        )
      ),
    );
  }
}

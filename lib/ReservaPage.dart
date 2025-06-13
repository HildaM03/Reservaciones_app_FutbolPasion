import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resrevacion_canchas/ConfirmacionReservaPage.dart';

class ReservaPage extends StatefulWidget {
  final Map<String, dynamic> cancha;
  final Map<String, dynamic> complejo;

  const ReservaPage({
    super.key,
    required this.cancha,
    required this.complejo,
  });

  @override
  State<ReservaPage> createState() => _ReservaPageState();
}

class _ReservaPageState extends State<ReservaPage> {
  DateTime? _selectedDate;
  String? _selectedTime;
  List<String> _horariosReservados = [];
  int? _hoveredIndex;

  // Colores del tema
  final Color _colorPrimario = Color(0xFF0D47A1); // Azul
  final Color _colorSecundario = Color(0xFFFF6F00); // Naranja
  final Color _colorHorarioDisponible = Colors.green;
  final Color _colorHorarioSeleccionado = Colors.transparent;
  final Color _colorBordeSeleccionado = Colors.green;
  final Color _colorHorarioReservado = Colors.red;
  final Color _colorHover = Colors.green.withOpacity(0.7);

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

  String _getPrecioNumerico() {
    final precio = widget.cancha['precio'].toString();
    return precio.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final precioNumerico = _getPrecioNumerico();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.complejo['nombre'] ?? 'Reserva'),
        backgroundColor: _colorPrimario,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la cancha
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_soccer, color: _colorSecundario, size: 28), // Ícono de balón
                          const SizedBox(width: 8),
                          Text(
                            widget.cancha['nombre'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _colorPrimario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Icon(Icons.people, color: _colorSecundario),
                        const SizedBox(width: 8),
                        Text(
                          'Jugadores: ${widget.cancha['jugadores']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: _colorSecundario),
                        const SizedBox(width: 8),
                        Text(
                          'Precio hora: L $precioNumerico',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                    Icon(Icons.calendar_today, color: _colorPrimario),
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
                final isReserved = _horariosReservados.any(
                  (h) => h.trim().toLowerCase() == horario.trim().toLowerCase(),
                );
                final isHovered = _hoveredIndex == index && !isReserved && !isSelected;

                return MouseRegion(
                  onEnter: (event) => setState(() => _hoveredIndex = index),
                  onExit: (event) => setState(() => _hoveredIndex = null),
                  child: GestureDetector(
                    onTap: isReserved
                        ? null
                        : () => setState(() => _selectedTime = horario),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isReserved
                            ? _colorHorarioReservado
                            : isSelected
                                ? _colorHorarioSeleccionado
                                : isHovered
                                    ? _colorHover
                                    : _colorHorarioDisponible,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: _colorBordeSeleccionado, width: 2)
                            : null,
                        boxShadow: isHovered
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          horario,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorSecundario,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _validateAndContinue,
                child: const Text(
                  'RESERVAR',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      await _cargarHorariosReservados();
    }
  }

  Future<void> _cargarHorariosReservados() async {
    if (_selectedDate == null) return;

    final firestore = FirebaseFirestore.instance;

    try {
      final String canchaNombre = widget.cancha['nombre'];
      final String complejoNombre = widget.complejo['nombre'];
      final String fechaString = _selectedDate!.toIso8601String().split('T').first;

      final querySnapshot = await firestore
          .collection('reservas')
          .where('canchaNombre', isEqualTo: canchaNombre)
          .where('complejoNombre', isEqualTo: complejoNombre)
          .where('fecha', isEqualTo: fechaString)
          .get();

      final horariosReservados = querySnapshot.docs
          .map((doc) => (doc['horario'] as String).trim())
          .toList();

      setState(() {
        _horariosReservados = horariosReservados;
        _selectedTime = null;
      });

    } catch (e) {
      print('Error al cargar horarios reservados: $e');
      setState(() {
        _horariosReservados = [];
      });
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }

  void _validateAndContinue() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un horario')),
      );
      return;
    }

    final isReserved = _horariosReservados.any(
      (h) => h.trim().toLowerCase() == _selectedTime!.trim().toLowerCase(),
    );
    if (isReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El horario seleccionado ya está reservado')),
      );
      return;
    }

    final precioNumerico = _getPrecioNumerico();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmacionReservaPage(
          cancha: widget.cancha,
          complejo: widget.complejo,
          fecha: _selectedDate!,
          horario: _selectedTime!,
          precio: 'L $precioNumerico',
        ),
      ),
    );
  }
}
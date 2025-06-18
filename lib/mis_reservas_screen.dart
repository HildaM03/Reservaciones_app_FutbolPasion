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
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser ;
  }

  Future<List<Map<String, dynamic>>> _fetchReservas() async {
    if (user == null) return [];

    final usuarioEmail = user!.email;
    final activosQuery = await FirebaseFirestore.instance
        .collection('reservas')
        .where('correo', isEqualTo: usuarioEmail)
        .get();
    final canceladasQuery = await FirebaseFirestore.instance
        .collection('reservas_canceladas')
        .where('correo', isEqualTo: usuarioEmail)
        .get();

    List<Map<String, dynamic>> listaReservas = [];

    for (var doc in activosQuery.docs) {
      final data = doc.data();
      DateTime fecha = _parseFecha(data['fecha']);

      listaReservas.add({
        'data': data,
        'fecha': fecha,
        'docId': doc.id,
        'cancelada': false,
      });
    }

    for (var doc in canceladasQuery.docs) {
      final data = doc.data();
      DateTime fecha = _parseFecha(data['fecha']);

      listaReservas.add({
        'data': data,
        'fecha': fecha,
        'docId': doc.id,
        'cancelada': true,
      });
    }

    listaReservas.sort((a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
    return listaReservas;
  }

  DateTime _parseFecha(dynamic fecha) {
    if (fecha == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (fecha is Timestamp) return fecha.toDate();
    if (fecha is String) return DateTime.tryParse(fecha) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<List<String>> _fetchHorariosBloqueados(
      String complejoNombre, String canchaNombre, DateTime fecha) async {
    final normalizedFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('complejoNombre', isEqualTo: complejoNombre)
        .where('canchaNombre', isEqualTo: canchaNombre)
        .where('fecha', isEqualTo: Timestamp.fromDate(normalizedFecha))
        .get();

    return querySnapshot.docs
        .map((doc) => doc['horario'] as String?)
        .where((horario) => horario != null)
        .cast<String>()
        .toList();
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
        title: const Text('Mis Reservas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D47A1).withOpacity(0.1),
              const Color(0xFFFF6F00).withOpacity(0.05),
            ],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchReservas(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reservas = snapshot.data ?? [];
            if (reservas.isEmpty) {
              return const Center(child: Text('No tienes reservas registradas'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                return _buildReservaCard(
                  complejo: reserva['data']['complejoNombre'] ?? 'Sin nombre',
                  cancha: reserva['data']['canchaNombre'] ?? 'Sin cancha',
                  fecha: reserva['fecha'] as DateTime,
                  horario: reserva['data']['horario'] ?? 'Sin horario',
                  docId: reserva['docId'] as String,
                  cancelada: reserva['cancelada'] as bool,
                  data: reserva['data'] as Map<String, dynamic>,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _reagendarReserva(BuildContext context, String docId, Map<String, dynamic> data) async {
    DateTime initialFecha = _parseFecha(data['fecha']);
    initialFecha = DateTime(initialFecha.year, initialFecha.month, initialFecha.day);

    DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: initialFecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (nuevaFecha == null) return;
    nuevaFecha = DateTime(nuevaFecha.year, nuevaFecha.month, nuevaFecha.day);

    String horarioSeleccionado = data['horario'] ?? _horarios.first;
    Set<String> blockedHorarios = {};
    String? errorText;

    try {
      final bloques = await _fetchHorariosBloqueados(
        data['complejoNombre'],
        data['canchaNombre'],
        nuevaFecha,
      );
      blockedHorarios = bloques.toSet();

      // Si el horario actual está bloqueado, buscar el primer disponible
      if (blockedHorarios.contains(horarioSeleccionado)) {
        for (var horario in _horarios) {
          if (!blockedHorarios.contains(horario)) {
            horarioSeleccionado = horario;
            break;
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar disponibilidad: $e')),
      );
      return;
    }

    bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool horarioBloqueado = blockedHorarios.contains(horarioSeleccionado);

            return AlertDialog(
              title: const Text('Reagendar Reserva'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Fecha: ${_formatDate(nuevaFecha!)}'),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: horarioSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Horario',
                      errorText: horarioBloqueado ? 'Horario no disponible' : null,
                      border: OutlineInputBorder(),
                    ),
                    items: _horarios.map((horario) {
                      bool bloqueado = blockedHorarios.contains(horario);
                      return DropdownMenuItem(
                        value: horario,
                        enabled: !bloqueado,
                        child: Row(
                          children: [
                            if (bloqueado) Icon(Icons.block, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              horario,
                              style: TextStyle(
                                color: bloqueado ? Colors.red : Colors.black,
                                decoration: bloqueado ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && !blockedHorarios.contains(value)) {
                        setState(() {
                          horarioSeleccionado = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: blockedHorarios.contains(horarioSeleccionado)
                      ? null
                      : () => Navigator.pop(context, true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) return;

    try {
      // Validación final antes de actualizar
      final horariosOcupados = await _fetchHorariosBloqueados(
        data['complejoNombre'],
        data['canchaNombre'],
        nuevaFecha,
      );

      if (horariosOcupados.contains(horarioSeleccionado)) {
        throw Exception('El horario seleccionado ya no está disponible');
      }

      await FirebaseFirestore.instance.collection('reservas').doc(docId).update({
        'fecha': Timestamp.fromDate(nuevaFecha),
        'horario': horarioSeleccionado,
        'estado': 'reagendada',
        'fecha_actualizada': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva reagendada exitosamente')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reagendar: $e')),
      );
    }
  }

  Widget _buildReservaCard({
    required String complejo,
    required String cancha,
    required DateTime fecha,
    required String horario,
    required String docId,
    required bool cancelada,
    required Map<String, dynamic> data,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diferenciaDias = fecha.difference(today).inDays;

    // Etiqueta relativa de fecha (Hoy, Mañana, etc.)
    String etiquetaFecha = '';
    Color colorEtiquetaFecha = Colors.transparent;

    if (cancelada) {
      etiquetaFecha = '❌ Cancelada';
      colorEtiquetaFecha = Colors.grey;
    } else if (diferenciaDias == 0) {
      etiquetaFecha = '🎯 Hoy';
      colorEtiquetaFecha = Colors.orange;
    } else if (diferenciaDias == 1) {
      etiquetaFecha = '⏳ Mañana';
      colorEtiquetaFecha = Colors.blue;
    } else if (diferenciaDias <= 3) {
      etiquetaFecha = '📆 En $diferenciaDias días';
      colorEtiquetaFecha = Colors.green;
    } else if (diferenciaDias <= 7) {
      etiquetaFecha = '📅 Esta semana';
      colorEtiquetaFecha = Colors.yellow;
    } else {
      etiquetaFecha = '🚀 Futura';
      colorEtiquetaFecha = Colors.purple;
    }

    // Estado de reserva (Confirmada, Reagendada, Cancelada) con ícono para el chip
    String estadoTexto = '';
    Widget? estadoIcono;
    Color colorEstado = Colors.transparent;

    if (cancelada) {
      estadoTexto = 'Cancelada';
      colorEstado = Colors.grey.shade200;
      estadoIcono = null;
    } else if (data['estado'] == 'reagendada') {
      estadoTexto = 'Reagendada';
      estadoIcono = const Icon(Icons.refresh, color: Colors.blue, size: 18);
      colorEstado = Colors.blue.shade50;
    } else {
      estadoTexto = 'Confirmada';
      estadoIcono = const Icon(Icons.check_circle, color: Colors.green, size: 18);
      colorEstado = Colors.green.shade50;
    }

    Color colorPrincipal = cancelada ? Colors.grey : const Color(0xFF0D47A1);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stadium, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    complejo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorPrincipal,
                      decoration: cancelada ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorEtiquetaFecha.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    etiquetaFecha,
                    style: TextStyle(
                      color: colorEtiquetaFecha,
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
                    Icon(Icons.sports_soccer, color: cancelada ? Colors.grey : Colors.blue),
                    const SizedBox(height: 16),
                    Icon(Icons.calendar_today, color: cancelada ? Colors.grey : Colors.blue),
                    const SizedBox(height: 16),
                    Icon(Icons.access_time, color: cancelada ? Colors.grey : Colors.blue),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cancha),
                      const SizedBox(height: 16),
                      Text(_formatDate(fecha)),
                      const SizedBox(height: 16),
                      Text(horario),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Chip(
                      backgroundColor: colorEstado,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (estadoIcono != null) ...[
                            estadoIcono,
                            const SizedBox(width: 6),
                          ],
                          Text(
                            estadoTexto,
                            style: TextStyle(
                              color: cancelada ? Colors.grey : (data['estado'] == 'reagendada' ? Colors.blue : Colors.green),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!cancelada) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _cancelarReserva(context, docId, data),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_calendar),
                      label: const Text('Reagendar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _reagendarReserva(context, docId, data),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _cancelarReserva(BuildContext context, String docId, Map<String, dynamic> data) async {
    bool confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cancelación'),
        content: const Text('¿Estás seguro de que quieres cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmado) return;

    try {
      final reservaRef = FirebaseFirestore.instance.collection('reservas').doc(docId);
      final reservaSnapshot = await reservaRef.get();

      if (!reservaSnapshot.exists) return;

      final reservaData = reservaSnapshot.data()!;
      
      // Mover a reservas_canceladas
      await FirebaseFirestore.instance.collection('reservas_canceladas').add({
        ...reservaData,
        'fechaOriginal': reservaData['fecha'],
        'fecha_cancelacion': FieldValue.serverTimestamp(),
      });

      // Eliminar de reservas activas
      await reservaRef.delete();

      // Liberar el horario en la cancha
      await _liberarHorario(reservaData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada exitosamente')),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar: $e')),
      );
    }
  }

  Future<void> _liberarHorario(Map<String, dynamic> reservaData) async {
    final canchaId = reservaData['canchaId'];
    final complejoId = reservaData['complejoId'];
    final horario = reservaData['horario'];
    final fecha = _parseFecha(reservaData['fecha']);
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);

    final canchaRef = FirebaseFirestore.instance
        .collection('complejos')
        .doc(complejoId)
        .collection('canchas')
        .doc(canchaId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final canchaSnap = await transaction.get(canchaRef);
      if (!canchaSnap.exists) return;

      final canchaData = canchaSnap.data()!;
      final horarios = Map<String, dynamic>.from(canchaData['horarios'] ?? {});
      final horariosDelDia = List<String>.from(horarios[fechaStr] ?? []);

      if (horariosDelDia.contains(horario)) {
        horariosDelDia.remove(horario);
        horarios[fechaStr] = horariosDelDia;
        transaction.update(canchaRef, {'horarios': horarios});
      }
    });
  }

  String _formatDate(DateTime date) {
    final days = ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB'];
    final months = [
      'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return '${days[date.weekday == 7 ? 0 : date.weekday]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
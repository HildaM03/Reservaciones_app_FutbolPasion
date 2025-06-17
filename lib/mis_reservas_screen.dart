
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
    user = FirebaseAuth.instance.currentUser;
  }

  Future<List<Map<String, dynamic>>> _fetchReservas() async {
    if (user == null) return [];

    final usuarioEmail = user!.email;

    // Obtener reservas activas
    final activosQuery = await FirebaseFirestore.instance
        .collection('reservas')
        .where('correo', isEqualTo: usuarioEmail)
        .get();

    // Obtener reservas canceladas
    final canceladasQuery = await FirebaseFirestore.instance
        .collection('reservas_canceladas')
        .where('correo', isEqualTo: usuarioEmail)
        .get();

    List<Map<String, dynamic>> listaReservas = [];

    for (var doc in activosQuery.docs) {
      final data = doc.data();

      DateTime fecha;
      if (data['fecha'] == null) {
        fecha = DateTime.fromMillisecondsSinceEpoch(0);
      } else if (data['fecha'] is Timestamp) {
        fecha = (data['fecha'] as Timestamp).toDate();
      } else if (data['fecha'] is String) {
        fecha = DateTime.tryParse(data['fecha'] as String) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      } else {
        fecha = DateTime.fromMillisecondsSinceEpoch(0);
      }

      String precio = data['precio']?.toString() ?? '0';
      precio = precio.replaceAll('L.', '').replaceAll('L', '').trim();
      precio = 'L $precio';

      listaReservas.add({
        'data': {...data, 'precio': precio},
        'fecha': fecha,
        'docId': doc.id,
        'cancelada': false,
      });
    }

    for (var doc in canceladasQuery.docs) {
      final data = doc.data();

      DateTime fecha;
      if (data['fecha'] == null) {
        fecha = DateTime.fromMillisecondsSinceEpoch(0);
      } else if (data['fecha'] is Timestamp) {
        fecha = (data['fecha'] as Timestamp).toDate();
      } else if (data['fecha'] is String) {
        fecha = DateTime.tryParse(data['fecha'] as String) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      } else {
        fecha = DateTime.fromMillisecondsSinceEpoch(0);
      }

      String precio = data['precio']?.toString() ?? '0';
      precio = precio.replaceAll('L.', '').replaceAll('L', '').trim();
      precio = 'L $precio';

      listaReservas.add({
        'data': {...data, 'precio': precio},
        'fecha': fecha,
        'docId': doc.id,
        'cancelada': true,
      });
    }

    // Ordenar por fecha descendente
    listaReservas.sort((a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));

    return listaReservas;
  }

  Future<List<String>> _fetchHorariosBloqueados(
      String complejoNombre, String canchaNombre, DateTime fecha) async {
    // Query all active reservas (non-cancelled) for given complejo, cancha, and date to get all blocked horarios
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('complejoNombre', isEqualTo: complejoNombre)
        .where('canchaNombre', isEqualTo: canchaNombre)
        .where('fecha', isEqualTo: Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day)))
        .get();

    final blockedHorarios = <String>{};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final String? horario = data['horario'] as String?;
      if (horario != null) {
        blockedHorarios.add(horario);
      }
    }

    return blockedHorarios.toList();
  }

  Future<bool> _isHorarioBloqueado(
      String complejoNombre, String canchaNombre, DateTime fecha, String horario) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('complejoNombre', isEqualTo: complejoNombre)
        .where('canchaNombre', isEqualTo: canchaNombre)
        .where('fecha', isEqualTo: Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day)))
        .where('horario', isEqualTo: horario)
        .get();

    return querySnapshot.docs.isNotEmpty; // Retorna true si hay reservas para ese horario
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchReservas(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.black)));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1))),
              );
            }

            final reservas = snapshot.data ?? [];

            if (reservas.isEmpty) {
              return const Center(
                child: Text('No tienes reservas registradas',
                    style: TextStyle(color: Colors.black)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                final data = reserva['data'] as Map<String, dynamic>;
                final fecha = reserva['fecha'] as DateTime;
                final docId = reserva['docId'] as String;
                final cancelada = reserva['cancelada'] as bool;

                return _buildReservaCard(
                  complejo: data['complejoNombre'] ?? 'Sin nombre',
                  cancha: data['canchaNombre'] ?? 'Sin cancha',
                  fecha: fecha,
                  horario: data['horario'] ?? 'Sin horario',
                  precio: data['precio'] ?? 'L 0',
                  docId: docId,
                  cancelada: cancelada,
                  data: data,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _reagendarReserva(BuildContext context, String docId, Map<String, dynamic> data) async {
    final initialFecha = (data['fecha'] is Timestamp) ? (data['fecha'] as Timestamp).toDate() : DateTime.now();

    DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: initialFecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecciona nueva fecha',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF0D47A1), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D47A1), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (nuevaFecha == null) return;

    String horarioSeleccionado = data['horario'] ?? _horarios.first;

    Set<String> blockedHorarios = {};

    // Fetch blocked horarios for the selected fecha and cancha/complejo
    try {
      final bloques = await _fetchHorariosBloqueados(
        data['complejoNombre'],
        data['canchaNombre'],
        nuevaFecha,
      );
      blockedHorarios = bloques.toSet();
    } catch (e) {
      // If error occurs, consider no horarios blocked (optional: show message)
      blockedHorarios = {};
    }

    // Use StatefulBuilder inside dialog for dynamic updates
    bool horarioBloqueado = blockedHorarios.contains(horarioSeleccionado);
    String? errorText;

    bool confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            InputDecoration dropdownDecoration = InputDecoration(
              labelText: 'Nuevo Horario',
              labelStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: horarioBloqueado ? Colors.red : const Color(0xFF0D47A1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: horarioBloqueado ? Colors.red : Colors.grey),
              ),
              errorText: errorText,
            );

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Reagendar Reserva', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Nueva fecha:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _formatDate(nuevaFecha),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: horarioSeleccionado,
                    decoration: dropdownDecoration,
                    items: _horarios.map((horario) {
                      final bool isBlocked = blockedHorarios.contains(horario);
                      return DropdownMenuItem<String>(
                        value: horario,
                        enabled: !isBlocked,
                        child: Text(
                          horario,
                          style: TextStyle(
                            fontSize: 14,
                            color: isBlocked ? Colors.red : Colors.black87,
                            decoration: isBlocked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      final bool blocked = blockedHorarios.contains(value);
                      if (blocked) {
                        // Show error feedback with snackbar or error text
                        setState(() {
                          errorText = 'Este horario ya está reservado.';
                        });
                      } else {
                        setState(() {
                          horarioSeleccionado = value;
                          horarioBloqueado = false;
                          errorText = null;
                        });
                      }
                    },
                    dropdownColor: Colors.white,
                    iconEnabledColor: const Color(0xFF0D47A1),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false), // Cancel dialog
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.blue, // cancel button background
                      foregroundColor: Colors.white, // cancel button text
                    ),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: horarioBloqueado // disable confirm if blocked
                      ? null
                      : () {
                          Navigator.pop(context, true);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: horarioBloqueado
                        ? Colors.grey
                        : const Color(0xFF0D47A1), // Confirm button color
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    ) ?? false;

    if (!confirmado) return;

    try {
      final reservaRef = FirebaseFirestore.instance.collection('reservas').doc(docId);

      await reservaRef.update({
        'fecha': Timestamp.fromDate(DateTime(nuevaFecha.year, nuevaFecha.month, nuevaFecha.day)),
        'horario': horarioSeleccionado,
        'estado': 'reagendada', // Cambiar el estado a "reagendada"
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
    required String precio,
    required String docId,
    required bool cancelada,
    required Map<String, dynamic> data,
  }) {
    final now = DateTime.now();
    final diferenciaDias = fecha.difference(DateTime(now.year, now.month, now.day)).inDays;

    String etiqueta = '';
    Color colorEtiqueta = Colors.transparent;
    Color colorPrincipal = cancelada ? Colors.grey : const Color(0xFF0D47A1);
    Color colorSecundario = cancelada ? Colors.grey : const Color(0xFFFF6F00);

    if (cancelada) {
      etiqueta = '❌ Cancelada';
      colorEtiqueta = Colors.grey;
    } else if (data['estado'] == 'reagendada') {
      etiqueta = '🔄 Reagendada';
      colorEtiqueta = Colors.blue;
    } else if (diferenciaDias == 0) {
      etiqueta = '🎯 Hoy';
      colorEtiqueta = Colors.orange;
    } else if (diferenciaDias == 1) {
      etiqueta = '⏳ Mañana';
      colorEtiqueta = Colors.blue;
    } else if (diferenciaDias <= 3) {
      etiqueta = '📆 En $diferenciaDias días';
      colorEtiqueta = Colors.green;
    } else if (diferenciaDias <= 7) {
      etiqueta = '📅 Esta semana';
      colorEtiqueta = Colors.yellowAccent;
    } else if (diferenciaDias > 7) {
      etiqueta = '🚀 Futura';
      colorEtiqueta = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: cancelada ? 2 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cancelada ? Colors.grey.shade100 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stadium, color: colorSecundario, size: 28),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer,
                        color: cancelada ? Colors.grey : Colors.blue.shade700,
                        size: 24),
                    const SizedBox(height: 16),
                    Icon(Icons.calendar_today,
                        color: cancelada ? Colors.grey : Colors.blue.shade700,
                        size: 24),
                    const SizedBox(height: 16),
                    Icon(Icons.access_time,
                        color: cancelada ? Colors.grey : Colors.blue.shade700,
                        size: 24),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cancha,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: cancelada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _formatDate(fecha),
                        style: TextStyle(
                          fontSize: 16,
                          decoration: cancelada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        horario,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: cancelada ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cancelada ? Colors.grey.shade200 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: cancelada ? Colors.grey : Colors.green.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cancelada ? Icons.block : Icons.check_circle,
                            color: cancelada ? Colors.grey : Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cancelada ? 'Cancelada ' : 'Confirmada',
                            style: const TextStyle(
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
                        color: cancelada ? Colors.grey.shade200 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: cancelada ? Colors.grey : Colors.blue.shade100),
                      ),
                      child: Text(
                        precio,
                        style: TextStyle(
                          color: cancelada ? Colors.grey : Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          decoration: cancelada ? TextDecoration.lineThrough : null,
                        ),
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
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white, // Texto blanco
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        // Confirmar cancelación
                        bool confirmado = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar cancelación'),
                            content: const Text(
                                '¿Estás seguro de que quieres cancelar esta reserva?'),
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
                        );

                        if (confirmado != true) return;

                        try {
                          final reservaRef = FirebaseFirestore.instance
                              .collection('reservas')
                              .doc(docId);
                          final reservaSnapshot = await reservaRef.get();

                          if (!reservaSnapshot.exists) return;

                          final reservaData = reservaSnapshot.data()!;
                          final canchaId = reservaData['canchaId'];
                          final complejoId = reservaData['complejoId'];
                          final horario = reservaData['horario'];

                          final fechaReserva = reservaData['fecha'] is Timestamp
                              ? (reservaData['fecha'] as Timestamp).toDate()
                              : DateTime.tryParse(
                                      reservaData['fecha'] as String? ?? '') ??
                                  DateTime.now();

                          final fechaStr =
                              DateFormat('yyyy-MM-dd').format(fechaReserva);

                          await FirebaseFirestore.instance
                              .collection('reservas_canceladas')
                              .add({
                            ...reservaData,
                            'fechaOriginal': reservaData['fecha'],
                            'fecha_cancelacion': FieldValue.serverTimestamp(),
                          });

                          await reservaRef.delete();

                          final canchaRef = FirebaseFirestore.instance
                              .collection('complejos')
                              .doc(complejoId)
                              .collection('canchas')
                              .doc(canchaId);

                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            final canchaSnap = await transaction.get(canchaRef);
                            if (!canchaSnap.exists) return;

                            final canchaData = canchaSnap.data()!;
                            final horarios =
                                Map<String, dynamic>.from(canchaData['horarios'] ?? {});
                            final horariosDelDia =
                                List<String>.from(horarios[fechaStr] ?? []);

                            if (!horariosDelDia.contains(horario)) {
                              horariosDelDia.add(horario);
                              horariosDelDia.sort();
                              horarios[fechaStr] = horariosDelDia;
                              transaction.update(canchaRef, {'horarios': horarios});
                            }
                          });

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Reserva cancelada exitosamente')),
                          );

                          setState(() {});
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al cancelar: $e')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_calendar, size: 20),
                      label: const Text('Reagendar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white, // Texto blanco
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        await _reagendarReserva(context, docId, data);
                      },
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

  String _formatDate(DateTime date) {
    final days = ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB'];
    final months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC'
    ];
    return '${days[date.weekday % 7]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}


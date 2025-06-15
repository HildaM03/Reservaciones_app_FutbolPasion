import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificacionesReservasScreen extends StatefulWidget {
  final String adminId;

  const NotificacionesReservasScreen({
    Key? key,
    required this.adminId,
  }) : super(key: key);

  @override
  State<NotificacionesReservasScreen> createState() => _NotificacionesReservasScreenState();
}

class _NotificacionesReservasScreenState extends State<NotificacionesReservasScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _reservas = [];
  List<Map<String, dynamic>> _nuevasReservas = [];
  int _contadorNotificaciones = 0;
  bool _mostrarNotificaciones = false;
  bool _isLoading = true;
  bool _hasError = false;
  DateTime? _ultimaActualizacion;

  @override
  void initState() {
    super.initState();
    _cargarReservasIniciales();
    _configurarListenerTiempoReal();
  }

  Future<void> _cargarReservasIniciales() async {
    try {
      final querySnapshot = await _firestore
          .collection('reservas')
          .orderBy('fecha', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _reservas = querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _formatearDatosReserva(doc.id, data);
          }).toList();
          _isLoading = false;
          _ultimaActualizacion = DateTime.now();
          _nuevasReservas.clear(); // Limpiar nuevas reservas al recargar
        });
      }
    } catch (e) {
      print('Error al cargar reservas iniciales: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  bool _esReservaDuplicada(Map<String, dynamic> reserva) {
    return _reservas.any((r) => 
      r['id'] == reserva['id'] || 
      (r['nombre'] == reserva['nombre'] && 
       r['fecha'] == reserva['fecha'] && 
       r['horario'] == reserva['horario']));
  }

  void _actualizarReservas(List<Map<String, dynamic>> nuevasReservas) {
    if (!mounted || nuevasReservas.isEmpty) return;
    
    final reservasFiltradas = nuevasReservas.where(
      (reserva) => !_esReservaDuplicada(reserva)
    ).toList();

    if (reservasFiltradas.isEmpty) return;

    setState(() {
      _contadorNotificaciones += reservasFiltradas.length;
      _nuevasReservas = [...reservasFiltradas, ..._nuevasReservas];
      _reservas = [...reservasFiltradas, ..._reservas];
      _ultimaActualizacion = DateTime.now();
    });

    for (final reserva in reservasFiltradas) {
      _mostrarNotificacion(reserva);
    }
  }

  void _configurarListenerTiempoReal() {
    _firestore.collection('reservas')
      .orderBy('fecha', descending: true)
      .snapshots()
      .listen((snapshot) {
        final nuevasReservas = snapshot.docChanges
            .where((change) => change.type == DocumentChangeType.added)
            .map((change) {
              final data = change.doc.data() as Map<String, dynamic>;
              return _formatearDatosReserva(change.doc.id, data);
            }).toList();

        _actualizarReservas(nuevasReservas);
      }, onError: (error) {
        print('Error en listener: $error');
        if (mounted) {
          setState(() => _hasError = true);
        }
      });
  }

  Map<String, dynamic> _formatearDatosReserva(String id, Map<String, dynamic> data) {
    return {
      'id': id,
      'nombre': data['nombre']?.toString() ?? 'Sin nombre',
      'complejo': data['complejo']?.toString() ?? 'Sin complejo',
      'cancha': data['cancha']?.toString() ?? 'Sin cancha',
      'fecha': _formatearFecha(data['fecha']),
      'horario': data['horario']?.toString() ?? 'Sin horario',
      'jugadores': data['jugadores']?.toString() ?? 'No especificado',
      'correo': data['correo']?.toString() ?? 'Sin correo',
      'timestamp': data['timestamp'] ?? FieldValue.serverTimestamp(),
    };
  }

  String _formatearFecha(dynamic fecha) {
    try {
      if (fecha is Timestamp) {
        return DateFormat('dd/MM/yyyy').format(fecha.toDate());
      } else if (fecha is String) {
        return DateFormat('dd/MM/yyyy').format(DateTime.parse(fecha));
      }
      return DateFormat('dd/MM/yyyy').format(DateTime.now());
    } catch (e) {
      return 'Fecha no válida';
    }
  }

  void _mostrarNotificacion(Map<String, dynamic> reserva) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NUEVA RESERVA', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            )),
            SizedBox(height: 8),
            Text('A nombre de: ${reserva['nombre']}', style: TextStyle(color: Colors.white)),
            Text('Complejo: ${reserva['complejo']}', style: TextStyle(color: Colors.white)),
            Text('Fecha: ${reserva['fecha']}', style: TextStyle(color: Colors.white)),
            Text('Horario: ${reserva['horario']}', style: TextStyle(color: Colors.white)),
          ],
        ),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _limpiarNotificaciones() {
    if (mounted) {
      setState(() {
        _contadorNotificaciones = 0;
        _nuevasReservas.clear();
        _mostrarNotificaciones = false;
        _ultimaActualizacion = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones de Reservas'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _mostrarNotificaciones = !_mostrarNotificaciones;
                      if (_mostrarNotificaciones) {
                        _contadorNotificaciones = 0;
                      }
                    });
                  }
                },
              ),
              if (_contadorNotificaciones > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$_contadorNotificaciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarReservasIniciales,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Lista principal de reservas
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Error al cargar reservas'),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _cargarReservasIniciales,
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        : _reservas.isEmpty
                            ? const Center(child: Text('No hay reservas registradas'))
                            : ListView.builder(
                                padding: EdgeInsets.only(top: _mostrarNotificaciones ? 180 : 0),
                                itemCount: _reservas.length,
                                itemBuilder: (context, index) {
                                  final reserva = _reservas[index];
                                  return Card(
                                    margin: const EdgeInsets.all(8),
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(reserva['nombre'], style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Complejo: ${reserva['complejo']}'),
                                          Text('Cancha: ${reserva['cancha']}'),
                                          Text('Fecha: ${reserva['fecha']}'),
                                          Text('Horario: ${reserva['horario']}'),
                                          Text('Jugadores: ${reserva['jugadores']}'),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(reserva['correo']),
                                          if (_nuevasReservas.any((r) => r['id'] == reserva['id']))
                                            Container(
                                              margin: EdgeInsets.only(top: 4),
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'NUEVO',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),

          // Panel de notificaciones
          if (_mostrarNotificaciones && _nuevasReservas.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 8,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ÚLTIMAS RESERVAS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue[800],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 20),
                            onPressed: () {
                              if (mounted) {
                                setState(() => _mostrarNotificaciones = false);
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ..._nuevasReservas.take(3).map((reserva) => Column(
                        children: [
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.calendar_today, color: Colors.blue),
                            title: Text(
                              reserva['nombre'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${reserva['complejo']} - ${reserva['cancha']}'),
                                Text('${reserva['fecha']} ${reserva['horario']}'),
                              ],
                            ),
                            trailing: Text(
                              'NUEVO',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                        ],
                      )),
                      if (_nuevasReservas.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+ ${_nuevasReservas.length - 3} más...',
                            style: TextStyle(
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
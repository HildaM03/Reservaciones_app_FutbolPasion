import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> _reservas = [];
  List<Map<String, dynamic>> _nuevasReservas = [];
  int _contadorNotificaciones = 0;
  bool _mostrarNotificaciones = false;
  bool _isLoading = true;
  bool _hasError = false;
  OverlayEntry? _overlayEntry;

  // Updated color scheme
  static const Color azulElectrico = Color(0xFF0D47A1);
  static const Color naranjaFuerte = Color(0xFFFF6F00);
  static const Color blanco = Colors.white;
  static final Color grisClaro = Colors.grey.shade300;
  static const Color verde = Color(0xFF2ECC71);
  static const Color rojo = Color(0xFFE74C3C);

  @override
  void initState() {
    super.initState();
    _cargarReservasIniciales();
    _configurarListenerTiempoReal();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      debugPrint('Error al reproducir sonido: $e');
    }
  }

  Future<void> _cargarReservasIniciales() async {
    try {
      final querySnapshot = await _firestore
          .collection('reservas')
          .orderBy('timestamp', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _reservas = querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _formatearDatosReserva(doc.id, data);
          }).toList();
          _isLoading = false;
          _nuevasReservas.clear();
        });
      }
    } catch (e) {
      debugPrint('Error al cargar reservas iniciales: $e');
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
    });

    _playNotificationSound();

    for (final reserva in reservasFiltradas) {
      _mostrarNotificacion(reserva);
    }
  }

  void _configurarListenerTiempoReal() {
    _firestore.collection('reservas')
      .orderBy('timestamp', descending: true)
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
        debugPrint('Error en listener: $error');
        if (mounted) {
          setState(() => _hasError = true);
        }
      });
  }

  Map<String, dynamic> _formatearDatosReserva(String id, Map<String, dynamic> data) {
    return {
      'id': id,
      'nombre': data['nombre']?.toString() ?? 'Sin nombre',
      'complejo': data['complejoNombre']?.toString() ?? 'Sin complejo',
      'cancha': data['canchaNombre']?.toString() ?? 'Sin cancha',
      // 'telefono': data['complejoTelefono']?.toString() ?? 'Sin teléfono', // Removed
      'ubicacion': data['complejoUbicacion']?.toString() ?? 'Sin ubicación',
      'fecha': _formatearFecha(data['fecha']),
      'horario': data['horario']?.toString() ?? 'Sin horario',
      'jugadores': data['jugadores']?.toString() ?? 'No especificado',
      'correo': data['correo']?.toString() ?? 'Sin correo',
      'precio': data['precio']?.toString() ?? 'Sin precio',
      'timestamp': data['timestamp'] ?? FieldValue.serverTimestamp(),
    };
  }

  String _formatearFecha(dynamic fecha) {
    try {
      if (fecha is Timestamp) {
        return DateFormat('dd/MM/yyyy').format(fecha.toDate());
      } else if (fecha is String) {
        // Parsear fecha en formato "2025-06-17"
        return DateFormat('dd/MM/yyyy').format(DateTime.parse(fecha));
      }
      return DateFormat('dd/MM/yyyy').format(DateTime.now());
    } catch (e) {
      return 'Fecha no válida';
    }
  }

  void _mostrarNotificacion(Map<String, dynamic> reserva) {
    if (!mounted) return;

    _removeOverlay();

    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 20,
        top: position.dy + kToolbarHeight + 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: blanco,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications, color: verde),
                    const SizedBox(width: 8),
                    Text(
                      'NUEVA RESERVA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: verde,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Nombre: ${reserva['nombre']}'),
                Text('Complejo: ${reserva['complejo']}'),
                Text('Cancha: ${reserva['cancha']}'),
                Text('Fecha: ${reserva['fecha']} ${reserva['horario']}'),
                Text('Precio: ${reserva['precio']}'),
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 5), _removeOverlay);
  }

  void _limpiarNotificaciones() {
    if (mounted) {
      setState(() {
        _contadorNotificaciones = 0;
        _nuevasReservas.clear();
        _mostrarNotificaciones = false;
      });
    }
  }

  Widget _buildReservaItem(Map<String, dynamic> reserva, bool esNueva) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: blanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: esNueva ? verde.withOpacity(0.3) : grisClaro,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            reserva['nombre'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: azulElectrico,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.place, size: 16, color: naranjaFuerte),
                  const SizedBox(width: 5),
                  Text('${reserva['complejo']} - ${reserva['cancha']}'),
                ],
              ),
              const SizedBox(height: 3),
              // Row( // Removed
              //   children: [
              //     Icon(Icons.phone, size: 16, color: naranjaFuerte),
              //     const SizedBox(width: 5),
              //     Text(reserva['telefono']),
              //   ],
              // ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: naranjaFuerte),
                  const SizedBox(width: 5),
                  Text(reserva['fecha']),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: naranjaFuerte),
                  const SizedBox(width: 5),
                  Text(reserva['horario']),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: naranjaFuerte),
                  const SizedBox(width: 5),
                  Text('${reserva['jugadores']}'),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: naranjaFuerte),
                  const SizedBox(width: 5),
                  Text('${reserva['precio']}'),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 20, color: naranjaFuerte),
              SizedBox(
                width: 80,
                child: Text(
                  reserva['correo'],
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (esNueva)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: verde,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'NUEVO',
                    style: TextStyle(
                      color: blanco,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificacionesPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 8,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: blanco,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                azulElectrico.withOpacity(0.8),
                naranjaFuerte.withOpacity(0.6),
              ],
            ),
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
                      color: blanco,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: blanco),
                    onPressed: () {
                      if (mounted) {
                        setState(() => _mostrarNotificaciones = false);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._nuevasReservas.take(3).map((reserva) => Column(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, color: blanco),
                    title: Text(
                      reserva['nombre']?.toString() ?? 'Sin nombre',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blanco,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${reserva['complejo']?.toString() ?? 'Sin complejo'} - ${reserva['cancha']?.toString() ?? 'Sin cancha'}',
                          style: TextStyle(color: blanco.withOpacity(0.7)),
                        ),
                        Text(
                          '${reserva['fecha']?.toString() ?? 'Sin fecha'} ${reserva['horario']?.toString() ?? 'Sin horario'}',
                          style: TextStyle(color: blanco.withOpacity(0.7)),
                        ),
                        Text(
                          '${reserva['precio']?.toString() ?? 'Sin precio'}',
                          style: TextStyle(color: blanco.withOpacity(0.7)),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: blanco,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NUEVO',
                        style: TextStyle(
                          color: verde,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: blanco.withOpacity(0.3)),
                ],
              )),
              if (_nuevasReservas.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${_nuevasReservas.length - 3} más...',
                    style: TextStyle(
                      color: blanco,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: _limpiarNotificaciones,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blanco,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(
                    'Limpiar notificaciones',
                    style: TextStyle(
                      color: azulElectrico,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white), // Changed text color to white
        ),
        backgroundColor: azulElectrico,
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: rojo,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$_contadorNotificaciones',
                      style: const TextStyle(
                        color: blanco,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: blanco),
            onPressed: _cargarReservasIniciales,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  azulElectrico.withOpacity(0.1),
                  naranjaFuerte.withOpacity(0.05),
                ],
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(naranjaFuerte),
                        ),
                      )
                    : _hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: rojo, size: 50),
                                const SizedBox(height: 20),
                                const Text('Error al cargar reservas', style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _cargarReservasIniciales,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: naranjaFuerte,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  ),
                                  child: const Text('Reintentar', style: TextStyle(color: blanco)),
                                ),
                              ],
                            ),
                          )
                        : _reservas.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today, color: naranjaFuerte.withOpacity(0.5), size: 60),
                                    const SizedBox(height: 20),
                                    Text('No hay reservas registradas', style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 18,
                                    )),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.only(top: _mostrarNotificaciones ? 180 : 0),
                                itemCount: _reservas.length,
                                itemBuilder: (context, index) {
                                  final reserva = _reservas[index];
                                  final esNueva = _nuevasReservas.any((r) => r['id'] == reserva['id']);
                                  return _buildReservaItem(reserva, esNueva);
                                },
                              ),
              ),
            ],
          ),

          if (_mostrarNotificaciones && _nuevasReservas.isNotEmpty)
            _buildNotificacionesPanel(),
        ],
      ),
    );
  }
}

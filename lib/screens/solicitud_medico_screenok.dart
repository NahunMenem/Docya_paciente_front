import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

/// 🔹 Pantalla de confirmación y pago
class SolicitudMedicoScreen extends StatefulWidget {
  final String direccion;
  final LatLng ubicacion;

  const SolicitudMedicoScreen({
    super.key,
    required this.direccion,
    required this.ubicacion,
  });

  @override
  State<SolicitudMedicoScreen> createState() => _SolicitudMedicoScreenState();
}

class _SolicitudMedicoScreenState extends State<SolicitudMedicoScreen> {
  bool aceptaConsentimiento = false;
  final TextEditingController motivoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Confirmar solicitud"),
        backgroundColor: const Color(0xFF11B5B0),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // 📍 Footer con precio + botón
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Precio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Total",
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    SizedBox(height: 2),
                    Text("\$30.000 ARS",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11B5B0))),
                  ],
                ),
              ),

              // Botón Pagar
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF11B5B0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: aceptaConsentimiento
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BuscandoMedicoScreen(
                                direccion: widget.direccion,
                                ubicacion: widget.ubicacion,
                                motivo: motivoCtrl.text, // 👈 PASAMOS MOTIVO
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    "Pagar con MercadoPago",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 📍 Contenido
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Image.asset("assets/logo.png", height: 70),
            ),

            // Card con dirección + motivo + consentimiento
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dirección
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF11B5B0)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(widget.direccion,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Motivo de la consulta
                  const Text(
                    "Motivo de la consulta",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11B5B0)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: motivoCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Ej: fiebre, dolor de garganta...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Declaración jurada
                  const Text(
                    "Declaración Jurada",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11B5B0)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Declaro bajo juramento que he respondido con honestidad las preguntas previas de triage.\n\n"
                    "Entiendo y acepto que DocYa es una plataforma de conexión y no se responsabiliza por el resultado de la atención brindada entre médico y paciente.",
                    style: TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    value: aceptaConsentimiento,
                    onChanged: (val) =>
                        setState(() => aceptaConsentimiento = val ?? false),
                    activeColor: const Color(0xFF11B5B0),
                    title: const Text("Acepto la declaración jurada",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Pantalla estilo Uber buscando médico
class BuscandoMedicoScreen extends StatefulWidget {
  final String direccion;
  final LatLng ubicacion;
  final String motivo; // 👈 AGREGADO

  const BuscandoMedicoScreen({
    super.key,
    required this.direccion,
    required this.ubicacion,
    required this.motivo, // 👈 AGREGADO
  });

  @override
  State<BuscandoMedicoScreen> createState() => _BuscandoMedicoScreenState();
}


class _BuscandoMedicoScreenState extends State<BuscandoMedicoScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController _mapController;
  late AnimationController _animController;

  // 🔹 mismo estilo que en MedicoEnCamino
  final String uberMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [ { "color": "#212121" } ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [ { "visibility": "off" } ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [ { "color": "#757575" } ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [ { "color": "#212121" } ]
    },
    {
      "featureType": "poi",
      "stylers": [ { "visibility": "off" } ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [ { "color": "#2c2c2c" } ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [ { "color": "#3c3c3c" } ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [ { "color": "#000000" } ]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    // Simulación búsqueda
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MedicoEnCaminoScreen(
            direccion: widget.direccion,
            ubicacionPaciente: widget.ubicacion,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF11B5B0),
        foregroundColor: Colors.white,
        title: const Text("Buscando médico"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController.setMapStyle(uberMapStyle); // 👈 aplica estilo negro
            },
            initialCameraPosition:
                CameraPosition(target: widget.ubicacion, zoom: 15),
            markers: {
              Marker(
                markerId: const MarkerId("user"),
                position: widget.ubicacion,
                infoWindow: const InfoWindow(title: "Tu ubicación"),
              ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),
          Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                double size = 100 + (_animController.value * 200);
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF11B5B0)
                        .withOpacity(1 - _animController.value),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset("assets/logo.png", height: 60),
                  const SizedBox(height: 12),
                  const Text(
                    "Buscando un médico disponible...",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// 🔹 Pantalla médico en camino con foto, matrícula, ambulancia 🚑 y ruta azul
class MedicoEnCaminoScreen extends StatefulWidget {
  final String direccion;
  final LatLng ubicacionPaciente;

  const MedicoEnCaminoScreen({
    super.key,
    required this.direccion,
    required this.ubicacionPaciente,
  });

  @override
  State<MedicoEnCaminoScreen> createState() => _MedicoEnCaminoScreenState();
}

class _MedicoEnCaminoScreenState extends State<MedicoEnCaminoScreen> {
  late GoogleMapController _mapController;
  LatLng medicoLocation = const LatLng(-34.6000, -58.4000);
  Timer? _timer;
  double tiempoEstimado = 0;
  BitmapDescriptor? medicoIcon;
  Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  // 🔹 Estilo Uber oscuro
  final String uberMapStyle = '''
  [
    {"elementType": "geometry","stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon","stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill","stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke","stylers": [{"color": "#212121"}]},
    {"featureType": "poi","stylers": [{"visibility": "off"}]},
    {"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "road","elementType": "geometry.stroke","stylers": [{"color": "#3c3c3c"}]},
    {"featureType": "water","elementType": "geometry","stylers": [{"color": "#000000"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _cargarIconoMedico();
    _dibujarRuta();
    _calcularTiempo();

    // 🔹 Simulación de movimiento del médico
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        medicoLocation = LatLng(
          (medicoLocation.latitude + widget.ubicacionPaciente.latitude) / 2,
          (medicoLocation.longitude + widget.ubicacionPaciente.longitude) / 2,
        );
        _dibujarRuta(); // actualizar ruta
        _calcularTiempo();
      });

      if ((medicoLocation.latitude - widget.ubicacionPaciente.latitude).abs() < 0.0005 &&
          (medicoLocation.longitude - widget.ubicacionPaciente.longitude).abs() < 0.0005) {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ El médico llegó a tu domicilio")),
        );
      }
    });
  }

  /// 🔹 Cargar ambulancia como ícono en el mapa
  Future<void> _cargarIconoMedico() async {
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(64, 64)),
      "assets/ambulancia.png", // 🚑 tu asset correcto
    );
    setState(() {
      medicoIcon = icon;
    });
  }

  Future<void> _dibujarRuta() async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${medicoLocation.latitude},${medicoLocation.longitude}"
        "&destination=${widget.ubicacionPaciente.latitude},${widget.ubicacionPaciente.longitude}"
        "&mode=driving&key=AIzaSyClH5_b6XATyG2o9cFj8CKGS1E-bzrFFhU";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data["routes"].isNotEmpty) {
      final puntos = data["routes"][0]["overview_polyline"]["points"];
      final List<PointLatLng> decodedPoints = PolylinePoints().decodePolyline(puntos);

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("ruta"),
            color: const Color(0xFF11B5B0),
            width: 6,
            points: decodedPoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
          ),
        };

        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId("paciente"),
          position: widget.ubicacionPaciente,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "Tu domicilio"),
        ));
        if (medicoIcon != null) {
          _markers.add(Marker(
            markerId: const MarkerId("medico"),
            position: medicoLocation,
            icon: medicoIcon!, // 🚑 ahora usa la ambulancia
            infoWindow: const InfoWindow(title: "Médico en camino"),
          ));
        }
      });
    }
  }

  void _calcularTiempo() {
    double distanciaKm = _haversine(
      medicoLocation.latitude,
      medicoLocation.longitude,
      widget.ubicacionPaciente.latitude,
      widget.ubicacionPaciente.longitude,
    );
    tiempoEstimado = distanciaKm / 0.5; // 0.5 km/min ~ 30 km/h
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  @override
  void dispose() {
    _mapController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int minutos = tiempoEstimado.ceil();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF11B5B0),
        title: const Text("Médico en camino"),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController.setMapStyle(uberMapStyle);
              _ajustarCamara(); // centra médico + paciente
            },
            initialCameraPosition: CameraPosition(
              target: widget.ubicacionPaciente,
              zoom: 16,
            ),
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // 🔹 Card inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage("assets/doctor.jpg"),
                        radius: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dra. Guadalupe Murcia",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text("Matrícula: MP 12345",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text("⏳ Llega en aprox. $minutos min",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("📞 Llamando al médico...")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11B5B0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: const Text(
                        "Contactar",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 Ajusta la cámara para mostrar paciente + médico
  Future<void> _ajustarCamara() async {
    if (_markers.isEmpty) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(medicoLocation.latitude, widget.ubicacionPaciente.latitude),
        min(medicoLocation.longitude, widget.ubicacionPaciente.longitude),
      ),
      northeast: LatLng(
        max(medicoLocation.latitude, widget.ubicacionPaciente.latitude),
        max(medicoLocation.longitude, widget.ubicacionPaciente.longitude),
      ),
    );

    try {
      await _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (e) {
      await _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(widget.ubicacionPaciente, 16),
      );
    }
  }
}

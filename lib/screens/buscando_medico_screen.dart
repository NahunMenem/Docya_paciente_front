import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'MedicoEnCaminoScreen.dart';

class BuscandoMedicoScreen extends StatefulWidget {
  final String direccion;
  final LatLng ubicacion;
  final String motivo;
  final int consultaId; // 👈 ID de la consulta en la DB

  const BuscandoMedicoScreen({
    super.key,
    required this.direccion,
    required this.ubicacion,
    required this.motivo,
    required this.consultaId,
  });

  @override
  State<BuscandoMedicoScreen> createState() => _BuscandoMedicoScreenState();
}

class _BuscandoMedicoScreenState extends State<BuscandoMedicoScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController _mapController;
  late AnimationController _animController;
  Timer? _timer;
  String estadoConsulta = "pendiente";

  final String uberMapStyle = '''
  [
    {"elementType": "geometry","stylers":[{"color":"#212121"}]},
    {"elementType": "labels.icon","stylers":[{"visibility":"off"}]},
    {"elementType": "labels.text.fill","stylers":[{"color":"#757575"}]},
    {"elementType": "labels.text.stroke","stylers":[{"color":"#212121"}]},
    {"featureType": "poi","stylers":[{"visibility":"off"}]},
    {"featureType": "road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
    {"featureType": "road","elementType":"geometry.stroke","stylers":[{"color":"#3c3c3c"}]},
    {"featureType": "water","elementType":"geometry","stylers":[{"color":"#000000"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    // 🔹 Revisar estado cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEstadoConsulta();
    });
  }

  Future<void> _checkEstadoConsulta() async {
    final url = "https://docya-railway-production.up.railway.app/consultas/${widget.consultaId}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          estadoConsulta = data["estado"];
        });

        if (estadoConsulta == "aceptada") {
          _timer?.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MedicoEnCaminoScreen(
                direccion: widget.direccion,
                ubicacionPaciente: widget.ubicacion,
                motivo: widget.motivo,
                medicoId: data["medico_id"],             // ✅ viene del backend
                nombreMedico: data["medico_nombre"] ?? "Médico asignado",
                matricula: data["medico_matricula"] ?? "N/A",
                consultaId: widget.consultaId,
              ),
            ),
          );

        }

      }
    } catch (e) {
      debugPrint("Error consultando estado: $e");
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _animController.dispose();
    _timer?.cancel();
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
          // 🔹 Google Maps
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController.setMapStyle(uberMapStyle);
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

          // 🔹 Animación tipo Uber
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

          // 🔹 Texto + estado arriba
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset("assets/logoblanco.png", height: 60),
                  const SizedBox(height: 12),
                  const Text(
                    "Buscando un médico disponible...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Estado: $estadoConsulta",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
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

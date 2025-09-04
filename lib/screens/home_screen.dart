import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'filtro_medico_screen.dart';
import '../widgets/cards.dart';
import '../widgets/bottom_nav.dart';
import 'perfil_screen.dart'; // <--- Agrega esto si tu archivo se llama así
import 'consultas_screen.dart';
import 'recetas_screen.dart';
 
// 📍 API Key Google
const kGoogleApiKey = "AIzaSyClH5_b6XATyG2o9cFj8CKGS1E-bzrFFhU";

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  final String userId;

  const HomeScreen({super.key, required this.nombreUsuario, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? selectedLocation;
  late GoogleMapController mapController;
  bool cargando = true;
  bool tieneDireccion = false;
  int _selectedIndex = 0;

  TextEditingController direccionCtrl = TextEditingController();
  TextEditingController pisoCtrl = TextEditingController();
  TextEditingController deptoCtrl = TextEditingController();
  TextEditingController indicacionesCtrl = TextEditingController();
  TextEditingController telefonoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDireccionGuardada();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _cargarDireccionGuardada() async {
    final url = Uri.parse(
        "https://docya-railway-production.up.railway.app/direccion/mia/${widget.userId}");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        selectedLocation = LatLng(data["lat"], data["lng"]);
        direccionCtrl.text = data["direccion"] ?? "";
        pisoCtrl.text = data["piso"] ?? "";
        deptoCtrl.text = data["depto"] ?? "";
        indicacionesCtrl.text = data["indicaciones"] ?? "";
        telefonoCtrl.text = data["telefono_contacto"] ?? "";
        tieneDireccion = true;
        cargando = false;
      });
    } else {
      setState(() {
        tieneDireccion = false;
        cargando = false;
      });
    }
  }

  Future<void> guardarDireccion() async {
    if (selectedLocation == null) return;

    final url = Uri.parse(
        "https://docya-railway-production.up.railway.app/direccion/guardar");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.userId,
        "lat": selectedLocation!.latitude,
        "lng": selectedLocation!.longitude,
        "direccion": direccionCtrl.text,
        "piso": pisoCtrl.text,
        "depto": deptoCtrl.text,
        "indicaciones": indicacionesCtrl.text,
        "telefono_contacto": telefonoCtrl.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        tieneDireccion = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Dirección guardada con éxito")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al guardar dirección")),
      );
    }
  }

  // 📍 Vista primera vez → Registrar dirección
  Widget _vistaRegistrarDireccion() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Bienvenido, ${widget.nombreUsuario}",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: direccionCtrl,
            googleAPIKey: kGoogleApiKey,
            debounceTime: 800,
            countries: ["ar"],
            isLatLngRequired: true,
            inputDecoration: InputDecoration(
              hintText: "Buscar dirección...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF11B5B0)),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            getPlaceDetailWithLatLng: (Prediction prediction) {
              if (prediction.lat != null && prediction.lng != null) {
                setState(() {
                  selectedLocation = LatLng(
                    double.parse(prediction.lat!),
                    double.parse(prediction.lng!),
                  );
                });
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(selectedLocation!, 16),
                );
              }
            },
            itemClick: (Prediction prediction) {
              direccionCtrl.text = prediction.description ?? "";
              direccionCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: direccionCtrl.text.length),
              );
            },
          ),
        ),
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: selectedLocation ?? const LatLng(-34.6037, -58.3816),
              zoom: selectedLocation != null ? 16 : 14,
            ),
            onTap: (LatLng pos) {
              setState(() => selectedLocation = pos);
            },
            markers: selectedLocation != null
                ? {Marker(markerId: const MarkerId("sel"), position: selectedLocation!)}
                : {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: pisoCtrl, decoration: const InputDecoration(labelText: "Piso")),
              TextField(controller: deptoCtrl, decoration: const InputDecoration(labelText: "Depto")),
              TextField(controller: indicacionesCtrl, decoration: const InputDecoration(labelText: "Indicaciones")),
              TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: "Teléfono de contacto")),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF11B5B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: guardarDireccion,
                  child: const Text("Guardar dirección",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // 🏠 Vista Home estilo moderno tipo PedidosYa
  Widget _vistaHomePrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📍 Dirección
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF11B5B0)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(direccionCtrl.text,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text("Piso: ${pisoCtrl.text} - Depto: ${deptoCtrl.text}",
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => tieneDireccion = false),
                child: const Text("Cambiar",
                    style: TextStyle(color: Color(0xFF11B5B0))),
              ),
            ],
          ),
        ),

        // 📰 Carrusel de promos
        SizedBox(
          height: 140,
          child: PageView(
            children: [
              promoCard("10% OFF en Farmacias",
                  "Mostrá tu app en farmacias adheridas"),
              promoCard("Consulta + Medicamentos",
                  "Llevate un voucher con descuento"),
              promoCard("Promo Pediatría",
                  "Atención para niños con precio especial"),
            ],
          ),
        ),

        // ℹ️ Noticias
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Noticias de salud",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 10),
              infoCard(
                "💉 Campaña contra el dengue",
                "Ya comenzó la vacunación contra el dengue.\nConsultá a tu médico para más info.",
              ),
              const SizedBox(height: 10),
              infoCard(
                "🩺 Chequeos anuales",
                "No olvides hacerte un control clínico una vez al año.",
              ),
            ],
          ),
        ),

        // 🔹 Servicios
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("¿Qué necesitás hoy?",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              serviceCardHorizontal(context, Icons.local_hospital, "Solicitar Médico",
                  direccionCtrl.text, selectedLocation),
              serviceCardHorizontal(context, Icons.medical_services, "Solicitar Enfermero",
                  direccionCtrl.text, selectedLocation),
            ],
          ),
        ),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  if (cargando) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text("DocYa"),
      backgroundColor: const Color(0xFF11B5B0),
      foregroundColor: Colors.white,
    ),
    body: () {
      // 👇 controlás qué pantalla mostrar según el índice
      if (!tieneDireccion) return _vistaRegistrarDireccion();

      switch (_selectedIndex) {
        case 0:
          return _vistaHomePrincipal();
        case 1:
          return const RecetasScreen();
        case 2:
          return ConsultasScreen(pacienteUuid: widget.userId);


        case 3:
          return PerfilScreen(userId: widget.userId);
        default:
          return _vistaHomePrincipal();
      }
    }(),
    bottomNavigationBar: bottomNav(_selectedIndex, (i) {
      setState(() => _selectedIndex = i);
    }),
  );
 }
}

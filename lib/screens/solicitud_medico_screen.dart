import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'buscando_medico_screen.dart';

// 🔹 Podés guardar el UUID del paciente en un lugar central (ej: SharedPreferences, Provider, etc.)
String pacienteUuidGlobal = "86fdcf96-5bca-494a-9db8-3a2c1201901d"; // ⚠️ Cargarlo dinámicamente desde el login

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

  // 🔹 URL de tu backend FastAPI
  final String apiUrl = "https://docya-railway-production.up.railway.app/consultas/solicitar";

  Future<void> _solicitarConsulta() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "paciente_uuid": pacienteUuidGlobal, // 👈 usamos el UUID del login
          "motivo": motivoCtrl.text,
          "direccion": widget.direccion,
          "lat": widget.ubicacion.latitude,
          "lng": widget.ubicacion.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final consulta = jsonDecode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BuscandoMedicoScreen(
              direccion: widget.direccion,
              ubicacion: widget.ubicacion,
              motivo: motivoCtrl.text,
              consultaId: consulta["consulta_id"], // 👈 pasamos el ID de la consulta creada
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al solicitar médico: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmar solicitud"),
        backgroundColor: const Color(0xFF11B5B0),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,

      // 📍 Botón inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF11B5B0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: aceptaConsentimiento ? _solicitarConsulta : null,
          child: const Text(
            "Pagar con MercadoPago",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),

      // 📍 Contenido
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset("assets/logo.png", height: 100)),
            const SizedBox(height: 20),

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

            // Motivo
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
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              value: aceptaConsentimiento,
              onChanged: (val) =>
                  setState(() => aceptaConsentimiento = val ?? false),
              activeColor: const Color(0xFF11B5B0),
              title: const Text(
                "Acepto la declaración jurada",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}

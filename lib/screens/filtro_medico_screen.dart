import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'solicitud_medico_screen.dart';

class FiltroMedicoScreen extends StatefulWidget {
  final String direccion;
  final LatLng ubicacion;

  const FiltroMedicoScreen({
    super.key,
    required this.direccion,
    required this.ubicacion,
  });

  @override
  State<FiltroMedicoScreen> createState() => _FiltroMedicoScreenState();
}

class _FiltroMedicoScreenState extends State<FiltroMedicoScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, bool?> respuestas = {};
  final List<String> preguntas = [
    "¿Tiene dificultad grave para respirar?",
    "¿Tiene dolor intenso en el pecho?",
    "¿Tiene pérdida de conocimiento o convulsiones?",
    "¿Tiene sangrado abundante o que no se detiene?",
    "¿Tiene fiebre muy alta (más de 39.5 °C) con mal estado general?",
    "¿Se trata de un niño menor de 12 años con fiebre persistente o decaimiento?",
    "¿Tiene un accidente grave, fractura expuesta o quemadura extensa?",
  ];

  void _respuesta(String pregunta, bool valor) {
    setState(() {
      respuestas[pregunta] = valor;
    });
    if (valor == true) _mostrarAlertaUrgencia();
  }

  void _mostrarAlertaUrgencia() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("⚠️ Urgencia detectada"),
        content: const Text(
          "Esto puede ser una urgencia.\n"
          "👉 Llame al 911 o diríjase al hospital más cercano.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          )
        ],
      ),
    );
  }

  bool _todasNo() {
    if (respuestas.length < preguntas.length) return false;
    return respuestas.values.every((v) => v == false);
  }

  @override
  Widget build(BuildContext context) {
    final continuarHabilitado = _todasNo();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Filtro inicial"),
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF14B8A6),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Antes de continuar",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Por favor responde estas preguntas para descartar una urgencia.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: preguntas.length,
              itemBuilder: (_, i) {
                final pregunta = preguntas[i];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.health_and_safety,
                                color: const Color(0xFF14B8A6)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pregunta,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        respuestas[pregunta] == true
                                            ? Colors.red
                                            : Colors.grey[200],
                                    foregroundColor:
                                        respuestas[pregunta] == true
                                            ? Colors.white
                                            : Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => _respuesta(pregunta, true),
                                  child: const Text("Sí",
                                      style: TextStyle(fontSize: 15)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        respuestas[pregunta] == false
                                            ? const Color(0xFF14B8A6)
                                            : Colors.grey[200],
                                    foregroundColor:
                                        respuestas[pregunta] == false
                                            ? Colors.white
                                            : Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => _respuesta(pregunta, false),
                                  child: const Text("No",
                                      style: TextStyle(fontSize: 15)),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: continuarHabilitado
            ? SafeArea(
                key: const ValueKey("continuar"),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SolicitudMedicoScreen(
                            direccion: widget.direccion,
                            ubicacion: widget.ubicacion,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Continuar solicitud",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

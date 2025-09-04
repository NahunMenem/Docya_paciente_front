import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConsultasScreen extends StatefulWidget {
  final String pacienteUuid; // 👈 se lo pasás desde login o perfil

  const ConsultasScreen({super.key, required this.pacienteUuid});

  @override
  State<ConsultasScreen> createState() => _ConsultasScreenState();
}

class _ConsultasScreenState extends State<ConsultasScreen> {
  List<dynamic> consultas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchConsultas();
  }

  Future<void> _fetchConsultas() async {
    final url =
        "https://docya-railway-production.up.railway.app/consultas/historial/${widget.pacienteUuid}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          consultas = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${response.statusCode}: no se pudieron cargar las consultas")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando consultas: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Consultas"),
        backgroundColor: const Color(0xFF11B5B0),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : consultas.isEmpty
              ? const Center(
                  child: Text(
                    "No tenés consultas todavía",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: consultas.length,
                  itemBuilder: (context, index) {
                    final consulta = consultas[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF11B5B0),
                          child: const Icon(Icons.medical_services,
                              color: Colors.white),
                        ),
                        title: Text(
                          "${consulta['medico']['especialidad'] ?? ''} - ${consulta['medico']['nombre'] ?? 'Médico'}",
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Fecha: ${consulta['creado_en']}"),
                            Text("Motivo: ${consulta['motivo']}"),
                          ],
                        ),
                        trailing: Text(
                          consulta['estado'] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: consulta['estado'] == "finalizada"
                                ? Colors.green
                                : consulta['estado'] == "cancelada"
                                    ? Colors.redAccent
                                    : Colors.orange,
                          ),
                        ),
                        onTap: () {
                          // 👇 Detalle de la consulta
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                  "Consulta ${consulta['medico']['especialidad'] ?? ''}"),
                              content: Text(
                                  "Médico: ${consulta['medico']['nombre'] ?? 'N/D'}\n"
                                  "Fecha: ${consulta['creado_en']}\n"
                                  "Motivo: ${consulta['motivo']}\n"
                                  "Estado: ${consulta['estado']}"),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text("Cerrar"))
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

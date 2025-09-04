import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'terminos_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _dni = TextEditingController();
  final _phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _pais;
  String? _provincia;
  String? _localidad;
  DateTime? _fechaNacimiento;
  bool _aceptaCondiciones = false;

  bool _loading = false;
  String? _error;
  final _auth = AuthService();

  // 🌎 Países
  final List<String> _paises = ["Argentina"];

  // 📌 Provincias de Argentina
  final Map<String, List<String>> _provincias = {
    "Argentina": [
      "CABA",
      "Buenos Aires",
      "Catamarca",
      "Chaco",
      "Chubut",
      "Córdoba",
      "Corrientes",
      "Entre Ríos",
      "Formosa",
      "Jujuy",
      "La Pampa",
      "La Rioja",
      "Mendoza",
      "Misiones",
      "Neuquén",
      "Río Negro",
      "Salta",
      "San Juan",
      "San Luis",
      "Santa Cruz",
      "Santa Fe",
      "Santiago del Estero",
      "Tierra del Fuego",
      "Tucumán"
    ]
  };

  // 📍 Localidades principales + barrios de CABA
  final Map<String, List<String>> _localidades = {
    "CABA": [
      "Almagro",
      "Balvanera",
      "Belgrano",
      "Boedo",
      "Caballito",
      "Palermo",
      "Recoleta",
      "Retiro",
      "San Telmo",
      "Villa Urquiza",
      "Villa Devoto",
      "Villa Lugano",
    ],
    "Buenos Aires": ["La Plata", "Mar del Plata", "Bahía Blanca"],
    "Córdoba": ["Córdoba Capital", "Villa Carlos Paz"],
    "Santa Fe": ["Rosario", "Santa Fe Capital"],
    "Mendoza": ["Mendoza Capital", "San Rafael"],
    "La Rioja": ["La Rioja Capital", "Chilecito"],
    "Salta": ["Salta Capital", "Orán"],
  };

  // 🔑 Registro
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pais == null ||
        _provincia == null ||
        _localidad == null ||
        _fechaNacimiento == null ||
        !_aceptaCondiciones) {
      setState(() => _error = "Completa todos los campos y acepta los términos");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final fechaIso = _fechaNacimiento!.toIso8601String().split("T").first;

    final token = await _auth.register(
      _name.text.trim(),
      _email.text.trim(),
      _password.text.trim(),
      dni: _dni.text.trim(),
      telefono: _phone.text.trim(),
      pais: _pais!,
      provincia: _provincia!,
      localidad: _localidad!,
      fechaNacimiento: fechaIso,
      aceptoCondiciones: _aceptaCondiciones,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (token != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. ¡Bienvenido!')),
      );
    } else {
      setState(() => _error = 'No se pudo registrar.');
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF14B8A6)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Crear cuenta"),
        centerTitle: true,
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 6,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset("assets/logo.png", height: 80),
                      const SizedBox(height: 16),
                      const Text(
                        "Regístrate en DocYa",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 24),

                      // Nombre
                      TextFormField(
                        controller: _name,
                        decoration: _inputStyle("Nombre y apellido", Icons.person),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),

                      // DNI
                      TextFormField(
                        controller: _dni,
                        decoration: _inputStyle("DNI / Pasaporte", Icons.badge),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Teléfono
                      TextFormField(
                        controller: _phone,
                        decoration: _inputStyle("Teléfono", Icons.phone_android),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // País
                      DropdownButtonFormField<String>(
                        value: _pais,
                        decoration: _inputStyle("País", Icons.public),
                        items: _paises
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _pais = val;
                            _provincia = null;
                            _localidad = null;
                          });
                        },
                        validator: (v) => v == null ? "Selecciona un país" : null,
                      ),
                      const SizedBox(height: 16),

                      // Provincia
                      if (_pais != null)
                        DropdownButtonFormField<String>(
                          value: _provincia,
                          decoration: _inputStyle("Provincia", Icons.map),
                          items: (_provincias[_pais] ?? [])
                              .map((prov) =>
                                  DropdownMenuItem(value: prov, child: Text(prov)))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _provincia = val;
                              _localidad = null;
                            });
                          },
                          validator: (v) =>
                              v == null ? "Selecciona una provincia" : null,
                        ),
                      if (_pais != null) const SizedBox(height: 16),

                      // Localidad
                      if (_provincia != null)
                        DropdownButtonFormField<String>(
                          value: _localidad,
                          decoration:
                              _inputStyle("Localidad", Icons.location_city),
                          items: (_localidades[_provincia] ?? [])
                              .map((loc) =>
                                  DropdownMenuItem(value: loc, child: Text(loc)))
                              .toList(),
                          onChanged: (val) => setState(() => _localidad = val),
                          validator: (v) =>
                              v == null ? "Selecciona una localidad" : null,
                        ),
                      if (_provincia != null) const SizedBox(height: 16),

                      // Fecha nacimiento
                      TextFormField(
                        readOnly: true,
                        decoration: _inputStyle(
                            "Fecha de nacimiento", Icons.calendar_today),
                        controller: TextEditingController(
                          text: _fechaNacimiento == null
                              ? ""
                              : "${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}",
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            locale: const Locale("es", "ES"),
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _fechaNacimiento = picked;
                            });
                          }
                        },
                        validator: (_) => _fechaNacimiento == null
                            ? "Selecciona tu fecha de nacimiento"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _email,
                        decoration: _inputStyle("Email", Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (!v.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      TextFormField(
                        controller: _password,
                        decoration: _inputStyle("Contraseña", Icons.lock),
                        obscureText: true,
                        validator: (v) =>
                            (v == null || v.length < 6)
                                ? 'Mínimo 6 caracteres'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Confirmar contraseña
                      TextFormField(
                        controller: _confirm,
                        decoration: _inputStyle(
                            "Confirmar contraseña", Icons.check_circle),
                        obscureText: true,
                        validator: (v) =>
                            v != _password.text ? 'No coincide' : null,
                      ),
                      const SizedBox(height: 16),

                      // ✅ Términos y condiciones
                      CheckboxListTile(
                        value: _aceptaCondiciones,
                        activeColor: const Color(0xFF14B8A6),
                        onChanged: (val) {
                          setState(() => _aceptaCondiciones = val ?? false);
                        },
                        title: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Acepto los Términos y Condiciones",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const TerminosScreen()),
                                );
                              },
                              child: const Text(
                                "Ver",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF14B8A6),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14B8A6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Crear cuenta",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("¿Ya tienes cuenta? Inicia sesión"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

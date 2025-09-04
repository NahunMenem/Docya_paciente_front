import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 📌 Screens existentes
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// 📌 Nuevas screens
import 'screens/solicitud_medico_screen.dart';
import 'screens/MedicoEnCaminoScreen.dart'; // 👈 asegúrate de importar tu screen

void main() {
  runApp(const DocYaApp());
}

class DocYaApp extends StatelessWidget {
  const DocYaApp({super.key});

  static const Color primary = Color(0xFF14B8A6); // teal DocYa
  static const Color dark = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocYa',
      theme: ThemeData(
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: dark,
        ),
      ),
      // 🌍 Localización en español
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // 🇪🇸 Español
        Locale('en', ''), // 🇬🇧 Inglés (opcional)
      ],

      // 📌 Ruta inicial
      initialRoute: "/login",

      // 📌 Rutas nombradas
      routes: {
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(
              nombreUsuario: "Usuario",
              userId: "1",
            ),

        // 🔹 Pantallas de flujo de consultas
        "/solicitud": (context) => const SolicitudMedicoScreen(
              direccion: "Av. Santa Fe 1234, Palermo",
              ubicacion: LatLng(-34.6037, -58.3816),
            ),

        "/medico_en_camino": (context) => MedicoEnCaminoScreen(
            direccion: "Av. Rivadavia 1234",
            ubicacionPaciente: const LatLng(-34.6037, -58.3816),
            motivo: "Dolor de cabeza",
            medicoId: 1,
            nombreMedico: "Dr. Juan Pérez",
            matricula: "MP12345",
            consultaId: 10, // 👈 consulta de prueba
          ),

      },
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // URL del backend en Railway
  static const String BASE_URL = 'https://docya-railway-production.up.railway.app';

  // 🔑 Client ID de Google (Android)
  static const String GOOGLE_CLIENT_ID =
      "130001297631-u4ekqs9n0g88b7d574i04qlngmdk7fbq.apps.googleusercontent.com";

  /// Login con email y password
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$BASE_URL/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        return {
          "access_token": data['access_token'],
          "user_id": data['user']['id'].toString(),
          "full_name": data['user']['full_name'],
        };
      }
      return null;
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  /// Registro de usuario
  Future<Map<String, dynamic>?> register(
    String name,
    String email,
    String password, {
    String? dni,
    String? telefono,
    String? pais,
    String? provincia,
    String? localidad,
    String? fechaNacimiento, // ISO8601 (ej: "1990-05-20")
    bool aceptoCondiciones = false,
    String versionTexto = "v1.0",
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$BASE_URL/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': name,
          'email': email,
          'password': password,
          'dni': dni,
          'telefono': telefono,
          'pais': pais,
          'provincia': provincia,
          'localidad': localidad,
          'fecha_nacimiento': fechaNacimiento,
          'acepto_condiciones': aceptoCondiciones,
          'version_texto': versionTexto,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        return {
          "access_token": data['access_token'],
          "user_id": data['user']['id'].toString(),
          "full_name": data['user']['full_name'],
        };
      } else {
        print("Error backend register: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Error en register: $e");
      return null;
    }
  }

  /// Login con Google
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: GOOGLE_CLIENT_ID,
      );

      final account = await googleSignIn.signIn();
      if (account == null) return null; // usuario canceló

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return null;

      final res = await http.post(
        Uri.parse('$BASE_URL/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        return {
          "access_token": data['access_token'],
          "user_id": data['user']['id'].toString(),
          "full_name": data['user']['full_name'],
        };
      } else {
        print("Error backend Google login: ${res.body}");
      }
      return null;
    } catch (e) {
      print("Error en loginWithGoogle: $e");
      return null;
    }
  }
}

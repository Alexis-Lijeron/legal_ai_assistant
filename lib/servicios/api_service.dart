import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../modelos/usuario.dart';

class ApiService {
  static Future<Usuario> registrarUsuario(
    String nombre,
    String correo,
    String contrasena,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "correo": correo,
        "contrasena": contrasena,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al registrar usuario: ${response.body}');
    }
  }

  static Future<TokenData> loginUsuario(
    String correo,
    String contrasena,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"correo": correo, "contrasena": contrasena}),
    );

    if (response.statusCode == 200) {
      return TokenData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }
}

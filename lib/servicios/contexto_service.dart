import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../preferencias/preferencias_usuario.dart';
import '../modelos/contexto.dart';

class ContextoService {
  static Future<Contexto> crearContexto(int idChat, String descripcion) async {
    final token = await PreferenciasUsuario.obtenerToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/contextos/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"id_chat": idChat, "descripcion": descripcion}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Contexto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear contexto: ${response.body}');
    }
  }
}

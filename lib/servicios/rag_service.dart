import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../preferencias/preferencias_usuario.dart';

class RagService {
  static Future<Map<String, dynamic>> buscarRespuesta({
    required String pregunta,
    required int idChat,
    required int idContexto,
    int k = 5,
    List<String> historial = const [],
  }) async {
    final token = await PreferenciasUsuario.obtenerToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/rag/search'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "pregunta": pregunta,
        "k": k,
        "historial": historial,
        "id_chat": idChat,
        "id_contexto": idContexto,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error en la búsqueda RAG: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> buscarRespuestaPublica({
    required String pregunta,
    int k = 5,
    String oldQuestion = "",
    String oldResponse = "",
    List<String> historial = const [],
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/rag/public_search'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "pregunta": pregunta,
        "k": k,
        "old_question": oldQuestion,
        "old_response": oldResponse,
        "historial": historial,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
        'Error en búsqueda pública RAG: ${utf8.decode(response.bodyBytes)}',
      );
    }
  }
}

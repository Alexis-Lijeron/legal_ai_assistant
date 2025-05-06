import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legal_ai_assistant/config/api_config.dart';
import 'package:legal_ai_assistant/preferencias/preferencias_usuario.dart';

class Chat {
  final int idChat;
  final String titulo;

  Chat({required this.idChat, required this.titulo});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(idChat: json['id_chat'], titulo: json['titulo']);
  }
}

class ChatService {
  static Future<Chat> crearChat(String titulo) async {
    final token = await PreferenciasUsuario.obtenerToken();
    if (token == null) {
      throw Exception('Token no encontrado. Debe iniciar sesión.');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chats/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'titulo': titulo}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return Chat.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado (token inválido o expirado).');
    } else {
      throw Exception(
        'Error al crear chat (${response.statusCode}): ${response.body}',
      );
    }
  }
}

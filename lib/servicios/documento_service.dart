import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legal_ai_assistant/config/api_config.dart';

class DocumentoService {
  // Obtener la lista de documentos disponibles
  static Future<List<String>> listarDocumentos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/consulta_txt/documentos'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(data['documentos']);
    } else {
      throw Exception('Error al obtener documentos');
    }
  }

  // Obtener la estructura resumida del documento seleccionado
  static Future<Map<String, dynamic>> obtenerEstructura(
    String documento,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/consulta_txt/estructura_resumida?documento=$documento',
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al obtener la estructura del documento');
    }
  }

  // Buscar contenido según el título, capítulo y artículo
  static Future<String> buscarContenido({
    required String documento,
    String? titulo,
    int? capitulo,
    int? articulo,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/consulta_txt/buscar').replace(
      queryParameters: {
        'documento': documento,
        if (titulo != null) 'titulo': titulo,
        if (capitulo != null) 'capitulo': capitulo.toString(),
        if (articulo != null) 'articulo': articulo.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['resultado'];
    } else {
      throw Exception('Error al buscar contenido');
    }
  }

  static Future<String> buscarConOpenAI({
    required String documento,
    required String consulta,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/consulta_txt/buscar_con_openai',
    ).replace(queryParameters: {'documento': documento, 'consulta': consulta});

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['respuesta'];
    } else {
      throw Exception('Error al consultar con OpenAI');
    }
  }
}

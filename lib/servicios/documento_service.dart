import 'dart:convert';
import 'package:flutter/services.dart';
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

  // Obtener la lista de documentos disponibles localmente
  static Future<List<String>> listarDocumentosOffline() async {
    // Lista de archivos .txt locales
    return [
      '1978-BO-RE-RS187444(1).txt',
      '2006-BO-DS-28710.txt',
      '2010-BO-DS-N420.txt',
      '2011-BO-L-N145.txt',
      '2014-BO-DS-N2079.txt',
      '2017-BO-DS-N3045.txt',
      '2022-BO-DS-N4740.txt',
      '2022-BO-DS-N4780.txt',
      '2022-BO-DS-N4810.txt',
      '2022-BO-DS-N4845.txt',
      'codigo_de_transito.txt',
      'Decreto supremo N 29293.txt',
      'DECRETO SUPREMO N° 27295 DE 20 DE DICIEMBRE DE 2003.txt',
      'RESOLUCION ADMINISTRATIVA N 63 -2006.txt',
    ];
  }

  // Obtener la estructura resumida del documento de manera offline
  static Future<Map<String, dynamic>> obtenerEstructuraOffline(
    String documento,
  ) async {
    try {
      // Cargar el archivo .txt desde los assets
      String contenido = await rootBundle.loadString('assets/$documento');
      List<String> lineas = contenido.split('\n');

      List<String> estructura = [];
      String? tituloActual;
      String? capituloActual;

      // Analizar el contenido del archivo y generar la estructura
      for (String linea in lineas) {
        // Detectar título
        if (linea.toLowerCase().startsWith('titulo')) {
          if (tituloActual != null) {
            estructura.add("  - $tituloActual");
          }
          tituloActual = linea.trim();
        }

        // Detectar capítulo
        if (linea.toLowerCase().startsWith('capitulo')) {
          capituloActual = linea.trim();
        }

        // Detectar artículo
        if (linea.toLowerCase().startsWith('articulo')) {
          estructura.add("    - $capituloActual: $linea");
        }
      }

      // Si hay un título al final, agregarlo
      if (tituloActual != null) {
        estructura.add("  - $tituloActual");
      }

      return {'estructura_resumida': estructura};
    } catch (e) {
      throw Exception('Error al obtener la estructura offline: $e');
    }
  }

  // Buscar contenido de manera offline (Local)
  static Future<String> buscarContenidoOffline({
    required String documento,
    String? titulo,
    int? capitulo,
    int? articulo,
  }) async {
    try {
      // Cargar el archivo .txt desde los assets
      String contenido = await rootBundle.loadString('assets/$documento');
      List<String> lineas = contenido.split('\n');
      String resultado = '';

      // Buscar por título, capítulo y artículo
      if (titulo != null && capitulo != null && articulo != null) {
        String buscarTexto =
            "titulo $titulo capitulo $capitulo articulo $articulo";
        if (contenido.contains(buscarTexto)) {
          resultado = _extraerContenido(contenido, buscarTexto);
        } else {
          return "No se encontró el contenido especificado para título $titulo, capítulo $capitulo, artículo $articulo.";
        }
      } else if (titulo != null && capitulo != null) {
        String buscarTexto = "titulo $titulo capitulo $capitulo";
        if (contenido.contains(buscarTexto)) {
          resultado = _extraerContenido(contenido, buscarTexto);
        } else {
          return "No se encontró el contenido especificado para título $titulo, capítulo $capitulo.";
        }
      } else if (titulo != null) {
        String buscarTexto = "titulo $titulo";
        if (contenido.contains(buscarTexto)) {
          resultado = _extraerContenido(contenido, buscarTexto);
        } else {
          return "No se encontró el título $titulo en el documento.";
        }
      } else {
        return "Consulta inválida.";
      }

      return resultado;
    } catch (e) {
      throw Exception('Error al procesar la consulta offline: $e');
    }
  }

  // Función auxiliar para extraer contenido desde el documento
  static String _extraerContenido(String contenido, String buscarTexto) {
    int index = contenido.indexOf(buscarTexto);
    int endIndex = contenido.indexOf(
      "titulo",
      index + buscarTexto.length,
    ); // Busca el siguiente título
    if (endIndex == -1) {
      endIndex =
          contenido
              .length; // Si no se encuentra el siguiente título, extrae hasta el final
    }
    return contenido.substring(index, endIndex);
  }
}

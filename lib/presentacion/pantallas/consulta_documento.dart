import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:legal_ai_assistant/servicios/documento_service.dart';
import 'package:legal_ai_assistant/presentacion/componentes/barra_lateral.dart';
import 'package:legal_ai_assistant/presentacion/componentes/burbujas_de_mensaje.dart';

class ConsultaDocumentoPantalla extends StatefulWidget {
  const ConsultaDocumentoPantalla({super.key});

  @override
  _ConsultaDocumentoPantallaState createState() =>
      _ConsultaDocumentoPantallaState();
}

class _ConsultaDocumentoPantallaState extends State<ConsultaDocumentoPantalla> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _controladorTexto = TextEditingController();

  bool _cargando = false;
  bool _grabando = false;
  bool _escuchando = false;

  List<String> documentos = [];
  String? documentoSeleccionado;
  Map<String, dynamic>? estructuraDocumento;
  List<Map<String, String>> mensajes = [
    {
      "texto": "📄 Bienvenido, selecciona un documento para comenzar.",
      "tipo": "asistente",
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarDocumentos();
  }

  Future<void> _cargarDocumentos() async {
    try {
      documentos = await DocumentoService.listarDocumentos();
      setState(() {});
    } catch (e) {
      _mostrarError("Error al cargar documentos: $e");
    }
  }

  Future<void> _seleccionarDocumento(String doc) async {
    try {
      documentoSeleccionado = doc;
      estructuraDocumento = await DocumentoService.obtenerEstructura(doc);
      mensajes.add({
        "texto": "📚 Has seleccionado *$doc*.\nPuedes revisar su estructura.",
        "tipo": "asistente",
      });
      setState(() {});
    } catch (e) {
      _mostrarError("Error al obtener estructura: $e");
    }
  }

  void _mostrarError(String texto) {
    setState(() {
      mensajes.add({"texto": "❌ $texto", "tipo": "asistente"});
    });
  }

  Future<void> _leerTexto(String texto) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1.0);
    await flutterTts.stop();
    await flutterTts.speak(texto);
  }

  Future<void> _enviarConsulta() async {
    final texto = _controladorTexto.text.trim();
    if (texto.isEmpty || documentoSeleccionado == null) return;

    setState(() {
      _cargando = true;
      mensajes.add({"texto": texto, "tipo": "persona"});
      _controladorTexto.clear();
    });

    try {
      final respuesta = await DocumentoService.buscarConOpenAI(
        documento: documentoSeleccionado!,
        consulta: texto,
      );
      setState(() {
        mensajes.add({"texto": "📄 $respuesta", "tipo": "asistente"});
        _cargando = false;
      });
      await _leerTexto(respuesta);
    } catch (e) {
      _mostrarError("Error en la consulta: $e");
    }
  }

  Future<void> _iniciarDetenerEscucha() async {
    if (!_escuchando) {
      bool disponible = await _speech.initialize(
        onStatus: (val) {
          if (val == "done") {
            setState(() => _escuchando = false);
          }
        },
        onError: (val) {
          setState(() => _escuchando = false);
        },
      );

      if (disponible) {
        setState(() {
          _escuchando = true;
          _grabando = true;
        });

        _speech.listen(
          localeId: "es_ES",
          onResult: (val) {
            setState(() {
              _controladorTexto.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _escuchando = false;
        _grabando = false;
      });

      _speech.stop();
      await _enviarConsulta();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulta de Documentos"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      drawer: const BarraLateral(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (documentos.isNotEmpty && documentoSeleccionado == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📁 Documentos disponibles:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      for (var doc in documentos)
                        ListTile(
                          title: Text(doc),
                          onTap: () => _seleccionarDocumento(doc),
                        ),
                    ],
                  ),
                if (estructuraDocumento != null) ...[
                  const Text(
                    "📂 Estructura del documento:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (var linea
                      in estructuraDocumento!["estructura_resumida"] as List)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "• $linea",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  const Divider(),
                ],
                for (var mensaje in mensajes)
                  BurbujasDeMensaje(
                    texto: mensaje["texto"]!,
                    tipo: mensaje["tipo"]!,
                  ),
                if (_cargando)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controladorTexto,
                    decoration: const InputDecoration.collapsed(
                      hintText: "Escribe o dicta tu consulta...",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _grabando ? Icons.mic : Icons.mic_none,
                    color: _grabando ? Colors.red : Colors.teal,
                  ),
                  onPressed: _iniciarDetenerEscucha,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _enviarConsulta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

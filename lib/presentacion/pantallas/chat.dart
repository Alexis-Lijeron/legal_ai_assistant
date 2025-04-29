// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:legal_ai_assistant/presentacion/componentes/burbujas_de_mensaje.dart';
import 'package:legal_ai_assistant/presentacion/componentes/barra_lateral.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPantalla extends StatefulWidget {
  const ChatPantalla({super.key});

  @override
  _ChatPantallaState createState() => _ChatPantallaState();
}

class _ChatPantallaState extends State<ChatPantalla> {
  final TextEditingController _controladorTexto = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _cargando = false;
  bool _escuchando = false;
  bool _grabando = false; // Para saber si estamos grabando

  List<Map<String, String>> mensajes = [
    {"texto": "👩‍⚖️ Bienvenido, ¿en qué puedo ayudarte?", "tipo": "asistente"},
  ];
  
  @override
  void dispose() {
    flutterTts.stop();
    _controladorTexto.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    final texto = _controladorTexto.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      mensajes.add({"texto": texto, "tipo": "persona"});
      _cargando = true;
      _controladorTexto.clear();
    });

    try {
      final respuesta = await http.post(
        Uri.parse('https://TU_BACKEND_URL/chat'), // Cambia por tu URL real
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"mensaje": texto}),
      );

      if (respuesta.statusCode == 200) {
        final data = json.decode(respuesta.body);
        final respuestaAsistente = data["respuesta"];

        setState(() {
          mensajes.add({"texto": "👩‍⚖️ $respuestaAsistente", "tipo": "asistente"});
          _cargando = false;
        });

        await _leerTexto(respuestaAsistente);
      } else {
        throw Exception("Error del servidor");
      }
    } catch (e) {
      setState(() {
        mensajes.add({"texto": "👩‍⚖️ Lo siento, hubo un problema de conexión.", "tipo": "asistente"});
        _cargando = false;
      });
    }
  }

  Future<void> _leerTexto(String texto) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1.0);
    await flutterTts.stop();
    await flutterTts.speak(texto);
  }

  // Función para iniciar o detener la grabación
  Future<void> _iniciarDetenerEscucha() async {
    if (!_escuchando) {
      // Iniciamos la grabación
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
          _grabando = true; // Marcamos como grabando
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
      // Detenemos la grabación y enviamos el mensaje
      setState(() {
        _escuchando = false;
        _grabando = false; // Dejamos de grabar
      });

      _speech.stop();
      await _enviarMensaje(); // Enviamos el mensaje después de grabar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Asistente Legal'),
        centerTitle: true,
      ),
      drawer: const BarraLateral(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = mensajes[index];
                return BurbujasDeMensaje(
                  texto: mensaje["texto"]!,
                  tipo: mensaje["tipo"]!,
                );
              },
            ),
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controladorTexto,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Escribe o dicta un mensaje...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      enabled: !_grabando, // Deshabilitamos el campo mientras grabamos
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _grabando ? Icons.mic : Icons.mic_none,
                    color: _grabando ? Colors.red : Colors.blueAccent, // Rojo mientras grabamos
                  ),
                  onPressed: _iniciarDetenerEscucha,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

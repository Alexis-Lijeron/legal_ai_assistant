// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:legal_ai_assistant/config/api_config.dart';
import 'package:legal_ai_assistant/presentacion/componentes/burbujas_de_mensaje.dart';
import 'package:legal_ai_assistant/presentacion/componentes/barra_lateral.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:legal_ai_assistant/servicios/chat_service.dart';
import 'package:legal_ai_assistant/servicios/contexto_service.dart';
import 'package:legal_ai_assistant/servicios/rag_service.dart';
import 'package:legal_ai_assistant/preferencias/preferencias_usuario.dart';
import 'dart:convert';

class ChatPantalla extends StatefulWidget {
  final int? idChat;
  final String? tituloChat;

  const ChatPantalla({super.key, this.idChat, this.tituloChat});

  @override
  _ChatPantallaState createState() => _ChatPantallaState();
}

class _ChatPantallaState extends State<ChatPantalla> {
  final TextEditingController _controladorTexto = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _cargando = false;
  bool _escuchando = false;
  bool _grabando = false;

  List<Map<String, String>> mensajes = [
    {"texto": "👩‍⚖️ Bienvenido, ¿en qué puedo ayudarte?", "tipo": "asistente"},
  ];

  // 🔑 Chat y contexto actuales
  int? idChat;
  int? idContexto;
  List<String> historialLogueado = [];

  // Para detectar si hay usuario logueado
  String? token;

  // 🔥 Para mostrar el título del chat
  String tituloChat = 'Asistente Legal';

  @override
  void initState() {
    super.initState();
    idChat = widget.idChat;
    tituloChat = widget.tituloChat ?? 'Asistente Legal';
    _verificarToken();
  }

  Future<void> _verificarToken() async {
    final tk = await PreferenciasUsuario.obtenerToken();
    setState(() {
      token = tk;
    });

    if (idChat != null) {
      await _cargarMensajesAnteriores();
    }
  }

  Future<void> _cargarMensajesAnteriores() async {
    try {
      final mensajesBackend = await ChatService.obtenerMensajes(idChat!);
      mensajes.clear();
      historialLogueado.clear();

      for (var mensaje in mensajesBackend) {
        mensajes.add({
          "texto": mensaje['contenido'],
          "tipo": mensaje['tipo'] == 'pregunta' ? 'persona' : 'asistente',
        });

        // Solo guardamos en historial si es tipo pregunta/respuesta
        if (mensaje['tipo'] == 'pregunta') {
          historialLogueado.add("Persona: ${mensaje['contenido']}");
        } else {
          historialLogueado.add("Asistente: ${mensaje['contenido']}");
        }
      }

      // Si hay mensajes previos, actualizamos también el idContexto
      if (mensajesBackend.isNotEmpty) {
        idContexto = mensajesBackend.last['id_contexto'];
      }

      setState(() {});
    } catch (e) {
      mensajes.add({
        "texto": "Error al cargar mensajes anteriores: $e",
        "tipo": "asistente",
      });
      setState(() {});
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _controladorTexto.dispose();
    super.dispose();
  }

  String? oldQuestionAnon;
  String? oldResponseAnon;
  List<String> historialAnon = [];

  Future<void> _enviarMensaje() async {
    final texto = _controladorTexto.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      mensajes.add({"texto": texto, "tipo": "persona"});
      _cargando = true;
      _controladorTexto.clear();
    });

    try {
      if (token != null) {
        // ================================
        // 🔥 USUARIO LOGUEADO - Usa el backend completo
        // ================================

        // 1️⃣ Si no existe un chat todavía, crearlo
        if (idChat == null) {
          final titulo = texto.length > 50 ? texto.substring(0, 50) : texto;
          final nuevoChat = await ChatService.crearChat(titulo);
          idChat = nuevoChat.idChat;
          tituloChat = nuevoChat.titulo;
          setState(() {}); // Para actualizar el título del AppBar
        }

        // 2️⃣ Si no existe contexto todavía, crearlo
        if (idContexto == null) {
          final nuevoContexto = await ContextoService.crearContexto(
            idChat!,
            "Primer contexto automático",
          );
          idContexto = nuevoContexto.idContexto;
        }

        // 3️⃣ Enviar la pregunta al servicio RAG
        final resultado = await RagService.buscarRespuesta(
          pregunta: texto,
          idChat: idChat!,
          idContexto: idContexto!,
          historial: historialLogueado,
        );

        final respuestaAsistente = resultado['respuesta'];

        // Guardar en historial (ventana deslizante de hasta 6 líneas = 3 interacciones)
        historialLogueado.add("Persona: $texto");
        historialLogueado.add("Asistente: $respuestaAsistente");
        if (historialLogueado.length > 6) {
          historialLogueado = historialLogueado.sublist(
            historialLogueado.length - 6,
          );
        }

        // Actualizar el contexto si el backend cambió el contexto
        idContexto = resultado['id_contexto_usado'];

        setState(() {
          mensajes.add({
            "texto": "👩‍⚖️ $respuestaAsistente",
            "tipo": "asistente",
          });
          _cargando = false;
        });

        await _leerTexto(respuestaAsistente);
      } else {
        // ================================
        // 🕵️ USUARIO NO LOGUEADO (ANÓNIMO)
        // ================================
        final resultado = await RagService.buscarRespuestaPublica(
          pregunta: texto,
          historial: historialAnon,
        );

        final respuestaAsistente = resultado['respuesta'];

        historialAnon.add("Persona: $texto");
        historialAnon.add("Asistente: $respuestaAsistente");

        setState(() {
          mensajes.add({
            "texto": "👩‍⚖️ $respuestaAsistente",
            "tipo": "asistente",
          });
          _cargando = false;
        });
        await _leerTexto(respuestaAsistente);
      }
    } catch (e) {
      setState(() {
        mensajes.add({
          "texto":
              "👩‍⚖️ Lo siento, hubo un problema de conexión o un error. ($e)",
          "tipo": "asistente",
        });
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
      await _enviarMensaje();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(tituloChat),
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
                      enabled: !_grabando,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _grabando ? Icons.mic : Icons.mic_none,
                    color: _grabando ? Colors.red : Colors.blueAccent,
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

// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BurbujasDeMensaje extends StatefulWidget {
  final String texto;
  final String tipo; // "persona" o "asistente"

  const BurbujasDeMensaje({
    super.key,
    required this.texto,
    required this.tipo,
  });

  @override
  _BurbujasDeMensajeState createState() => _BurbujasDeMensajeState();
}

class _BurbujasDeMensajeState extends State<BurbujasDeMensaje> {
  final FlutterTts _flutterTts = FlutterTts();

   List<String> _palabras = [];
  int _indiceActual = 0;
  bool _pausado = false;

@override
  void initState() {
    super.initState();

    _palabras = widget.texto.split(' ');

    _flutterTts.setProgressHandler((text, start, end, word) {
      if (word.isNotEmpty) {
        setState(() {
          _indiceActual += word.trim().split(' ').length;
        });
      }
    });
  }

   Future<void> _leerMensaje() async {
    if (_pausado) {
      // Si está pausado, continúa desde donde se quedó
      _pausado = false;
      await _leerDesdeIndice();
    } else {
      // Si no, empieza desde el principio
      _indiceActual = 0;
      await _flutterTts.stop();
      await _leerDesdeIndice();
    }
  }

  Future<void> _leerDesdeIndice() async {
    if (_indiceActual >= _palabras.length) return;

    String textoRestante = _palabras.sublist(_indiceActual).join(' ');
    await _flutterTts.speak(textoRestante);
  }

  Future<void> _pausarLectura() async {
    await _flutterTts.pause();
    setState(() {
      _pausado = true;
    });
  }

  Future<void> _reiniciarLectura() async {
    _indiceActual = 0;
    _pausado = false;
    await _flutterTts.stop();
    await _leerDesdeIndice();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esAsistente = widget.tipo == "asistente";

    return Align(
      alignment: esAsistente ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: esAsistente ? Colors.grey[300] : Colors.blueAccent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.texto,
              style: TextStyle(
                color: esAsistente ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (esAsistente)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      color: Colors.blue,
                      onPressed: _leerMensaje,
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause),
                      color: Colors.orange,
                      onPressed: _pausarLectura,
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay),
                      color: Colors.green,
                      onPressed: _reiniciarLectura,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

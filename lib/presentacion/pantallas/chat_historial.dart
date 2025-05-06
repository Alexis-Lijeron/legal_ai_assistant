import 'package:flutter/material.dart';
import 'package:legal_ai_assistant/servicios/chat_service.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/chat.dart';
import 'package:legal_ai_assistant/presentacion/componentes/barra_lateral.dart';

class ChatHistorialPantalla extends StatefulWidget {
  const ChatHistorialPantalla({super.key});

  @override
  State<ChatHistorialPantalla> createState() => _ChatHistorialPantallaState();
}

class _ChatHistorialPantallaState extends State<ChatHistorialPantalla> {
  List<Map<String, dynamic>> chats = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarChats();
  }

  Future<void> cargarChats() async {
    try {
      final listaChats = await ChatService.obtenerChats();
      setState(() {
        chats = listaChats;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar chats: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Chats'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: const BarraLateral(),
      body:
          cargando
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ListTile(
                    title: Text(chat['titulo']),
                    subtitle: Text('ID: ${chat['id_chat']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatPantalla(
                                // ✅ Forzar que el idChat sea entero
                                idChat: int.parse(chat['id_chat'].toString()),
                                tituloChat: chat['titulo'],
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

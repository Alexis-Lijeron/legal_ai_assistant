import 'package:flutter/material.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/ajustes_pantalla.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/consulta_documento.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/login_pantalla.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/chat_historial.dart';
import 'package:legal_ai_assistant/preferencias/preferencias_usuario.dart';

class BarraLateral extends StatefulWidget {
  const BarraLateral({super.key});

  @override
  _BarraLateralState createState() => _BarraLateralState();
}

class _BarraLateralState extends State<BarraLateral> {
  String? token;

  @override
  void initState() {
    super.initState();
    cargarToken();
  }

  void cargarToken() async {
    String? tokenGuardado = await PreferenciasUsuario.obtenerToken();
    setState(() {
      token = tokenGuardado;
    });
  }

  void cerrarSesion() async {
    await PreferenciasUsuario.eliminarToken();
    setState(() {
      token = null;
    });
    Navigator.of(context).pop(); // Cierra el Drawer
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text(
              'Chat Legal AI',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // Chat siempre disponible
          ListTile(
            title: const Text('Chat nuevo'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
            },
          ),

          // Documentos y Historial solo si hay sesión iniciada
          if (token != null) ...[
            ListTile(
              title: const Text('Documentos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConsultaDocumentoPantalla(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Historial de chats'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatHistorialPantalla(),
                  ),
                );
              },
            ),
          ],

          // Ajustes siempre disponible
          ListTile(
            title: const Text('Ajustes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AjustesPantalla(),
                ),
              );
            },
          ),

          const Divider(),

          if (token == null)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Iniciar Sesión'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPantalla()),
                ).then((_) => cargarToken());
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: cerrarSesion,
            ),
        ],
      ),
    );
  }
}

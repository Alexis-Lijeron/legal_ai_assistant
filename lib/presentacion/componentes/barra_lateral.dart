import 'package:flutter/material.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/ajustes_pantalla.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/login_pantalla.dart';
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
    ).showSnackBar(SnackBar(content: Text('Sesión cerrada')));
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
            title: const Text('Chat'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
            },
          ),

          // Documentos y Historial solo si hay sesión iniciada
          if (token != null) ...[
            ListTile(
              title: const Text('Documentos'),
              onTap: () {
                // Navegar a Documentos (por ahora puede ser un print o Navigator)
                print('Ir a Documentos');
              },
            ),
            ListTile(
              title: const Text('Historial'),
              onTap: () {
                // Navegar a Historial
                print('Ir a Historial');
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

          // Mostrar "Iniciar Sesión" o "Cerrar Sesión" según el estado
          if (token == null)
            ListTile(
              leading: Icon(Icons.login),
              title: const Text('Iniciar Sesión'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPantalla()),
                ).then((_) {
                  // Cuando vuelva del login, recargar token
                  cargarToken();
                });
              },
            )
          else
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: cerrarSesion,
            ),
        ],
      ),
    );
  }
}

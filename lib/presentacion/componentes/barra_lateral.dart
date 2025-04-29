import 'package:flutter/material.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/ajustes_pantalla.dart';

class BarraLateral extends StatelessWidget {
  const BarraLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Chat Legal AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Documentos'),
            onTap: () {
              // Navegar a la pantalla de historial
            },
          ),
          ListTile(
            title: const Text('Historial'),
            onTap: () {
              // Navegar a la pantalla de perfil
            },
          ),
          ListTile(
            title: const Text('Ajustes'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)
              => const AjustesPantalla()),
              );
            },
          ),
        ],
      ),
    );
  }
}

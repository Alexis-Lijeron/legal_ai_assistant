import 'package:flutter/material.dart';
import 'package:legal_ai_assistant/modelos/usuario.dart';
import 'package:legal_ai_assistant/servicios/api_service.dart';

class RegistroPantalla extends StatefulWidget {
  @override
  _RegistroPantallaState createState() => _RegistroPantallaState();
}

class _RegistroPantallaState extends State<RegistroPantalla> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  String mensaje = '';

  void registrar() async {
    try {
      Usuario usuario = await ApiService.registrarUsuario(
        nombreController.text.trim(),
        correoController.text.trim(),
        contrasenaController.text.trim(),
      );

      setState(() {
        mensaje = "Usuario registrado: ${usuario.nombre}";
      });
    } catch (e) {
      setState(() {
        mensaje = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: correoController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: contrasenaController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: registrar, child: Text("Registrar")),
            SizedBox(height: 20),
            Text(mensaje),
          ],
        ),
      ),
    );
  }
}

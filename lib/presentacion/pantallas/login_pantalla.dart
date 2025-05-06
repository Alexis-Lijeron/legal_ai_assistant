import 'package:flutter/material.dart';
import 'package:legal_ai_assistant/servicios/api_service.dart';
import 'package:legal_ai_assistant/preferencias/preferencias_usuario.dart';
import 'package:legal_ai_assistant/presentacion/pantallas/registro_pantalla.dart';

class LoginPantalla extends StatefulWidget {
  @override
  _LoginPantallaState createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  String mensaje = '';

  void login() async {
    try {
      var tokenData = await ApiService.loginUsuario(
        correoController.text.trim(),
        contrasenaController.text.trim(),
      );

      // Guardamos el token
      await PreferenciasUsuario.guardarToken(tokenData.accessToken);

      setState(() {
        mensaje = "Bienvenido ${tokenData.nombre}";
      });

      print("Token: ${tokenData.accessToken}");

      // Después de login puedes volver atrás o navegar a la pantalla principal
      Navigator.pop(context); // Cierra el login y vuelve
    } catch (e) {
      setState(() {
        mensaje = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            ElevatedButton(onPressed: login, child: Text("Iniciar sesión")),
            SizedBox(height: 20),
            Text(mensaje),

            // Enlace para registrarse
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroPantalla()),
                ).then((_) {
                  // Al volver del registro puedes refrescar si deseas
                  setState(() {}); // Solo refresca el estado actual
                });
              },
              child: Text("¿No tienes cuenta? Regístrate"),
            ),
          ],
        ),
      ),
    );
  }
}

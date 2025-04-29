import 'package:flutter/material.dart';

class AjustesPantalla extends StatefulWidget {
  const AjustesPantalla({super.key});

  @override
  _AjustesPantallaState createState() => _AjustesPantallaState();
}

class _AjustesPantallaState extends State<AjustesPantalla> {
  // Variables para la configuración
  String? _vozSeleccionada = 'Voz Masculina';
  double _velocidadVoz = 1.0;
  double _tonoVoz = 1.0;
  String? _idiomaSeleccionado = 'Español';

  // Opciones para voz
  List<String> _opcionesVoz = ['Voz Masculina', 'Voz Femenina', 'Voz Neutra'];

  // Opciones para idioma
  List<String> _opcionesIdioma = ['Español', 'Inglés', 'Francés'];

  // Guardar configuración
  void _guardarConfiguracion() {
    // Aquí puedes guardar la configuración, por ejemplo, en un archivo o base de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes del Asistente'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Configuración de voz
            const Text(
              'Configuración de Voz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _vozSeleccionada,
              items: _opcionesVoz.map((String opcion) {
                return DropdownMenuItem<String>(
                  value: opcion,
                  child: Text(opcion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _vozSeleccionada = value;
                });
              },
              isExpanded: true,
              hint: const Text('Selecciona una voz'),
            ),
            const SizedBox(height: 20),

            // Ajuste de velocidad de la voz
            const Text(
              'Velocidad de la Voz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _velocidadVoz,
              min: 0.5,
              max: 2.0,
              divisions: 3,
              label: '${_velocidadVoz.toStringAsFixed(1)}x',
              onChanged: (double value) {
                setState(() {
                  _velocidadVoz = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Ajuste del tono de la voz
            const Text(
              'Tono de la Voz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _tonoVoz,
              min: 0.5,
              max: 2.0,
              divisions: 3,
              label: '${_tonoVoz.toStringAsFixed(1)}x',
              onChanged: (double value) {
                setState(() {
                  _tonoVoz = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Configuración de idioma
            const Text(
              'Idioma del Asistente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _idiomaSeleccionado,
              items: _opcionesIdioma.map((String opcion) {
                return DropdownMenuItem<String>(
                  value: opcion,
                  child: Text(opcion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _idiomaSeleccionado = value;
                });
              },
              isExpanded: true,
              hint: const Text('Selecciona un idioma'),
            ),
            const SizedBox(height: 30),

            // Botón para guardar los cambios
            ElevatedButton(
              onPressed: _guardarConfiguracion,
              child: const Text('Guardar Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}


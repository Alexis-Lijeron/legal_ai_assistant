import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> guardarNombreUsuario(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', nombre);
  }

  static Future<String?> obtenerNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre');
  }

  static Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> eliminarToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}

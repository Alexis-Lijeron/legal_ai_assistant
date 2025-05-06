class Mensaje {
  final int idMensaje;
  final int idChat;
  final int? idContexto;
  final String tipo;
  final String contenido;
  final DateTime fecha;

  Mensaje({
    required this.idMensaje,
    required this.idChat,
    this.idContexto,
    required this.tipo,
    required this.contenido,
    required this.fecha,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      idMensaje: json['id_mensaje'],
      idChat: json['id_chat'],
      idContexto: json['id_contexto'],
      tipo: json['tipo'],
      contenido: json['contenido'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

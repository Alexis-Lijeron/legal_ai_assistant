class Chat {
  final int idChat;
  final int idUsuario;
  final String titulo;
  final DateTime fechaInicio;

  Chat({
    required this.idChat,
    required this.idUsuario,
    required this.titulo,
    required this.fechaInicio,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      idChat: json['id_chat'],
      idUsuario: json['id_usuario'],
      titulo: json['titulo'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
    );
  }
}

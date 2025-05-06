class Contexto {
  final int idContexto;
  final int idChat;
  final int contextoNumero;
  final String descripcion;
  final DateTime fechaInicio;

  Contexto({
    required this.idContexto,
    required this.idChat,
    required this.contextoNumero,
    required this.descripcion,
    required this.fechaInicio,
  });

  factory Contexto.fromJson(Map<String, dynamic> json) {
    return Contexto(
      idContexto: json['id_contexto'],
      idChat: json['id_chat'],
      contextoNumero: json['contexto_numero'],
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
    );
  }
}

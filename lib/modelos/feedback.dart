class FeedbackModelo {
  final int idFeedback;
  final int idMensaje;
  final int puntuacion;
  final String comentario;
  final DateTime fecha;

  FeedbackModelo({
    required this.idFeedback,
    required this.idMensaje,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
  });

  factory FeedbackModelo.fromJson(Map<String, dynamic> json) {
    return FeedbackModelo(
      idFeedback: json['id_feedback'],
      idMensaje: json['id_mensaje'],
      puntuacion: json['puntuacion'],
      comentario: json['comentario'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

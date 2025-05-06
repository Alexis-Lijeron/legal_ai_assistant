class Usuario {
  final int idUsuario;
  final String nombre;
  final String correo;
  final DateTime fechaRegistro;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.fechaRegistro,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      correo: json['correo'],
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }
}

class TokenData {
  final String accessToken;
  final String tokenType;
  final int idUsuario;
  final String nombre;
  final String correo;

  TokenData({
    required this.accessToken,
    required this.tokenType,
    required this.idUsuario,
    required this.nombre,
    required this.correo,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      correo: json['correo'],
    );
  }
}

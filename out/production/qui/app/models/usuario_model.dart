class Usuario {
  final int id;
  final String nome;
  final String enderecoPrincipal;
  final double latitude;
  final double longitude;

  Usuario({
    required this.id,
    required this.nome,
    required this.enderecoPrincipal,
    required this.latitude,
    required this.longitude,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      enderecoPrincipal: json['enderecoPrincipal'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'enderecoPrincipal': enderecoPrincipal,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

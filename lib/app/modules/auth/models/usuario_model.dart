class UsuarioModel {
  final int id;
  final String nome;
  final String? email;
  final String? avatar;
  final String? whatsapp;

  UsuarioModel({
    required this.id,
    required this.nome,
    this.email,
    this.avatar,
    this.whatsapp,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
      nome: json['nome'] ?? json['username'] ?? '',
      email: json['email'],
      avatar: json['avatar'],
      whatsapp: json['whatsapp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'avatar': avatar,
      'whatsapp': whatsapp,
    };
  }
}

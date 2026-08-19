class UsuarioModel {
  final int id;
  final String nome;
  final String? email;
  final String? telefone;
  final String? whatsapp;
  final String? status;
  final String? avatar;
  final bool telefoneVerificado; // ✅ NOVO

  UsuarioModel({
    required this.id,
    required this.nome,
    this.email,
    this.telefone,
    this.whatsapp,
    this.status,
    this.avatar,
    this.telefoneVerificado = false, // ✅ Padrão false
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
      nome: json['nome'] ?? json['username'] ?? '',
      email: json['email'],
      telefone: json['telefone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      status: json['status']?.toString(),
      avatar: json['avatar'],
      // ✅ Parse do campo telefone_verificado
      telefoneVerificado: json['telefone_verificado'] == true ||
          json['telefone_verificado'] == 1 ||
          json['telefone_verificado'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'whatsapp': whatsapp,
      'status': status,
      'avatar': avatar,
      'telefone_verificado': telefoneVerificado, // ✅ NOVO
    };
  }

  UsuarioModel copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    String? whatsapp,
    String? status,
    String? avatar,
    bool? telefoneVerificado, // ✅ NOVO
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      whatsapp: whatsapp ?? this.whatsapp,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      telefoneVerificado: telefoneVerificado ?? this.telefoneVerificado, // ✅
    );
  }
}
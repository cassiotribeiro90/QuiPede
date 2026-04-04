class BannerModel {
  final int id;
  final String imagemUrl;
  final String? titulo;
  final String? descricao;
  final String tipo; // "promocao", "loja", "link_externo"
  final int? lojaId;
  final Map<String, dynamic> acao;

  BannerModel({
    required this.id,
    required this.imagemUrl,
    this.titulo,
    this.descricao,
    required this.tipo,
    this.lojaId,
    required this.acao,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      imagemUrl: json['imagemUrl'] as String,
      titulo: json['titulo'] as String?,
      descricao: json['descricao'] as String?,
      tipo: json['tipo'] as String,
      lojaId: json['lojaId'] as int?,
      acao: Map<String, dynamic>.from(json['acao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagemUrl': imagemUrl,
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo,
      'lojaId': lojaId,
      'acao': acao,
    };
  }
}

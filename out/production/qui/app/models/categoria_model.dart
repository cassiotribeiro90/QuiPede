class Categoria {
  final int id;
  final String nome;
  final String icone; // Pode ser um emoji ou um código para um IconData
  final String? imagemUrl;
  final String cor; // Hex code for color, e.g., "#FF5733"

  Categoria({
    required this.id,
    required this.nome,
    required this.icone,
    this.imagemUrl,
    required this.cor,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as int,
      nome: json['nome'] as String,
      icone: json['icone'] as String,
      imagemUrl: json['imagemUrl'] as String?,
      cor: json['cor'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'icone': icone,
      'imagemUrl': imagemUrl,
      'cor': cor,
    };
  }
}

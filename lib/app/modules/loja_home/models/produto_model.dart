import 'package:equatable/equatable.dart';

class ProdutoModel extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final double preco;
  final double? precoPromocional;
  final String? imagem;
  final int tempoPreparo;
  final bool disponivel;
  final bool destaque;
  final double notaMedia;

  const ProdutoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    this.precoPromocional,
    this.imagem,
    required this.tempoPreparo,
    required this.disponivel,
    required this.destaque,
    required this.notaMedia,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      preco: (json['preco'] as num).toDouble(),
      precoPromocional: json['preco_promocional'] != null 
          ? (json['preco_promocional'] as num).toDouble() 
          : null,
      imagem: json['imagem'] as String?,
      tempoPreparo: json['tempo_preparo'] as int? ?? 0,
      disponivel: json['disponivel'] == true || json['disponivel'] == 1,
      destaque: json['destaque'] == true || json['destaque'] == 1,
      notaMedia: (json['nota_media'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        descricao,
        preco,
        precoPromocional,
        imagem,
        tempoPreparo,
        disponivel,
        destaque,
        notaMedia,
      ];
}

import 'package:equatable/equatable.dart';

class ProdutoModel extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final double preco;
  final double? precoPromocional;
  final String? imagem;
  final int? tempoPreparo;
  final bool disponivel;
  final bool destaque;
  final int vendasHoje;
  final double notaMedia;
  final int totalAvaliacoes;
  final int? subcategoriaId;
  final String? subcategoriaNome;

  const ProdutoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    this.precoPromocional,
    this.imagem,
    this.tempoPreparo,
    required this.disponivel,
    required this.destaque,
    required this.vendasHoje,
    required this.notaMedia,
    required this.totalAvaliacoes,
    this.subcategoriaId,
    this.subcategoriaNome,
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
      tempoPreparo: (json['tempo_preparo'] ?? json['tempo_preparo_min']) as int?,
      disponivel: json['disponivel'] == 1 || json['disponivel'] == true,
      destaque: json['destaque'] == 1 || json['destaque'] == true,
      vendasHoje: (json['vendas_hoje'] ?? 0) as int,
      notaMedia: (json['nota_media'] as num? ?? 0).toDouble(),
      totalAvaliacoes: (json['total_avaliacoes'] ?? 0) as int,
      subcategoriaId: json['subcategoria_id'] as int?,
      subcategoriaNome: json['subcategoria_nome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'preco_promocional': precoPromocional,
      'imagem': imagem,
      'tempo_preparo': tempoPreparo,
      'disponivel': disponivel,
      'destaque': destaque,
      'vendas_hoje': vendasHoje,
      'nota_media': notaMedia,
      'total_avaliacoes': totalAvaliacoes,
      'subcategoria_id': subcategoriaId,
      'subcategoria_nome': subcategoriaNome,
    };
  }

  double get precoAtual => precoPromocional ?? preco;
  String get precoFormatado => 'R\$ ${precoAtual.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  List<Object?> get props => [
        id, nome, descricao, preco, precoPromocional, imagem,
        tempoPreparo, disponivel, destaque, vendasHoje, notaMedia,
        totalAvaliacoes, subcategoriaId, subcategoriaNome,
      ];
}

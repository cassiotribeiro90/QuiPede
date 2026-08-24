import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class CarrinhoItem extends Equatable {
  final int id;
  final int produtoId;
  final int? lojaId;
  final String? lojaNome;
  final String nome;
  final String? descricao;
  final String? imagem;
  final int quantidade;
  final double precoUnitario;
  final double precoAdicionais;
  final double precoTotal;
  final List<dynamic> opcoes;
  final List<dynamic> opcoesDetalhes;
  final String? observacao;
  final dynamic metadata;

  const CarrinhoItem({
    required this.id,
    required this.produtoId,
    this.lojaId,
    this.lojaNome,
    required this.nome,
    this.descricao,
    this.imagem,
    required this.quantidade,
    required this.precoUnitario,
    required this.precoAdicionais,
    required this.precoTotal,
    this.opcoes = const [],
    this.opcoesDetalhes = const [],
    this.observacao,
    this.metadata,
  });

  CarrinhoItem copyWith({
    int? id,
    int? produtoId,
    int? lojaId,
    String? lojaNome,
    String? nome,
    String? descricao,
    String? imagem,
    int? quantidade,
    double? precoUnitario,
    double? precoAdicionais,
    double? precoTotal,
    List<dynamic>? opcoes,
    List<dynamic>? opcoesDetalhes,
    String? observacao,
    dynamic metadata,
  }) {
    return CarrinhoItem(
      id: id ?? this.id,
      produtoId: produtoId ?? this.produtoId,
      lojaId: lojaId ?? this.lojaId,
      lojaNome: lojaNome ?? this.lojaNome,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      imagem: imagem ?? this.imagem,
      quantidade: quantidade ?? this.quantidade,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      precoAdicionais: precoAdicionais ?? this.precoAdicionais,
      precoTotal: precoTotal ?? this.precoTotal,
      opcoes: opcoes ?? this.opcoes,
      opcoesDetalhes: opcoesDetalhes ?? this.opcoesDetalhes,
      observacao: observacao ?? this.observacao,
      metadata: metadata ?? this.metadata,
    );
  }

  factory CarrinhoItem.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) debugPrint('🔍 CarrinhoItem.fromJson: \$json');

    return CarrinhoItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      produtoId: int.tryParse(json['produto_id']?.toString() ?? '0') ?? 0,
      lojaId: int.tryParse(json['loja_id']?.toString() ?? ''),
      lojaNome: json['loja_nome']?.toString(),
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      imagem: json['imagem']?.toString(),
      quantidade: int.tryParse(json['quantidade']?.toString() ?? '1') ?? 1,
      precoUnitario: double.tryParse(json['preco_unitario']?.toString() ?? '0') ?? 0.0,
      precoAdicionais: double.tryParse(json['preco_adicionais']?.toString() ?? '0') ?? 0.0,
      precoTotal: double.tryParse(json['preco_total']?.toString() ?? '0') ?? 0.0,
      opcoes: json['opcoes'] as List? ?? [],
      opcoesDetalhes: json['opcoes_detalhes'] as List? ?? [],
      observacao: json['observacao']?.toString(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produto_id': produtoId,
      'loja_id': lojaId,
      'loja_nome': lojaNome,
      'nome': nome,
      'descricao': descricao,
      'imagem': imagem,
      'quantidade': quantidade,
      'preco_unitario': precoUnitario,
      'preco_adicionais': precoAdicionais,
      'preco_total': precoTotal,
      'opcoes': opcoes,
      'opcoes_detalhes': opcoesDetalhes,
      'observacao': observacao,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        produtoId,
        lojaId,
        lojaNome,
        nome,
        descricao,
        imagem,
        quantidade,
        precoUnitario,
        precoAdicionais,
        precoTotal,
        opcoes,
        opcoesDetalhes,
        observacao,
        metadata
      ];
}

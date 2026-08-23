import 'package:equatable/equatable.dart';
import 'produto_model.dart';

class SecaoModel extends Equatable {
  final int id;
  final String nome;
  final String? icone;
  final int ordem;
  final int totalProdutos;
  final List<ProdutoModel> produtos;
  final bool isLoadingMore;

  const SecaoModel({
    required this.id,
    required this.nome,
    this.icone,
    required this.ordem,
    required this.totalProdutos,
    required this.produtos,
    this.isLoadingMore = false,
  });

  bool get hasMore => produtos.length < totalProdutos;

  factory SecaoModel.fromJson(Map<String, dynamic> json) {
    return SecaoModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      icone: json['icone'] as String?,
      ordem: json['ordem'] as int? ?? 0,
      totalProdutos: (json['total_produtos'] ?? json['totalProdutos'] ?? 0) as int,
      produtos: (json['produtos'] as List? ?? [])
          .map((e) => ProdutoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  SecaoModel copyWith({
    int? id,
    String? nome,
    String? icone,
    int? ordem,
    int? totalProdutos,
    List<ProdutoModel>? produtos,
    bool? isLoadingMore,
  }) {
    return SecaoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      icone: icone ?? this.icone,
      ordem: ordem ?? this.ordem,
      totalProdutos: totalProdutos ?? this.totalProdutos,
      produtos: produtos ?? this.produtos,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        icone,
        ordem,
        totalProdutos,
        produtos,
        isLoadingMore,
      ];
}

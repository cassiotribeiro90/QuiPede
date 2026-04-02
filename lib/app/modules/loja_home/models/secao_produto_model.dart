import 'package:equatable/equatable.dart';
import 'produto_model.dart';

class SecaoProdutoModel extends Equatable {
  final int id;
  final String nome;
  final String? icone;
  final int ordem;
  final List<ProdutoModel> produtos;

  const SecaoProdutoModel({
    required this.id,
    required this.nome,
    this.icone,
    required this.ordem,
    required this.produtos,
  });

  factory SecaoProdutoModel.fromJson(Map<String, dynamic> json) {
    return SecaoProdutoModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      icone: json['icone'] as String?,
      ordem: json['ordem'] as int? ?? 0,
      produtos: (json['produtos'] as List? ?? [])
          .map((e) => ProdutoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, nome, icone, ordem, produtos];
}

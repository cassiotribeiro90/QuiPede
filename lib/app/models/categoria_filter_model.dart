import 'package:equatable/equatable.dart';

class CategoriaFilterModel extends Equatable {
  final int id;
  final String nome;
  final String? icone;
  final int totalProdutos;

  const CategoriaFilterModel({
    required this.id,
    required this.nome,
    this.icone,
    required this.totalProdutos,
  });

  factory CategoriaFilterModel.fromJson(Map<String, dynamic> json) {
    return CategoriaFilterModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      icone: json['icone'] as String?,
      totalProdutos: (json['total_produtos'] ?? json['totalProdutos'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'icone': icone,
      'total_produtos': totalProdutos,
    };
  }

  @override
  List<Object?> get props => [id, nome, icone, totalProdutos];
}

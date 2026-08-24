import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'carrinho_item.dart';

class CarrinhoResponse extends Equatable {
  final String? mensagem;
  final List<CarrinhoItem> itens;
  final CarrinhoResumo resumo;

  const CarrinhoResponse({
    this.mensagem,
    required this.itens,
    required this.resumo,
  });

  factory CarrinhoResponse.fromJson(dynamic json) {
    if (kDebugMode) debugPrint('🔍 Parsing CarrinhoResponse: $json');
    
    // Se o json vier como uma lista (ex: carrinho vazio vindo do backend como []), 
    // tratamos como um objeto vazio para evitar erro de cast.
    final Map<String, dynamic> data = (json is Map) ? Map<String, dynamic>.from(json) : {};
    
    return CarrinhoResponse(
      mensagem: data['mensagem']?.toString(),
      itens: (data['itens'] is List)
          ? (data['itens'] as List)
              .map((e) => CarrinhoItem.fromJson(e))
              .toList()
          : [],
      resumo: CarrinhoResumo.fromJson(data['resumo']),
    );
  }

  @override
  List<Object?> get props => [mensagem, itens, resumo];
}

class CarrinhoResumo extends Equatable {
  final int totalItens;
  final double subtotal;
  final int? lojaId;
  final String? lojaNome;
  final double? taxaEntrega;
  final double? total;
  final double? distanciaKm;
  final Map<String, dynamic> formasPagamento;

  const CarrinhoResumo({
    required this.totalItens,
    required this.subtotal,
    this.lojaId,
    this.lojaNome,
    this.taxaEntrega,
    this.total,
    this.distanciaKm,
    this.formasPagamento = const {},
  });

  factory CarrinhoResumo.fromJson(dynamic json) {
    final data = (json is Map) ? Map<String, dynamic>.from(json) : <String, dynamic>{};
    
    return CarrinhoResumo(
      totalItens: int.tryParse(data['total_itens']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(data['subtotal']?.toString() ?? '0') ?? 0.0,
      lojaId: int.tryParse(data['loja_id']?.toString() ?? ''),
      lojaNome: data['loja_nome']?.toString(),
      taxaEntrega: double.tryParse(data['taxa_entrega']?.toString() ?? ''),
      total: double.tryParse(data['total']?.toString() ?? ''),
      distanciaKm: double.tryParse(data['distancia_km']?.toString() ?? ''),
      formasPagamento: (data['formas_pagamento'] is Map) 
          ? Map<String, dynamic>.from(data['formas_pagamento'])
          : {},
    );
  }

  /// Retorna as chaves das formas de pagamento disponíveis
  List<String> get formasDisponiveis => formasPagamento.keys.toList();
  
  /// Retorna o label de uma forma de pagamento
  String getLabel(String forma) {
    return formasPagamento[forma]?['label'] ?? forma;
  }

  @override
  List<Object?> get props => [
    totalItens, subtotal, lojaId, lojaNome, 
    taxaEntrega, total, distanciaKm, formasPagamento
  ];
}

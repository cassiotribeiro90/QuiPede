import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../models/endereco_model.dart';

class PedidoDetalheModel extends Equatable {
  final int id;
  final int itemCount;
  final String status;
  final String statusLabel;
  final double subtotal;
  final double taxaEntrega;
  final double total;
  final String formaPagamento;
  final String formaPagamentoLabel;
  final double? trocoPara;
  final String? observacao;
  final DateTime criadoEm;
  final DateTime? confirmadoEm;
  final DateTime? emPreparoEm;
  final DateTime? saiuEntregaEm;
  final DateTime? entregueEm;
  final DateTime? canceladoEm;
  final EnderecoModel endereco;
  final List<PedidoItemModel> itens;
  final String? lojaNome;

  const PedidoDetalheModel({
    required this.id,
    required this.itemCount,
    required this.status,
    required this.statusLabel,
    required this.subtotal,
    required this.taxaEntrega,
    required this.total,
    required this.formaPagamento,
    required this.formaPagamentoLabel,
    this.trocoPara,
    this.observacao,
    required this.criadoEm,
    this.confirmadoEm,
    this.emPreparoEm,
    this.saiuEntregaEm,
    this.entregueEm,
    this.canceladoEm,
    required this.endereco,
    required this.itens,
    this.lojaNome,
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'entregue':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'saiu_entrega':
      case 'saiu':
      case 'em_preparo':
      case 'preparando':
      case 'pronto':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'novo':
      case 'pendente':
        return Icons.receipt_long;
      case 'confirmado':
        return Icons.check_circle_outline;
      case 'em_preparo':
      case 'preparando':
        return Icons.restaurant;
      case 'saiu_entrega':
      case 'saiu':
        return Icons.delivery_dining;
      case 'entregue':
        return Icons.verified;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  factory PedidoDetalheModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null || v.toString().isEmpty) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (e) {
        return null;
      }
    }

    return PedidoDetalheModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      status: json['status']?.toString() ?? 'desconhecido',
      statusLabel: json['status_label']?.toString() ?? json['status']?.toString() ?? 'Desconhecido',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      taxaEntrega: double.tryParse(json['taxa_entrega']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      formaPagamento: json['forma_pagamento']?.toString() ?? '',
      formaPagamentoLabel: json['forma_pagamento_label']?.toString() ?? json['forma_pagamento']?.toString() ?? '',
      trocoPara: json['troco_para'] != null ? double.tryParse(json['troco_para'].toString()) : null,
      observacao: json['observacao']?.toString(),
      criadoEm: parseDate(json['created_at'] ?? json['criado_at']) ?? DateTime.now(),
      confirmadoEm: parseDate(json['confirmado_at']),
      emPreparoEm: parseDate(json['em_preparo_at']),
      saiuEntregaEm: parseDate(json['saiu_entrega_at']),
      entregueEm: parseDate(json['entregue_at']),
      canceladoEm: parseDate(json['cancelado_at']),
      itemCount: json['item_count'] ?? 0,
      endereco: json['endereco'] is Map 
          ? EnderecoModel.fromJson(json['endereco']) 
          : const EnderecoModel(cep: '', logradouro: '', numero: '', bairro: '', cidade: '', uf: ''),
      itens: (json['itens'] is List) 
          ? (json['itens'] as List).map((i) => PedidoItemModel.fromJson(i)).toList() 
          : [],
      lojaNome: json['loja'] is Map 
          ? json['loja']['nome']?.toString() 
          : (json['loja']?.toString() ?? json['loja_nome']?.toString()),
    );
  }

  @override
  List<Object?> get props => [
    id, status, subtotal, taxaEntrega, total, formaPagamento, 
    criadoEm, endereco, itens, lojaNome
  ];
}

class PedidoItemModel extends Equatable {
  final int id;
  final String nome;
  final int quantidade;
  final double precoUnitario;
  final double precoTotal;
  final String? observacao;

  const PedidoItemModel({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.precoUnitario,
    required this.precoTotal,
    this.observacao,
  });

  factory PedidoItemModel.fromJson(Map<String, dynamic> json) {
    return PedidoItemModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      nome: json['nome']?.toString() ?? '',
      quantidade: int.tryParse(json['quantidade']?.toString() ?? '0') ?? 0,
      precoUnitario: double.tryParse(json['preco_unitario']?.toString() ?? '0') ?? 0.0,
      precoTotal: double.tryParse(json['preco_total']?.toString() ?? '0') ?? 0.0,
      observacao: json['observacao']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, nome, quantidade, precoUnitario, precoTotal, observacao];
}

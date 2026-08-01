import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../enderecos/models/endereco_model.dart';

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
  final String? lojaLogo; // 🔥 NOVO

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
    this.lojaLogo, // 🔥 NOVO
  });

  // Mapa de status para labels
  static const Map<String, String> statusLabels = {
    'novo': 'Novo',
    'aguardando': 'Aguardando',
    'confirmado': 'Confirmado',
    'preparando': 'Preparando',
    'pronto': 'Pronto',
    'saiu': 'Saiu para Entrega',
    'entregue': 'Entregue',
    'cancelado': 'Cancelado',
  };

  static const Map<String, String> pagamentoLabels = {
    'credito': 'Cartão de Crédito',
    'debito': 'Cartão de Débito',
    'dinheiro': 'Dinheiro',
    'pix': 'PIX',
    'vr': 'Vale Refeição',
  };

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'entregue':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'saiu':
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
      case 'preparando':
        return Icons.restaurant;
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

  // 🔥 HELPER DATA FORMATADA
  String get dataFormatada {
    final now = DateTime.now();
    final diff = now.difference(criadoEm);
    if (diff.inDays == 0) return 'Hoje ${DateFormat('HH:mm').format(criadoEm)}';
    if (diff.inDays == 1) return 'Ontem ${DateFormat('HH:mm').format(criadoEm)}';
    return DateFormat('dd/MM/yyyy HH:mm').format(criadoEm);
  }

  factory PedidoDetalheModel.fromJson(Map<String, dynamic> json) {
    // 🔧 FUNÇÃO DE PARSE CORRIGIDA
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      final str = value.toString().trim();
      try {
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(str);
      } catch (_) {
        try {
          return DateTime.parse(str);
        } catch (_) {
          return null;
        }
      }
    }

    String getStatusLabel(String status) {
      return statusLabels[status.toLowerCase()] ?? status;
    }

    String getPagamentoLabel(String forma) {
      return pagamentoLabels[forma.toLowerCase()] ?? forma;
    }

    // Endereço
    EnderecoModel endereco;
    if (json['endereco'] is Map) {
      endereco = EnderecoModel.fromJson(json['endereco']);
    } else if (json['endereco_entrega'] is Map) {
      endereco = EnderecoModel.fromJson(json['endereco_entrega']);
    } else {
      endereco = const EnderecoModel(
        cep: '',
        logradouro: '',
        numero: '',
        bairro: '',
        cidade: '',
        uf: '',
      );
    }

    // Itens
    List<PedidoItemModel> itens = [];
    if (json['itens'] is List) {
      itens = (json['itens'] as List)
          .map((i) => PedidoItemModel.fromJson(i))
          .toList();
    }

    // 🔥 LOJA – NOME E LOGO
    String? lojaNome;
    String? lojaLogo;
    if (json['loja'] is Map) {
      lojaNome = json['loja']['nome']?.toString();
      lojaLogo = json['loja']['logo']?.toString();
    } else if (json['loja_nome'] != null) {
      lojaNome = json['loja_nome'].toString();
    }
    if (json['loja_logo'] != null) {
      lojaLogo = json['loja_logo'].toString();
    }

    final statusStr = json['status']?.toString() ?? 'desconhecido';

    return PedidoDetalheModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      itemCount: json['item_count'] ?? 0,
      status: statusStr,
      statusLabel: json['status_label']?.toString() ?? getStatusLabel(statusStr),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxaEntrega: (json['taxa_entrega'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      formaPagamento: json['forma_pagamento']?.toString() ?? '',
      formaPagamentoLabel: json['forma_pagamento_label']?.toString() ??
          getPagamentoLabel(json['forma_pagamento']?.toString() ?? ''),
      trocoPara: json['troco_para'] != null
          ? (json['troco_para'] as num?)?.toDouble()
          : null,
      observacao: json['observacoes']?.toString() ?? json['observacao']?.toString(),
      criadoEm: parseDate(json['criado_em']) ?? DateTime.now(),
      confirmadoEm: parseDate(json['data_confirmacao']),
      emPreparoEm: parseDate(json['data_preparo']),
      saiuEntregaEm: parseDate(json['data_saida']),
      entregueEm: parseDate(json['data_entrega']),
      canceladoEm: parseDate(json['data_cancelamento']),
      endereco: endereco,
      itens: itens,
      lojaNome: lojaNome,
      lojaLogo: lojaLogo, // 🔥 NOVO
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    subtotal,
    taxaEntrega,
    total,
    formaPagamento,
    criadoEm,
    endereco,
    itens,
    lojaNome,
    lojaLogo, // 🔥 NOVO
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
      nome: json['nome']?.toString() ?? json['produto_nome']?.toString() ?? '',
      quantidade: json['quantidade'] is int
          ? json['quantidade']
          : (int.tryParse(json['quantidade']?.toString() ?? '0') ?? 0),
      precoUnitario: (json['preco_unitario'] as num?)?.toDouble() ?? 0.0,
      precoTotal: (json['preco_total'] as num?)?.toDouble() ?? 0.0,
      observacao: json['observacao']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, nome, quantidade, precoUnitario, precoTotal, observacao];
}
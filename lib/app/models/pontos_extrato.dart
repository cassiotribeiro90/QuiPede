import 'package:equatable/equatable.dart';

enum TipoPontos {
  pedido,
  avaliacaoPedido,
  avaliacaoProduto,
  bonusSemana,
  ajuste,
  desconhecido;

  static TipoPontos fromString(String? value) {
    switch (value) {
      case 'pedido':
        return TipoPontos.pedido;
      case 'avaliacao_pedido':
        return TipoPontos.avaliacaoPedido;
      case 'avaliacao_produto':
        return TipoPontos.avaliacaoProduto;
      case 'bonus_semana':
        return TipoPontos.bonusSemana;
      case 'ajuste':
        return TipoPontos.ajuste;
      default:
        return TipoPontos.desconhecido;
    }
  }
}

class PontosExtrato extends Equatable {
  final int id;
  final String tipo;
  final int pontos;
  final String? descricao;
  final int? referenciaId;
  final String criadoEm;

  const PontosExtrato({
    required this.id,
    required this.tipo,
    required this.pontos,
    this.descricao,
    this.referenciaId,
    required this.criadoEm,
  });

  factory PontosExtrato.fromJson(Map<String, dynamic> json) {
    return PontosExtrato(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tipo: json['tipo']?.toString() ?? '',
      pontos: (json['pontos'] as num?)?.toInt() ?? 0,
      descricao: json['descricao']?.toString(),
      referenciaId: (json['referencia_id'] as num?)?.toInt(),
      criadoEm: json['criado_em']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'pontos': pontos,
      'descricao': descricao,
      'referencia_id': referenciaId,
      'criado_em': criadoEm,
    };
  }

  bool get isCredito => pontos >= 0;

  String get tipoLabel {
    switch (TipoPontos.fromString(tipo)) {
      case TipoPontos.pedido:
        return 'Pedido';
      case TipoPontos.avaliacaoPedido:
        return 'Avaliação de pedido';
      case TipoPontos.avaliacaoProduto:
        return 'Avaliação de produto';
      case TipoPontos.bonusSemana:
        return 'Bônus semanal';
      case TipoPontos.ajuste:
        return 'Ajuste';
      default:
        return 'Movimentação';
    }
  }

  String get pontosLabel {
    return (isCredito ? '+' : '') + pontos.toString();
  }

  String get dataFormatada {
    try {
      final date = DateTime.parse(criadoEm);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return criadoEm;
    }
  }

  @override
  List<Object?> get props => [
    id,
    tipo,
    pontos,
    descricao,
    referenciaId,
    criadoEm,
  ];
}
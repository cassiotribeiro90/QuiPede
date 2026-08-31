import 'package:equatable/equatable.dart';

class AvaliacaoModel extends Equatable {
  final int id;
  final int usuarioId;
  final int lojaId;
  final int? pedidoId;
  final int? produtoId;
  final int nota;
  final String? comentario;
  final String? resposta;
  final String? respostaEm;
  final List<String>? fotos;
  final int curtidas;
  final String status;
  final String criadoEm;
  final String? atualizadoEm;
  final String? deletadoEm;
  
  // Campos relacionados (para exibição)
  final String? usuarioNome;
  final String? lojaNome;
  final String? produtoNome;
  final String? pedidoCodigo;

  const AvaliacaoModel({
    required this.id,
    required this.usuarioId,
    required this.lojaId,
    this.pedidoId,
    this.produtoId,
    required this.nota,
    this.comentario,
    this.resposta,
    this.respostaEm,
    this.fotos,
    this.curtidas = 0,
    required this.status,
    required this.criadoEm,
    this.atualizadoEm,
    this.deletadoEm,
    this.usuarioNome,
    this.lojaNome,
    this.produtoNome,
    this.pedidoCodigo,
  });

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    return AvaliacaoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      usuarioId: (json['usuario_id'] as num?)?.toInt() ?? 0,
      lojaId: (json['loja_id'] as num?)?.toInt() ?? 0,
      pedidoId: (json['pedido_id'] as num?)?.toInt(),
      produtoId: (json['produto_id'] as num?)?.toInt(),
      nota: (json['nota'] as num?)?.toInt() ?? 0,
      comentario: json['comentario']?.toString(),
      resposta: json['resposta']?.toString(),
      respostaEm: json['resposta_em']?.toString(),
      fotos: (json['fotos'] as List?)?.map((e) => e.toString()).toList(),
      curtidas: (json['curtidas'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'pendente',
      criadoEm: json['criado_em']?.toString() ?? '',
      atualizadoEm: json['atualizado_em']?.toString(),
      deletadoEm: json['deletado_em']?.toString(),
      usuarioNome: json['usuario_nome']?.toString(),
      lojaNome: json['loja_nome']?.toString(),
      produtoNome: json['produto_nome']?.toString(),
      pedidoCodigo: json['pedido_codigo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'loja_id': lojaId,
      'pedido_id': pedidoId,
      'produto_id': produtoId,
      'nota': nota,
      'comentario': comentario,
      'resposta': resposta,
      'resposta_em': respostaEm,
      'fotos': fotos,
      'curtidas': curtidas,
      'status': status,
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
      'deletado_em': deletadoEm,
      'usuario_nome': usuarioNome,
      'loja_nome': lojaNome,
      'produto_nome': produtoNome,
      'pedido_codigo': pedidoCodigo,
    };
  }

  @override
  List<Object?> get props => [
    id,
    usuarioId,
    lojaId,
    pedidoId,
    produtoId,
    nota,
    comentario,
    resposta,
    respostaEm,
    fotos,
    curtidas,
    status,
    criadoEm,
    atualizadoEm,
    deletadoEm,
    usuarioNome,
    lojaNome,
    produtoNome,
    pedidoCodigo,
  ];

  // ================================================================
  // 🔥 GETTERS AUXILIARES
  // ================================================================

  bool get isAprovado => status == 'aprovado';
  bool get isPendente => status == 'pendente';
  bool get isRejeitado => status == 'rejeitado';
  bool get hasResposta => resposta != null && resposta!.isNotEmpty;
  bool get isLoja => produtoId == null;
  bool get isProduto => produtoId != null;

  String get statusLabel {
    switch (status) {
      case 'aprovado':
        return 'Aprovado';
      case 'pendente':
        return 'Pendente';
      case 'rejeitado':
        return 'Rejeitado';
      default:
        return status;
    }
  }

  String get tipoLabel {
    if (isProduto) {
      return 'Produto: ${produtoNome ?? produtoId}';
    }
    return 'Loja: ${lojaNome ?? lojaId}';
  }

  String get estrelas {
    return '⭐' * nota + '☆' * (5 - nota);
  }

  String get dataFormatada {
    try {
      final date = DateTime.parse(criadoEm);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return criadoEm;
    }
  }

  AvaliacaoModel copyWith({
    int? id,
    int? usuarioId,
    int? lojaId,
    int? pedidoId,
    int? produtoId,
    int? nota,
    String? comentario,
    String? resposta,
    String? respostaEm,
    List<String>? fotos,
    int? curtidas,
    String? status,
    String? criadoEm,
    String? atualizadoEm,
    String? deletadoEm,
    String? usuarioNome,
    String? lojaNome,
    String? produtoNome,
    String? pedidoCodigo,
  }) {
    return AvaliacaoModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      lojaId: lojaId ?? this.lojaId,
      pedidoId: pedidoId ?? this.pedidoId,
      produtoId: produtoId ?? this.produtoId,
      nota: nota ?? this.nota,
      comentario: comentario ?? this.comentario,
      resposta: resposta ?? this.resposta,
      respostaEm: respostaEm ?? this.respostaEm,
      fotos: fotos ?? this.fotos,
      curtidas: curtidas ?? this.curtidas,
      status: status ?? this.status,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      deletadoEm: deletadoEm ?? this.deletadoEm,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      lojaNome: lojaNome ?? this.lojaNome,
      produtoNome: produtoNome ?? this.produtoNome,
      pedidoCodigo: pedidoCodigo ?? this.pedidoCodigo,
    );
  }
}

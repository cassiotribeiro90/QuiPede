import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final int id;
  final int clienteId;
  final int lojaId;
  final int? pedidoId;
  final String? ultimaMensagem;
  final String? dataUltimaMensagem;
  final String status;
  final String criadoEm;
  final String atualizadoEm;

  // Campos relacionados (para exibição)
  final String? clienteNome;
  final String? clienteAvatar;
  final String? lojaNome;
  final String? lojaLogo;

  // Campo virtual para contagem de não lidas
  final int? naoLidas;

  const ChatModel({
    required this.id,
    required this.clienteId,
    required this.lojaId,
    this.pedidoId,
    this.ultimaMensagem,
    this.dataUltimaMensagem,
    required this.status,
    required this.criadoEm,
    required this.atualizadoEm,
    this.clienteNome,
    this.clienteAvatar,
    this.lojaNome,
    this.lojaLogo,
    this.naoLidas = 0,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      clienteId: (json['cliente_id'] as num?)?.toInt() ?? 0,
      lojaId: (json['loja_id'] as num?)?.toInt() ?? 0,
      pedidoId: (json['pedido_id'] as num?)?.toInt(),
      ultimaMensagem: json['ultima_mensagem']?.toString(),
      dataUltimaMensagem: json['data_ultima_mensagem']?.toString(),
      status: json['status']?.toString() ?? 'ativo',
      criadoEm: json['criado_em']?.toString() ?? '',
      atualizadoEm: json['atualizado_em']?.toString() ?? json['criado_em']?.toString() ?? '',
      clienteNome: json['cliente_nome']?.toString(),
      clienteAvatar: json['cliente_avatar']?.toString(),
      lojaNome: json['loja_nome']?.toString(),
      lojaLogo: json['loja_logo']?.toString(),
      naoLidas: (json['nao_lidas'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'loja_id': lojaId,
      'pedido_id': pedidoId,
      'ultima_mensagem': ultimaMensagem,
      'data_ultima_mensagem': dataUltimaMensagem,
      'status': status,
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
      'cliente_nome': clienteNome,
      'cliente_avatar': clienteAvatar,
      'loja_nome': lojaNome,
      'loja_logo': lojaLogo,
      'nao_lidas': naoLidas,
    };
  }

  @override
  List<Object?> get props => [
    id,
    clienteId,
    lojaId,
    pedidoId,
    ultimaMensagem,
    dataUltimaMensagem,
    status,
    criadoEm,
    atualizadoEm,
    clienteNome,
    clienteAvatar,
    lojaNome,
    lojaLogo,
    naoLidas,
  ];

  // ================================================================
  // 🔥 GETTERS AUXILIARES
  // ================================================================

  bool get isAtivo => status == 'ativo';
  bool get isArquivado => status == 'arquivado';
  bool get isBloqueado => status == 'bloqueado_cliente' || status == 'bloqueado_lojista';
  bool get temMensagemNaoLida => (naoLidas ?? 0) > 0;

  String get statusLabel {
    switch (status) {
      case 'ativo':
        return 'Ativo';
      case 'arquivado':
        return 'Arquivado';
      case 'bloqueado_cliente':
        return 'Bloqueado pelo Cliente';
      case 'bloqueado_lojista':
        return 'Bloqueado pela Loja';
      default:
        return status;
    }
  }

  String get nomeParticipante {
    return lojaNome ?? 'Loja';
  }

  String? get avatarParticipante {
    return lojaLogo;
  }

  String get dataUltimaMensagemFormatada {
    try {
      final date = DateTime.parse(dataUltimaMensagem ?? criadoEm);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}min';
      } else {
        return 'Agora';
      }
    } catch (_) {
      return dataUltimaMensagem ?? criadoEm;
    }
  }

  ChatModel copyWith({
    int? id,
    int? clienteId,
    int? lojaId,
    int? pedidoId,
    String? ultimaMensagem,
    String? dataUltimaMensagem,
    String? status,
    String? criadoEm,
    String? atualizadoEm,
    String? clienteNome,
    String? clienteAvatar,
    String? lojaNome,
    String? lojaLogo,
    int? naoLidas,
  }) {
    return ChatModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      lojaId: lojaId ?? this.lojaId,
      pedidoId: pedidoId ?? this.pedidoId,
      ultimaMensagem: ultimaMensagem ?? this.ultimaMensagem,
      dataUltimaMensagem: dataUltimaMensagem ?? this.dataUltimaMensagem,
      status: status ?? this.status,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteAvatar: clienteAvatar ?? this.clienteAvatar,
      lojaNome: lojaNome ?? this.lojaNome,
      lojaLogo: lojaLogo ?? this.lojaLogo,
      naoLidas: naoLidas ?? this.naoLidas,
    );
  }
}

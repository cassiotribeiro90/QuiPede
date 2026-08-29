import 'package:equatable/equatable.dart';

class ChatMensagemModel extends Equatable {
  final int id;
  final int chatId;
  final int? pedidoId;
  final int? lojistaId;
  final int? clienteId;
  final String mensagem;
  final String tipo;
  final String? anexoUrl;
  final bool lida;
  final String? lidaEm;
  final String enviadoPor;
  final String criadoEm;

  // Campos relacionados (para exibição)
  final String? remetenteNome;
  final String? remetenteAvatar;

  const ChatMensagemModel({
    required this.id,
    required this.chatId,
    this.pedidoId,
    this.lojistaId,
    this.clienteId,
    required this.mensagem,
    required this.tipo,
    this.anexoUrl,
    this.lida = false,
    this.lidaEm,
    required this.enviadoPor,
    required this.criadoEm,
    this.remetenteNome,
    this.remetenteAvatar,
  });

  factory ChatMensagemModel.fromJson(Map<String, dynamic> json) {
    return ChatMensagemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      chatId: (json['chat_id'] as num?)?.toInt() ?? 0,
      pedidoId: (json['pedido_id'] as num?)?.toInt(),
      lojistaId: (json['lojista_id'] as num?)?.toInt(),
      clienteId: (json['cliente_id'] as num?)?.toInt(),
      mensagem: json['mensagem']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'texto',
      anexoUrl: json['anexo_url']?.toString(),
      lida: (json['lida'] == 1 || json['lida'] == true),
      lidaEm: json['lida_em']?.toString(),
      enviadoPor: json['enviado_por']?.toString() ?? 'sistema',
      criadoEm: json['criado_em']?.toString() ?? '',
      remetenteNome: json['remetente_nome']?.toString(),
      remetenteAvatar: json['remetente_avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'pedido_id': pedidoId,
      'lojista_id': lojistaId,
      'cliente_id': clienteId,
      'mensagem': mensagem,
      'tipo': tipo,
      'anexo_url': anexoUrl,
      'lida': lida,
      'lida_em': lidaEm,
      'enviado_por': enviadoPor,
      'criado_em': criadoEm,
      'remetente_nome': remetenteNome,
      'remetente_avatar': remetenteAvatar,
    };
  }

  @override
  List<Object?> get props => [
    id,
    chatId,
    pedidoId,
    lojistaId,
    clienteId,
    mensagem,
    tipo,
    anexoUrl,
    lida,
    lidaEm,
    enviadoPor,
    criadoEm,
    remetenteNome,
    remetenteAvatar,
  ];

  // ================================================================
  // 🔥 GETTERS AUXILIARES
  // ================================================================

  bool get isTexto => tipo == 'texto';
  bool get isImagem => tipo == 'imagem';
  bool get isAudio => tipo == 'audio';
  bool get isSistema => tipo == 'sistema';
  bool get isDoCliente => enviadoPor == 'cliente';
  bool get isDoLojista => enviadoPor == 'lojista';
  bool get isDoSistema => enviadoPor == 'sistema';
  bool get isLida => lida;

  String get tipoLabel {
    switch (tipo) {
      case 'texto':
        return 'Texto';
      case 'imagem':
        return 'Imagem';
      case 'audio':
        return 'Áudio';
      case 'sistema':
        return 'Sistema';
      default:
        return tipo;
    }
  }

  String get enviadoPorLabel {
    switch (enviadoPor) {
      case 'cliente':
        return 'Cliente';
      case 'lojista':
        return 'Lojista';
      case 'sistema':
        return 'Sistema';
      default:
        return enviadoPor;
    }
  }

  String get mensagemFormatada {
    if (isImagem && anexoUrl != null) {
      return '📷 [Imagem]';
    }
    if (isAudio && anexoUrl != null) {
      return '🎵 [Áudio]';
    }
    if (isSistema) {
      return '🔄 $mensagem';
    }
    return mensagem;
  }

  String get dataFormatada {
    try {
      final date = DateTime.parse(criadoEm);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return criadoEm;
    }
  }

  ChatMensagemModel copyWith({
    int? id,
    int? chatId,
    int? pedidoId,
    int? lojistaId,
    int? clienteId,
    String? mensagem,
    String? tipo,
    String? anexoUrl,
    bool? lida,
    String? lidaEm,
    String? enviadoPor,
    String? criadoEm,
    String? remetenteNome,
    String? remetenteAvatar,
  }) {
    return ChatMensagemModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      pedidoId: pedidoId ?? this.pedidoId,
      lojistaId: lojistaId ?? this.lojistaId,
      clienteId: clienteId ?? this.clienteId,
      mensagem: mensagem ?? this.mensagem,
      tipo: tipo ?? this.tipo,
      anexoUrl: anexoUrl ?? this.anexoUrl,
      lida: lida ?? this.lida,
      lidaEm: lidaEm ?? this.lidaEm,
      enviadoPor: enviadoPor ?? this.enviadoPor,
      criadoEm: criadoEm ?? this.criadoEm,
      remetenteNome: remetenteNome ?? this.remetenteNome,
      remetenteAvatar: remetenteAvatar ?? this.remetenteAvatar,
    );
  }
}

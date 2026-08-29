part of 'chat_bloc.dart';

/// 🔥 Estados do Chat
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

// ================================================================
// 🔥 ESTADOS INICIAL E DE CARREGAMENTO
// ================================================================

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

// ================================================================
// 🔥 ESTADOS DE CHATS (LISTA)
// ================================================================

/// Chats carregados com sucesso (cliente)
class ChatLoaded extends ChatState {
  final List<ChatModel> chats;
  final int totalNaoLidas;

  const ChatLoaded({
    required this.chats,
    this.totalNaoLidas = 0,
  });

  @override
  List<Object?> get props => [chats, totalNaoLidas];

  ChatLoaded copyWith({
    List<ChatModel>? chats,
    int? totalNaoLidas,
  }) {
    return ChatLoaded(
      chats: chats ?? this.chats,
      totalNaoLidas: totalNaoLidas ?? this.totalNaoLidas,
    );
  }
}

/// Chats carregados com sucesso (lojista)
class ChatLojistaLoaded extends ChatState {
  final List<ChatModel> chats;
  final int totalNaoLidas;

  const ChatLojistaLoaded({
    required this.chats,
    this.totalNaoLidas = 0,
  });

  @override
  List<Object?> get props => [chats, totalNaoLidas];

  ChatLojistaLoaded copyWith({
    List<ChatModel>? chats,
    int? totalNaoLidas,
  }) {
    return ChatLojistaLoaded(
      chats: chats ?? this.chats,
      totalNaoLidas: totalNaoLidas ?? this.totalNaoLidas,
    );
  }
}

// ================================================================
// 🔥 ESTADOS DE MENSAGENS
// ================================================================

/// Mensagens carregadas com sucesso
class ChatMessagesLoaded extends ChatState {
  final List<ChatMensagemModel> mensagens;
  final int chatId;
  final bool hasMore;

  const ChatMessagesLoaded({
    required this.mensagens,
    required this.chatId,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [mensagens, chatId, hasMore];

  ChatMessagesLoaded copyWith({
    List<ChatMensagemModel>? mensagens,
    int? chatId,
    bool? hasMore,
  }) {
    return ChatMessagesLoaded(
      mensagens: mensagens ?? this.mensagens,
      chatId: chatId ?? this.chatId,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ================================================================
// 🔥 ESTADOS DE AÇÃO
// ================================================================

/// Chat criado com sucesso
class ChatCreated extends ChatState {
  final ChatModel chat;
  const ChatCreated({required this.chat});

  @override
  List<Object?> get props => [chat];
}

/// Mensagem enviada com sucesso
class ChatMessageSent extends ChatState {
  final ChatMensagemModel mensagem;
  const ChatMessageSent({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}

/// Mensagens marcadas como lidas
class ChatMessagesMarkedAsRead extends ChatState {
  final int count;
  const ChatMessagesMarkedAsRead(this.count);

  @override
  List<Object?> get props => [count];
}

/// Chat arquivado com sucesso
class ChatArchived extends ChatState {
  final int chatId;
  const ChatArchived(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Contagem de não lidas carregada
class ChatNaoLidasLoaded extends ChatState {
  final int total;
  const ChatNaoLidasLoaded(this.total);

  @override
  List<Object?> get props => [total];
}

/// Status do chat atualizado
class ChatStatusUpdated extends ChatState {
  final ChatModel chat;
  const ChatStatusUpdated({required this.chat});

  @override
  List<Object?> get props => [chat];
}

/// Nova mensagem recebida via push
class ChatNovaMensagem extends ChatState {
  final ChatMensagemModel mensagem;
  const ChatNovaMensagem(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

/// 🔥 ESTADO ÚNICO PARA CHAT PRONTO (com mensagens carregadas)
class ChatReady extends ChatState {
  final ChatModel chat;
  final List<ChatMensagemModel> mensagens;

  const ChatReady({
    required this.chat,
    required this.mensagens,
  });

  @override
  List<Object?> get props => [chat, mensagens];
}

// ================================================================
// 🔥 ESTADO DE ERRO
// ================================================================

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

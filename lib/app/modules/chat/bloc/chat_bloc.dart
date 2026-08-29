import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quipede/app/models/chat/chat_model.dart';
import 'package:quipede/app/models/chat/chat_mensagem_model.dart';
import 'package:quipede/app/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// 🔥 BLoC para gerenciamento de Chat
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository = ChatRepository();
  
  // 🔥 MAPA PARA ARMAZENAR MENSAGENS POR CHAT ID (Cache persistente durante a sessão)
  static final Map<int, List<ChatMensagemModel>> _mensagensCache = {};

  ChatBloc() : super(ChatInitial()) {
    // ================================================================
    // 🔥 CLIENTE
    // ================================================================

    on<CarregarChats>(_onCarregarChats);
    on<IniciarChatComLoja>(_onIniciarChatComLoja);
    on<CarregarMensagens>(_onCarregarMensagens);
    on<CriarChat>(_onCriarChat);
    on<EnviarMensagem>(_onEnviarMensagem);
    on<MarcarMensagensComoLidas>(_onMarcarMensagensComoLidas);
    on<ArquivarChat>(_onArquivarChat);
    on<ContarNaoLidas>(_onContarNaoLidas);


    // ================================================================
    // 🔥 SINCRONIZAÇÃO
    // ================================================================

    on<NovaMensagemRecebida>(_onNovaMensagemRecebida);
    on<LimparChat>(_onLimparChat);
  }

  // ================================================================
  // 🔥 HANDLERS - CLIENTE
  // ================================================================

  /// Carregar chats do cliente
  Future<void> _onCarregarChats(
    CarregarChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chats = await _repository.getMeusChats();
      final totalNaoLidas = await _repository.contarNaoLidas();
      emit(ChatLoaded(chats: chats, totalNaoLidas: totalNaoLidas));
    } catch (e) {
      emit(ChatError(message: 'Erro ao carregar chats: $e'));
    }
  }

  /// Iniciar chat com a loja
  Future<void> _onIniciarChatComLoja(
    IniciarChatComLoja event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final result = await _repository.iniciarChatComLoja(
        lojaId: event.lojaId,
        pedidoId: event.pedidoId,
        mensagemInicial: event.mensagemInicial,
      );

      final chat = result['chat'] as ChatModel;
      final mensagens = result['mensagens'] as List<ChatMensagemModel>;

      // 🔥 ATUALIZA O CACHE COM AS MENSAGENS RECEBIDAS
      _mensagensCache[chat.id] = mensagens;

      // 🔥 EMITE O ESTADO DE PRONTO COM MENSAGENS CARREGADAS
      emit(ChatReady(
        chat: chat,
        mensagens: mensagens,
      ));

      add(CarregarChats());
    } catch (e) {
      emit(ChatError(message: 'Erro ao iniciar chat: $e'));
    }
  }

  /// Carregar mensagens de um chat
  Future<void> _onCarregarMensagens(
    CarregarMensagens event,
    Emitter<ChatState> emit,
  ) async {
    // 🔥 SE JÁ TIVER MENSAGENS EM CACHE, USA ELAS IMEDIATAMENTE PARA EVITAR FLICKER
    if (_mensagensCache.containsKey(event.chatId)) {
      emit(ChatMessagesLoaded(
        mensagens: _mensagensCache[event.chatId]!,
        chatId: event.chatId,
      ));
    } else {
      emit(ChatLoading());
    }

    try {
      final mensagens = await _repository.getMensagens(event.chatId);
      _mensagensCache[event.chatId] = mensagens; // 🔥 ATUALIZA O CACHE
      emit(ChatMessagesLoaded(
        mensagens: mensagens,
        chatId: event.chatId,
      ));
    } catch (e) {
      emit(ChatError(message: 'Erro ao carregar mensagens: $e'));
    }
  }

  /// Criar um novo chat
  Future<void> _onCriarChat(
    CriarChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chat = await _repository.criarChat(event.data);
      emit(ChatCreated(chat: chat));
      add(CarregarChats());
    } catch (e) {
      emit(ChatError(message: 'Erro ao criar chat: $e'));
    }
  }

  /// Enviar mensagem
  Future<void> _onEnviarMensagem(
    EnviarMensagem event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final mensagem = await _repository.enviarMensagem(
        event.chatId,
        {
          'mensagem': event.mensagem,
          'tipo': event.tipo,
          'anexo_url': event.anexoUrl,
          'pedido_id': event.pedidoId,
        },
      );

      // 🔥 ATUALIZA O CACHE LOCAL IMEDIATAMENTE
      if (_mensagensCache.containsKey(event.chatId)) {
        _mensagensCache[event.chatId]!.add(mensagem);
      } else {
        _mensagensCache[event.chatId] = [mensagem];
      }

      emit(ChatMessageSent(mensagem: mensagem));
      
      // 🔥 RE-EMITE O ESTADO LOADED COM O CACHE ATUALIZADO
      emit(ChatMessagesLoaded(
        mensagens: _mensagensCache[event.chatId]!,
        chatId: event.chatId,
      ));

      add(CarregarChats());
    } catch (e) {
      emit(ChatError(message: 'Erro ao enviar mensagem: $e'));
    }
  }

  /// Marcar mensagens como lidas
  Future<void> _onMarcarMensagensComoLidas(
    MarcarMensagensComoLidas event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final count = await _repository.marcarMensagensComoLidas(event.chatId);
      emit(ChatMessagesMarkedAsRead(count));
      
      // 🔥 RE-EMITE O ESTADO LOADED PARA MANTER AS MENSAGENS NA TELA
      if (_mensagensCache.containsKey(event.chatId)) {
        emit(ChatMessagesLoaded(
          mensagens: _mensagensCache[event.chatId]!,
          chatId: event.chatId,
        ));
      }
      
      add(CarregarChats());
    } catch (e) {
      print('Erro ao marcar mensagens como lidas: $e');
    }
  }

  /// Arquivar chat
  Future<void> _onArquivarChat(
    ArquivarChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      await _repository.arquivarChat(event.chatId);
      emit(ChatArchived(event.chatId));
      add(CarregarChats());
    } catch (e) {
      emit(ChatError(message: 'Erro ao arquivar chat: $e'));
    }
  }

  /// Contar mensagens não lidas
  Future<void> _onContarNaoLidas(
    ContarNaoLidas event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final total = await _repository.contarNaoLidas();
      emit(ChatNaoLidasLoaded(total));
    } catch (e) {
      emit(ChatNaoLidasLoaded(0));
    }
  }

  // ================================================================
  // 🔥 SINCRONIZAÇÃO
  // ================================================================

  Future<void> _onNovaMensagemRecebida(
    NovaMensagemRecebida event,
    Emitter<ChatState> emit,
  ) async {
    // Se estiver na tela de mensagens, adiciona à lista e ao cache
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      if (currentState.chatId == event.mensagem.chatId) {
        final novasMensagens = [...currentState.mensagens, event.mensagem];
        _mensagensCache[event.mensagem.chatId] = novasMensagens; // 🔥 UPDATE CACHE
        emit(ChatMessagesLoaded(
          mensagens: novasMensagens,
          chatId: currentState.chatId,
          hasMore: currentState.hasMore,
        ));
      }
    } else {
       // Se não estiver com o chat aberto mas o cache existir, atualiza ele silenciosamente
       if (_mensagensCache.containsKey(event.mensagem.chatId)) {
         _mensagensCache[event.mensagem.chatId]!.add(event.mensagem);
       }
    }

    if (state is ChatLoaded) {
      add(CarregarChats());
    }
    if (state is ChatLojistaLoaded) {
      add(CarregarChatsLojista());
    }

    emit(ChatNovaMensagem(event.mensagem));
  }

  void _onLimparChat(
    LimparChat event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatInitial());
  }

  // 🔥 METODO PARA LIMPAR CACHE (QUANDO SAIR DA TELA)
  static void limparCache(int chatId) {
    _mensagensCache.remove(chatId);
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quipede/app/core/theme/app_colors.dart';
import 'package:quipede/app/models/chat/chat_model.dart';
import 'package:quipede/app/models/chat/chat_mensagem_model.dart';
import 'package:quipede/app/repositories/chat_repository.dart';
import 'package:quipede/app/shared/widgets/chat_input.dart';
import 'package:quipede/app/shared/widgets/chat_message_bubble.dart';
import 'package:quipede/app/shared/widgets/chat_message_skeleton.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel? chat;
  final int? lojaId;
  final int? pedidoId;
  final String? mensagemInicial;
  final List<ChatMensagemModel>? mensagensIniciais;

  const ChatScreen({
    super.key,
    this.chat,
    this.lojaId,
    this.pedidoId,
    this.mensagemInicial,
    this.mensagensIniciais,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _repository = ChatRepository();

  // 🔥 ESTADO LOCAL
  List<ChatMensagemModel> _mensagens = [];
  ChatModel? _chat;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isFirstLoad = true;
  bool _isSending = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // 🔥 SE JÁ TEM DADOS, USA DIRETO (SEM SKELETON)
    if (widget.chat != null && widget.mensagensIniciais != null) {
      _chat = widget.chat;
      _mensagens = widget.mensagensIniciais!;
      _isLoading = false;
      _isFirstLoad = false;
      _startAutoRefresh();
      _scrollToBottom();
    } else {
      // 🔥 CARREGA EM BACKGROUND (UI MOSTRA SKELETON)
      _carregarDados();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // ================================================================
  // 🔥 CARREGAMENTO ÚNICO
  // ================================================================

  Future<void> _carregarDados() async {
    try {
      final result = await _repository.iniciarChatComLoja(
        lojaId: widget.lojaId ?? widget.chat?.lojaId,
        pedidoId: widget.pedidoId ?? widget.chat?.pedidoId,
        mensagemInicial: null,
      );

      if (mounted) {
        final chat = result['chat'] as ChatModel;
        final mensagens = result['mensagens'] as List<ChatMensagemModel>;

        setState(() {
          _chat = chat;
          _mensagens = mensagens;
          _isLoading = false;
          _isFirstLoad = false;
        });

        // 🔥 SÓ PREENCHE MENSAGEM INICIAL SE NÃO HOUVER MENSAGENS
        if (mensagens.isEmpty && widget.mensagemInicial != null) {
          _inputController.text = widget.mensagemInicial!;
        }

        // 🔥 MARCA COMO LIDAS EM BACKGROUND
        if (_chat != null) {
          _repository.marcarMensagensComoLidas(_chat!.id);
        }

        _startAutoRefresh();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFirstLoad = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // ================================================================
  // 🔥 AUTO REFRESH (SILENCIOSO)
  // ================================================================

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (mounted && _chat != null && !_isSending) {
        try {
          final mensagens = await _repository.getMensagens(_chat!.id);
          if (mounted && mensagens.length != _mensagens.length) {
            setState(() {
              _mensagens = mensagens;
            });
            _scrollToBottom();
          }
        } catch (_) {}
      }
    });
  }

  // ================================================================
  // 🔥 ENVIAR MENSAGEM (COM SKELETON)
  // ================================================================

  void _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _chat == null || _isSending) return;

    // 🔥 LIMPA CAMPO E MOSTRA SKELETON
    _inputController.clear();
    setState(() => _isSending = true);

    try {
      // 1️⃣ ENVIA MENSAGEM
      await _repository.enviarMensagem(
        _chat!.id,
        {
          'mensagem': text,
          'tipo': 'texto',
          'pedido_id': _chat!.pedidoId,
        },
      );

      // 2️⃣ RECARREGA TODAS AS MENSAGENS
      final mensagens = await _repository.getMensagens(_chat!.id);

      if (mounted) {
        setState(() {
          _mensagens = mensagens;
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      // 3️⃣ ERRO: VOLTA PARA LISTA ATUAL
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar mensagem. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ================================================================
  // 🔥 BUILD DA UI
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: AppBar(
        backgroundColor: AppColors.chatPrimary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _chat?.nomeParticipante ?? 'Carregando...',
              style: const TextStyle(color: Colors.white),
            ),
            if (_chat?.pedidoId != null)
              Text(
                'Pedido #${_chat?.pedidoId}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              )
            else if (_chat != null)
              const Text(
                'Conversa geral',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBody(),
          ),
          ChatInput(
            controller: _inputController,
            onSend: _sendMessage,
            onTextChanged: (_) {},
            isLoading: _isSending,
            hintText: 'Digite sua mensagem...',
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 🔥 CONSTRUÇÃO DO CORPO
  // ================================================================

  Widget _buildBody() {
    // 🔥 ERRO
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar conversa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Tente novamente',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // 🔥 SKELETON (PRIMEIRA CARGA OU ENVIANDO)
    if ((_isLoading && _isFirstLoad) || _isSending) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) {
          final isMe = index.isEven;
          final width = 180.0 + (index % 3) * 40;
          return ChatMessageSkeleton(
            isMe: isMe,
            width: width,
          );
        },
      );
    }

    // 🔥 SEM MENSAGENS
    if (!_isLoading && _mensagens.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma mensagem ainda',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Envie uma mensagem para iniciar a conversa',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 🔥 LISTA DE MENSAGENS
    return Container(
      color: AppColors.chatBackground,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _mensagens.length,
        itemBuilder: (context, index) {
          final message = _mensagens[index];
          final isMe = message.isDoCliente;
          return ChatMessageBubble(
            message: message,
            isMe: isMe,
          );
        },
      ),
    );
  }

  // ================================================================
  // 🔥 UTILITÁRIOS
  // ================================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
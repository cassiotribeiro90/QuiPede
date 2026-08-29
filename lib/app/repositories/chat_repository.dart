import 'package:quipede/app/models/chat/chat_model.dart';
import 'package:quipede/app/models/chat/chat_mensagem_model.dart';
import 'package:quipede/app/repositories/base_repository.dart';

class ChatRepository extends BaseRepository {
  // ================================================================
  // 🔥 CHATS DO CLIENTE
  // ================================================================

  Future<List<ChatModel>> getMeusChats() async {
    try {
      final response = await dio.get('/app/chats');

      if (response.data['success'] == true) {
        // 🔥 AGORA response.data['data'] é diretamente a lista
        final chatList = response.data['data'] as List;
        return chatList.map((item) => ChatModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chats');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatModel> criarChat(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/app/chats', data: data);

      if (response.data['success'] == true) {
        // 🔥 AGORA response.data['data'] é diretamente o chat
        return ChatModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao criar chat');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Map<String, dynamic>> iniciarChatComLoja({
    int? lojaId,
    int? pedidoId,
    String? mensagemInicial,
  }) async {
    if (lojaId == null && pedidoId == null) {
      throw Exception('lojaId ou pedidoId é obrigatório');
    }

    try {
      final Map<String, dynamic> data = {};
      if (lojaId != null) data['loja_id'] = lojaId;
      if (pedidoId != null) data['pedido_id'] = pedidoId;

      // 🔥 ÚNICA REQUISIÇÃO: RETORNA CHAT + MENSAGENS
      final response = await dio.post('/app/chats', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          final result = response.data['data'];

          // 🔥 EXTRAI CHAT E MENSAGENS DA NOVA RESPOSTA
          final chat = ChatModel.fromJson(result['chat']);
          final mensagens = (result['mensagens'] as List)
              .map((item) => ChatMensagemModel.fromJson(item))
              .toList();

          return {
            'chat': chat,
            'mensagens': mensagens,
          };
        }
      }

      throw Exception(response.data['message'] ?? 'Erro ao iniciar chat');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatModel> getChat(int id) async {
    try {
      final response = await dio.get('/app/chats/$id');

      if (response.data['success'] == true) {
        return ChatModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chat');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> arquivarChat(int id) async {
    try {
      final response = await dio.delete('/app/chats/$id');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erro ao arquivar chat');
      }
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> contarNaoLidas() async {
    try {
      final response = await dio.get('/app/chats/nao-lidas');

      if (response.data['success'] == true) {
        return response.data['data']['total_nao_lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ================================================================
  // 🔥 MENSAGENS
  // ================================================================

  Future<List<ChatMensagemModel>> getMensagens(int chatId) async {
    try {
      final response = await dio.get('/app/chats/$chatId/mensagens');

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => ChatMensagemModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar mensagens');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatMensagemModel> enviarMensagem(int chatId, Map<String, dynamic> data) async {
    try {
      final Map<String, dynamic> payload = {
        'mensagem': data['mensagem'] ?? '',
        'tipo': data['tipo'] ?? 'texto',
        'pedido_id': data['pedido_id'],
      };

      if (data['anexo_url'] != null && data['anexo_url'].toString().isNotEmpty) {
        payload['anexo_url'] = data['anexo_url'];
      }

      final response = await dio.post(
        '/app/chats/$chatId/mensagem',
        data: payload,
      );

      if (response.data['success'] == true) {
        return ChatMensagemModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao enviar mensagem');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> marcarMensagensComoLidas(int chatId) async {
    try {
      final response = await dio.put('/app/chats/$chatId/ler');

      if (response.data['success'] == true) {
        return response.data['data']['lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ================================================================
  // 🔥 CHATS DO LOJISTA
  // ================================================================

  Future<List<ChatModel>> getChatsLojista() async {
    try {
      final response = await dio.get('/lojista/chats');

      if (response.data['success'] == true) {
        final chatList = response.data['data'] as List;
        return chatList.map((item) => ChatModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chats');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<ChatModel>> getChatsLojistaComNaoLidas() async {
    try {
      final response = await dio.get('/lojista/chats/com-nao-lidas');

      if (response.data['success'] == true) {
        final chatList = response.data['data'] as List;
        return chatList.map((item) => ChatModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar chats com não lidas');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> contarNaoLidasLojista() async {
    try {
      final response = await dio.get('/lojista/chats/nao-lidas');

      if (response.data['success'] == true) {
        return response.data['data']['total_nao_lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<ChatMensagemModel>> getMensagensLojista(int chatId) async {
    try {
      final response = await dio.get('/lojista/chats/$chatId/mensagens');

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => ChatMensagemModel.fromJson(item)).toList();
      }

      throw Exception(response.data['message'] ?? 'Erro ao carregar mensagens');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ChatMensagemModel> enviarMensagemLojista(int chatId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        '/lojista/chats/$chatId/mensagem',
        data: data,
      );

      if (response.data['success'] == true) {
        return ChatMensagemModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao enviar mensagem');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<int> marcarMensagensComoLidasLojista(int chatId) async {
    try {
      final response = await dio.put('/lojista/chats/$chatId/ler');

      if (response.data['success'] == true) {
        return response.data['data']['lidas'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<ChatModel> atualizarStatusChatLojista(int chatId, String status) async {
    try {
      final response = await dio.put(
        '/lojista/chats/$chatId/status',
        data: {'status': status},
      );

      if (response.data['success'] == true) {
        return ChatModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Erro ao atualizar status do chat');
    } catch (e) {
      throw handleError(e);
    }
  }
}

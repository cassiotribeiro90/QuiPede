import 'package:quipede/app/models/avaliacao/avaliacao_model.dart';
import 'package:quipede/app/models/avaliacao/resumo_avaliacao_model.dart';
import 'package:quipede/app/repositories/base_repository.dart';

class AvaliacaoRepository extends BaseRepository {
  // ================================================================
  // 🔥 AVALIAÇÕES DO CLIENTE
  // ================================================================

  Future<List<AvaliacaoModel>> getMinhasAvaliacoes() async {
    try {
      final response = await dio.get('app/avaliacoes');
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => AvaliacaoModel.fromJson(item)).toList();
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao carregar avaliações');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<AvaliacaoModel> getAvaliacao(int id) async {
    try {
      final response = await dio.get('app/avaliacoes/$id');
      
      if (response.data['success'] == true) {
        return AvaliacaoModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao carregar avaliação');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<AvaliacaoModel> criarAvaliacao(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'app/avaliacoes',
        data: data,
      );
      
      if (response.data['success'] == true) {
        return AvaliacaoModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao criar avaliação');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<AvaliacaoModel> atualizarAvaliacao(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        'app/avaliacoes/$id',
        data: data,
      );
      
      if (response.data['success'] == true) {
        return AvaliacaoModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao atualizar avaliação');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> deletarAvaliacao(int id) async {
    try {
      final response = await dio.delete('app/avaliacoes/$id');
      
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Erro ao excluir avaliação');
      }
    } catch (e) {
      throw handleError(e);
    }
  }

  // ================================================================
  // 🔥 AVALIAÇÕES PÚBLICAS (LOJA / PRODUTO)
  // ================================================================

  Future<Map<String, dynamic>> getAvaliacoesLoja(int lojaId) async {
    try {
      final response = await dio.get('app/avaliacoes/loja/$lojaId');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao carregar avaliações da loja');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAvaliacoesProduto(int produtoId) async {
    try {
      final response = await dio.get('app/avaliacoes/produto/$produtoId');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao carregar avaliações do produto');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<AvaliacaoModel?> getAvaliacaoPedido(int pedidoId) async {
    try {
      final response = await dio.get('app/avaliacoes/pedido/$pedidoId');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return AvaliacaoModel.fromJson(response.data['data']);
      }
      
      return null;
    } catch (e) {
      // Se não encontrar, retorna null
      return null;
    }
  }

  // ================================================================
  // 🔥 AVALIAÇÕES DO LOJISTA
  // ================================================================

  Future<List<AvaliacaoModel>> getAvaliacoesLojista() async {
    try {
      final response = await dio.get('lojista/avaliacoes');
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => AvaliacaoModel.fromJson(item)).toList();
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao carregar avaliações');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<ResumoAvaliacaoModel> getResumoAvaliacoesLojista() async {
    try {
      final response = await dio.get('lojista/avaliacoes/resumo');
      
      if (response.data['success'] == true) {
        return ResumoAvaliacaoModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao carregar resumo');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<AvaliacaoModel>> getAvaliacoesPendentesLojista() async {
    try {
      final response = await dio.get('lojista/avaliacoes/pendentes');
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => AvaliacaoModel.fromJson(item)).toList();
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao carregar avaliações pendentes');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<List<AvaliacaoModel>> getAvaliacoesSemRespostaLojista() async {
    try {
      final response = await dio.get('lojista/avaliacoes/sem-resposta');
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => AvaliacaoModel.fromJson(item)).toList();
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao carregar avaliações sem resposta');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<AvaliacaoModel> responderAvaliacao(int id, String resposta) async {
    try {
      final response = await dio.post(
        'lojista/avaliacoes/$id/responder',
        data: {'resposta': resposta},
      );
      
      if (response.data['success'] == true) {
        return AvaliacaoModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao responder avaliação');
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<AvaliacaoModel> atualizarStatusAvaliacao(int id, String status) async {
    try {
      final response = await dio.put(
        'lojista/avaliacoes/$id/status',
        data: {'status': status},
      );
      
      if (response.data['success'] == true) {
        return AvaliacaoModel.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message'] ?? 'Erro ao atualizar status');
    } catch (e) {
      throw handleError(e);
    }
  }
}

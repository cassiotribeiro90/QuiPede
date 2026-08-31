import '../../../../shared/api/api_client.dart';
import '../../../models/avaliacao_model.dart';
import '../models/pedido_detalhe_model.dart';

class PedidoService {
  final ApiClient _apiClient;

  PedidoService(this._apiClient);

  Future<int> criarPedido({
    required int enderecoId,
    required String formaPagamento,
    double? trocoPara,
    String? observacao,
  }) async {
    final Map<String, dynamic> data = {
      'endereco_id': enderecoId,
      'forma_pagamento': formaPagamento,
    };
    if (trocoPara != null) data['troco_para'] = trocoPara;
    if (observacao != null) data['observacao'] = observacao;

    final response = await _apiClient.post('app/pedido/criar', data: data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data['data']['pedido_id'];
    }

    throw Exception(response.data['message'] ?? 'Erro ao criar pedido');
  }

  Future<PedidoDetalheModel> getPedidoDetalhe(int pedidoId) async {
    final response = await _apiClient.get(
      'app/pedido/view',
      queryParameters: {'id': pedidoId},
    );

    if (response.statusCode == 200) {
      // ⚠️ O backend retorna os dados diretamente na raiz, sem 'data'
      final json = response.data['data'] ?? response.data;
      return PedidoDetalheModel.fromJson(json);
    }

    throw Exception(response.data['message'] ?? 'Erro ao buscar detalhes do pedido');
  }

  Future<List<PedidoDetalheModel>> getPedidos() async {
    final response = await _apiClient.get('app/pedido/historico');

    if (response.statusCode == 200) {
      final List items = response.data['data']['items'];
      return items.map((e) => PedidoDetalheModel.fromJson(e)).toList();
    }

    throw Exception(response.data['message'] ?? 'Erro ao buscar pedidos');
  }

  Future<void> cancelarPedido(int pedidoId) async {
    final response = await _apiClient.post(
      'app/pedido/cancelar',
      queryParameters: {'id': pedidoId},
    );
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Erro ao cancelar pedido');
    }
  }

  Future<void> enviarAvaliacao({
    required int pedidoId,
    int? produtoId,
    int? lojaId,
    required int nota,
    String? comentario,
  }) async {
    final data = <String, dynamic>{
      'pedido_id': pedidoId,
      'nota': nota,
    };

    if (produtoId != null) data['produto_id'] = produtoId;
    if (lojaId != null) data['loja_id'] = lojaId;
    if (comentario != null && comentario.isNotEmpty) {
      data['comentario'] = comentario;
    }

    final response = await _apiClient.post('app/avaliacoes', data: data);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.data['message'] ?? 'Erro ao enviar avaliação');
    }
  }

  Future<void> editarAvaliacao({
    required int avaliacaoId,
    required int nota,
    String? comentario,
  }) async {
    final data = <String, dynamic>{
      'nota': nota,
    };

    if (comentario != null && comentario.isNotEmpty) {
      data['comentario'] = comentario;
    }

    final response = await _apiClient.put(
      'app/avaliacoes/$avaliacaoId',
      data: data,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Erro ao editar avaliação');
    }
  }

  Future<void> excluirAvaliacao(int avaliacaoId) async {
    final response = await _apiClient.delete('app/avaliacoes/$avaliacaoId');

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Erro ao excluir avaliação');
    }
  }

  Future<List<AvaliacaoModel>> getAvaliacoesPorPedido(int pedidoId) async {
    final response = await _apiClient.get(
      'app/avaliacoes/pedido/$pedidoId',
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data != null && data is List) {
        return data.map((e) => AvaliacaoModel.fromJson(e)).toList();
      }
      return [];
    }

    throw Exception(response.data['message'] ?? 'Erro ao buscar avaliações');
  }
}
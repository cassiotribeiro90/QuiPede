import '../../../../shared/api/api_client.dart';
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
      return PedidoDetalheModel.fromJson(response.data['data']);
    }
    
    throw Exception(response.data['message'] ?? 'Erro ao buscar detalhes do pedido');
  }

  Future<List<PedidoDetalheModel>> getPedidos() async {
    final response = await _apiClient.get('app/pedido/historico');
    
    if (response.statusCode == 200) {
      // Ajustado para extrair a lista 'items' de dentro de 'data'
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
}

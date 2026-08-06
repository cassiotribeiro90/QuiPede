import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:quipede/shared/api/api_client.dart';
import '../../../models/carrinho_response.dart';
import '../../../models/carrinho_result.dart';

class CarrinhoService {
  final ApiClient _apiClient;

  CarrinhoService(this._apiClient);

  /// Adiciona ou atualiza um item no carrinho
  Future<CarrinhoResult> atualizarItem({
    int? itemId,
    int? produtoId,
    int quantidade = 1,
    List<int> opcoes = const [],
    String? observacao,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'quantidade': quantidade,
        'opcoes': opcoes,
      };
      if (itemId != null) data['item_id'] = itemId;
      if (produtoId != null) data['produto_id'] = produtoId;
      if (observacao != null) data['observacao'] = observacao;

      debugPrint('📡 [Service] PUT /app/carrinho/atualizar -> $data');

      final response = await _apiClient.put(
        '/app/carrinho/atualizar',
        data: data,
      );

      debugPrint('📥 [Service] Status: ${response.statusCode}');

      // 🔥 TRATAR 409 (conflito de loja)
      if (response.statusCode == 409) {
        final json = response.data;
        if (json is Map<String, dynamic>) {
          final status = json['status'] as Map<String, dynamic>? ?? {};
          final lojaAtual = int.tryParse(status['loja_atual']?.toString() ?? '0') ?? 0;
          final novaLoja = int.tryParse(status['nova_loja']?.toString() ?? '0') ?? 0;
          final message = json['message'] ?? 'Seu carrinho já tem itens de outra loja.';

          debugPrint('🔥 [Service] CONFLITO 409 DETECTADO! lojaAtual=$lojaAtual, novaLoja=$novaLoja');

          final conflito = CarrinhoConflito(
            acao: status['acao'] ?? 'limpar_carrinho',
            lojaAtual: lojaAtual,
            novaLoja: novaLoja,
            lojaAtualNome: status['loja_atual_nome'],
            message: message,
          );
          return CarrinhoResult.conflito(conflito);
        }
        return CarrinhoResult.error('Erro ao processar conflito');
      }

      // Sucesso (200 ou 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = response.data;
        if (json['success'] == true && json['data'] != null) {
          final carrinho = CarrinhoResponse.fromJson(json['data']);
          return CarrinhoResult.success(carrinho);
        } else {
          return CarrinhoResult.error(json['message'] ?? 'Erro desconhecido');
        }
      }

      // Outros erros (400, 500, etc.)
      return CarrinhoResult.error('Erro inesperado: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [Service] Erro capturado: $e');

      if (e is DioException && e.response?.statusCode == 409) {
        final json = e.response?.data;
        if (json is Map<String, dynamic>) {
          final status = json['status'] as Map<String, dynamic>? ?? {};
          final lojaAtual = int.tryParse(status['loja_atual']?.toString() ?? '0') ?? 0;
          final novaLoja = int.tryParse(status['nova_loja']?.toString() ?? '0') ?? 0;
          final message = json['message'] ?? 'Seu carrinho já tem itens de outra loja.';

          debugPrint('🔥 [Service] CONFLITO 409 (via exceção)! lojaAtual=$lojaAtual, novaLoja=$novaLoja');

          final conflito = CarrinhoConflito(
            acao: status['acao'] ?? 'limpar_carrinho',
            lojaAtual: lojaAtual,
            novaLoja: novaLoja,
            lojaAtualNome: status['loja_atual_nome'],
            message: message,
          );
          return CarrinhoResult.conflito(conflito);
        }
        return CarrinhoResult.error('Erro ao processar conflito');
      }

      return CarrinhoResult.error(e.toString());
    }
  }

  /// Carrega o carrinho atual
  Future<CarrinhoResponse> carregarCarrinho({int? enderecoId}) async {
    try {
      final response = await _apiClient.get(
        'app/carrinho',
        queryParameters: enderecoId != null ? {'endereco_id': enderecoId} : null,
      );

      debugPrint('📥 [Service] carregarCarrinho - Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return CarrinhoResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Erro ao carregar carrinho');
      }
    } catch (e) {
      debugPrint('❌ [Service] Erro ao carregar carrinho: $e');
      throw Exception('Erro ao carregar carrinho: $e');
    }
  }

  /// Limpa o carrinho
  Future<void> limparCarrinho() async {
    try {
      await _apiClient.delete('/app/carrinho/limpar');
      debugPrint('✅ [Service] Carrinho limpo com sucesso');
    } catch (e) {
      debugPrint('❌ [Service] Erro ao limpar carrinho: $e');
      throw Exception('Erro ao limpar carrinho: $e');
    }
  }
}
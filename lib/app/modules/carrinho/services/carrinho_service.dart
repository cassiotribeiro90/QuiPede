import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../shared/api/api_client.dart';
import '../../../models/carrinho_response.dart';
import '../../../models/verificacao_loja_response.dart';
import '../../../models/carrinho_result.dart';

class CarrinhoService {
  final ApiClient _apiClient;

  CarrinhoService(this._apiClient);

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
      if (observacao != null && observacao.isNotEmpty) {
        data['observacao'] = observacao;
      }

      if (kDebugMode) {
        print('📤 [CarrinhoService] PUT app/carrinho/atualizar -> $data');
      }

      final response = await _apiClient.put('app/carrinho/atualizar', data: data);
      
      final int? statusCode = response.statusCode;
      final responseData = response.data;

      if (kDebugMode) {
        print('📥 [CarrinhoService] Resposta: $statusCode - $responseData');
      }

      // ✅ 1. Trata Conflito de Loja (Prioridade)
      if (statusCode == 409 || (responseData is Map && responseData['code'] == 409)) {
        if (kDebugMode) print('⚠️ [CarrinhoService] Conflito detectado (409)');
        return CarrinhoResult.conflito(CarrinhoConflito.fromJson(responseData));
      }

      // ✅ 2. Trata Sucesso
      if (statusCode == 200 && responseData is Map && responseData['code'] == 200) {
        final resData = CarrinhoResponse.fromJson(responseData['data']);
        return CarrinhoResult.success(resData);
      } 

      // ✅ 3. Erro Genérico na resposta (mas status 200)
      if (responseData is Map && responseData['success'] == false) {
        return CarrinhoResult.error(responseData['message'] ?? 'Erro na operação');
      }

      return CarrinhoResult.error('Erro inesperado: $statusCode');

    } on DioException catch (e) {
      if (kDebugMode) print('❌ [CarrinhoService] DioException: ${e.type} - ${e.response?.statusCode}');
      
      // ✅ Trata 409 vindo como exceção
      if (e.response?.statusCode == 409 || e.response?.data?['code'] == 409) {
        return CarrinhoResult.conflito(CarrinhoConflito.fromJson(e.response?.data));
      }

      return CarrinhoResult.error(
        e.response?.data?['message'] ?? e.message ?? 'Erro de conexão',
        code: e.response?.statusCode,
      );
    } catch (e, stack) {
      if (kDebugMode) print('❌ [CarrinhoService] Erro Fatal: $e\n$stack');
      return CarrinhoResult.error('Ocorreu um erro interno');
    }
  }

  Future<VerificacaoLojaResponse> verificarLoja(int lojaId) async {
    try {
      final response = await _apiClient.get('app/carrinho/verificar-loja', 
        queryParameters: {'loja_id': lojaId}
      );
      return VerificacaoLojaResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<CarrinhoResponse> carregarCarrinho() async {
    final response = await _apiClient.get('app/carrinho');
    return CarrinhoResponse.fromJson(response.data['data']);
  }

  Future<void> limparCarrinho() async {
    await _apiClient.post('app/carrinho/limpar');
  }
}

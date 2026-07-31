import 'package:dio/dio.dart';
import '../../../../shared/api/api_client.dart';
import '../models/endereco_model.dart';

class EnderecoService {
  final ApiClient _apiClient;

  EnderecoService(this._apiClient);

  /// Lista todos os endereços do usuário
  Future<List<EnderecoModel>> getEnderecos() async {
    final response = await _apiClient.get('/app/enderecos');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final list = response.data['data'] as List;
      return list.map((json) => EnderecoModel.fromJson(json)).toList();
    }
    throw Exception('Erro ao carregar endereços');
  }

  /// Cria um novo endereço
  Future<EnderecoModel> criarEndereco(EnderecoModel endereco) async {
    final response = await _apiClient.post(
      '/app/enderecos',
      data: endereco.toJson(),
    );
    if ((response.statusCode == 201 || response.statusCode == 200) && response.data['success'] == true) {
      return EnderecoModel.fromJson(response.data['data']);
    }
    throw Exception('Erro ao criar endereço');
  }

  /// Atualiza um endereço
  Future<EnderecoModel> atualizarEndereco(EnderecoModel endereco) async {
    final response = await _apiClient.put(
      '/app/enderecos/${endereco.id}',
      data: endereco.toJson(),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return EnderecoModel.fromJson(response.data['data']);
    }
    throw Exception('Erro ao atualizar endereço');
  }

  /// Remove um endereço
  Future<void> deletarEndereco(int id) async {
    final response = await _apiClient.delete('/app/enderecos/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao excluir endereço');
    }
  }

  /// Define um endereço como principal
  Future<EnderecoModel> definirPrincipal(int id) async {
    final response = await _apiClient.put(
      '/app/enderecos/$id/principal',
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return EnderecoModel.fromJson(response.data['data']);
    }
    throw Exception('Erro ao definir endereço principal');
  }

  /// Busca CEP via ViaCEP
  Future<Map<String, String>> buscarCep(String cep) async {
    try {
      final response = await Dio().get(
        'https://viacep.com.br/ws/$cep/json/',
      );
      if (response.data['erro'] == true) {
        throw Exception('CEP não encontrado');
      }
      return {
        'cep': response.data['cep'] ?? '',
        'logradouro': response.data['logradouro'] ?? '',
        'bairro': response.data['bairro'] ?? '',
        'cidade': response.data['localidade'] ?? '',
        'uf': response.data['uf'] ?? '',
      };
    } catch (e) {
      throw Exception('Erro ao buscar CEP: $e');
    }
  }
}

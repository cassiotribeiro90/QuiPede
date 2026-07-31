import '../models/endereco_model.dart';
import '../services/endereco_service.dart';

class EnderecoRepository {
  final EnderecoService _service;

  EnderecoRepository(this._service);

  Future<List<EnderecoModel>> getEnderecos() => _service.getEnderecos();
  Future<EnderecoModel> criarEndereco(EnderecoModel endereco) => _service.criarEndereco(endereco);
  Future<EnderecoModel> atualizarEndereco(EnderecoModel endereco) => _service.atualizarEndereco(endereco);
  Future<void> deletarEndereco(int id) => _service.deletarEndereco(id);
  Future<EnderecoModel> definirPrincipal(int id) => _service.definirPrincipal(id);
  Future<Map<String, String>> buscarCep(String cep) => _service.buscarCep(cep);
}

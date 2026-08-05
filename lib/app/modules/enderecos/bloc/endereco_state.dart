import 'package:quipede/app/modules/enderecos/models/endereco_model.dart';

abstract class EnderecoState {
  const EnderecoState();
}

class EnderecoInitial extends EnderecoState {}

class EnderecoLoading extends EnderecoState {}

class EnderecoLoaded extends EnderecoState {
  final List<EnderecoModel> enderecos;
  final EnderecoModel? enderecoPrincipal;

  const EnderecoLoaded(this.enderecos, {this.enderecoPrincipal});
}

class EnderecoError extends EnderecoState {
  final String message;
  const EnderecoError(this.message);
}

// ✅ Estado específico: endereço atualizado com sucesso
class EnderecoAtualizado extends EnderecoState {
  final EnderecoModel endereco;
  const EnderecoAtualizado(this.endereco);
}

// ✅ Estado específico: endereço excluído com sucesso
class EnderecoExcluido extends EnderecoState {
  final int id;
  const EnderecoExcluido(this.id);
}

// ✅ Estado específico: principal definido com sucesso
class EnderecoPrincipalDefinido extends EnderecoState {
  final int id;
  const EnderecoPrincipalDefinido(this.id);
}

// ✅ Estado específico: endereço criado com sucesso
class EnderecoCriado extends EnderecoState {
  final EnderecoModel endereco;
  const EnderecoCriado(this.endereco);
}

class EnderecoCepBuscando extends EnderecoState {}

class EnderecoCepCarregado extends EnderecoState {
  final Map<String, String> dadosCep;
  const EnderecoCepCarregado(this.dadosCep);
}
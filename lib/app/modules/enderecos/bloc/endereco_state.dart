import 'package:equatable/equatable.dart';
import '../models/endereco_model.dart';

abstract class EnderecoState extends Equatable {
  const EnderecoState();
  @override
  List<Object?> get props => [];
}

class EnderecoInitial extends EnderecoState {}

class EnderecoLoading extends EnderecoState {}

class EnderecoLoaded extends EnderecoState {
  final List<EnderecoModel> enderecos;
  final EnderecoModel? enderecoPrincipal;
  const EnderecoLoaded(this.enderecos, {this.enderecoPrincipal});
  @override
  List<Object?> get props => [enderecos, enderecoPrincipal];
}

class EnderecoOperacaoSucesso extends EnderecoState {
  final String mensagem;
  const EnderecoOperacaoSucesso(this.mensagem);
  @override
  List<Object> get props => [mensagem];
}

class EnderecoError extends EnderecoState {
  final String message;
  const EnderecoError(this.message);
  @override
  List<Object> get props => [message];
}

class EnderecoCepBuscando extends EnderecoState {}

class EnderecoCepCarregado extends EnderecoState {
  final Map<String, String> dados;
  const EnderecoCepCarregado(this.dados);
  @override
  List<Object> get props => [dados];
}

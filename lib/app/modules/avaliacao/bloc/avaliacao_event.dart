part of 'avaliacao_bloc.dart';

abstract class AvaliacaoEvent extends Equatable {
  const AvaliacaoEvent();

  @override
  List<Object?> get props => [];
}

// ================================================================
// 🔥 CLIENTE
// ================================================================

class CarregarMinhasAvaliacoes extends AvaliacaoEvent {}

class CarregarAvaliacaoLoja extends AvaliacaoEvent {
  final int lojaId;
  const CarregarAvaliacaoLoja(this.lojaId);

  @override
  List<Object?> get props => [lojaId];
}

class CarregarAvaliacaoProduto extends AvaliacaoEvent {
  final int produtoId;
  const CarregarAvaliacaoProduto(this.produtoId);

  @override
  List<Object?> get props => [produtoId];
}

class CarregarAvaliacaoPedido extends AvaliacaoEvent {
  final int pedidoId;
  const CarregarAvaliacaoPedido(this.pedidoId);

  @override
  List<Object?> get props => [pedidoId];
}

class CriarAvaliacao extends AvaliacaoEvent {
  final Map<String, dynamic> data;
  const CriarAvaliacao(this.data);

  @override
  List<Object?> get props => [data];
}

class AtualizarAvaliacao extends AvaliacaoEvent {
  final int id;
  final Map<String, dynamic> data;
  const AtualizarAvaliacao(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeletarAvaliacao extends AvaliacaoEvent {
  final int id;
  const DeletarAvaliacao(this.id);

  @override
  List<Object?> get props => [id];
}

// ================================================================
// 🔥 LOJISTA
// ================================================================

class CarregarAvaliacoesLojista extends AvaliacaoEvent {}

class CarregarResumoAvaliacoesLojista extends AvaliacaoEvent {}

class ResponderAvaliacao extends AvaliacaoEvent {
  final int id;
  final String resposta;
  const ResponderAvaliacao(this.id, this.resposta);

  @override
  List<Object?> get props => [id, resposta];
}

class AtualizarStatusAvaliacao extends AvaliacaoEvent {
  final int id;
  final String status;
  const AtualizarStatusAvaliacao(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

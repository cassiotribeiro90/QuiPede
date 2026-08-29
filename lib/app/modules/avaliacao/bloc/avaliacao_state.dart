part of 'avaliacao_bloc.dart';

abstract class AvaliacaoState extends Equatable {
  const AvaliacaoState();

  @override
  List<Object?> get props => [];
}

class AvaliacaoInitial extends AvaliacaoState {}

class AvaliacaoLoading extends AvaliacaoState {}

class AvaliacaoLoaded extends AvaliacaoState {
  final List<AvaliacaoModel> avaliacoes;
  const AvaliacaoLoaded({required this.avaliacoes});

  @override
  List<Object?> get props => [avaliacoes];
}

class AvaliacaoLojaLoaded extends AvaliacaoState {
  final double media;
  final int total;
  final Map<int, int> distribuicao;
  final List<AvaliacaoModel> avaliacoes;
  const AvaliacaoLojaLoaded({
    required this.media,
    required this.total,
    required this.distribuicao,
    required this.avaliacoes,
  });

  @override
  List<Object?> get props => [media, total, distribuicao, avaliacoes];
}

class AvaliacaoProdutoLoaded extends AvaliacaoState {
  final double media;
  final int total;
  final Map<int, int> distribuicao;
  final List<AvaliacaoModel> avaliacoes;
  const AvaliacaoProdutoLoaded({
    required this.media,
    required this.total,
    required this.distribuicao,
    required this.avaliacoes,
  });

  @override
  List<Object?> get props => [media, total, distribuicao, avaliacoes];
}

class AvaliacaoPedidoLoaded extends AvaliacaoState {
  final AvaliacaoModel avaliacao;
  const AvaliacaoPedidoLoaded({required this.avaliacao});

  @override
  List<Object?> get props => [avaliacao];
}

class AvaliacaoPedidoVazio extends AvaliacaoState {}

class AvaliacaoCreated extends AvaliacaoState {
  final AvaliacaoModel avaliacao;
  const AvaliacaoCreated({required this.avaliacao});

  @override
  List<Object?> get props => [avaliacao];
}

class AvaliacaoUpdated extends AvaliacaoState {
  final AvaliacaoModel avaliacao;
  const AvaliacaoUpdated({required this.avaliacao});

  @override
  List<Object?> get props => [avaliacao];
}

class AvaliacaoDeleted extends AvaliacaoState {}

// ================================================================
// 🔥 LOJISTA
// ================================================================

class AvaliacaoLojistaLoaded extends AvaliacaoState {
  final List<AvaliacaoModel> avaliacoes;
  const AvaliacaoLojistaLoaded({required this.avaliacoes});

  @override
  List<Object?> get props => [avaliacoes];
}

class AvaliacaoResumoLoaded extends AvaliacaoState {
  final ResumoAvaliacaoModel resumo;
  const AvaliacaoResumoLoaded({required this.resumo});

  @override
  List<Object?> get props => [resumo];
}

class AvaliacaoRespondida extends AvaliacaoState {
  final AvaliacaoModel avaliacao;
  const AvaliacaoRespondida({required this.avaliacao});

  @override
  List<Object?> get props => [avaliacao];
}

class AvaliacaoStatusUpdated extends AvaliacaoState {
  final AvaliacaoModel avaliacao;
  const AvaliacaoStatusUpdated({required this.avaliacao});

  @override
  List<Object?> get props => [avaliacao];
}

class AvaliacaoError extends AvaliacaoState {
  final String message;
  const AvaliacaoError({required this.message});

  @override
  List<Object?> get props => [message];
}

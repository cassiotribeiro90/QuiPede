import 'package:equatable/equatable.dart';
import '../../../models/avaliacao_model.dart';

abstract class LojaAvaliacoesState extends Equatable {
  const LojaAvaliacoesState();

  @override
  List<Object> get props => [];
}

class LojaAvaliacoesInitial extends LojaAvaliacoesState {}

class LojaAvaliacoesLoading extends LojaAvaliacoesState {}

class LojaAvaliacoesLoaded extends LojaAvaliacoesState {
  final List<Avaliacao> avaliacoes;

  const LojaAvaliacoesLoaded(this.avaliacoes);

  @override
  List<Object> get props => [avaliacoes];
}

class LojaAvaliacoesError extends LojaAvaliacoesState {
  final String message;

  const LojaAvaliacoesError(this.message);

  @override
  List<Object> get props => [message];
}

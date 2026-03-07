import 'package:equatable/equatable.dart';
import '../../../models/loja_model.dart';

abstract class LojasState extends Equatable {
  const LojasState();

  @override
  List<Object> get props => [];
}

class LojasInitial extends LojasState {}

class LojasLoading extends LojasState {}

class LojasLoaded extends LojasState {
  final List<Loja> lojas;

  const LojasLoaded(this.lojas);

  @override
  List<Object> get props => [lojas];
}

class LojasError extends LojasState {
  final String message;

  const LojasError(this.message);

  @override
  List<Object> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class LojaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LojaInitial extends LojaState {}

class LojaLoading extends LojaState {}

class LojaSuccess extends LojaState {
  final String message;
  LojaSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class LojaError extends LojaState {
  final String error;
  LojaError(this.error);

  @override
  List<Object?> get props => [error];
}

class LojasLoaded extends LojaState {
  final List<dynamic> lojas;
  LojasLoaded(this.lojas);

  @override
  List<Object?> get props => [lojas];
}

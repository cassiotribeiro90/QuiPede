import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  AuthAuthenticated(this.token);

  @override
  List<Object?> get props => [token];
}

class AuthUnauthenticated extends AuthState {
  final String? message;
  AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthTokenExpiringSoon extends AuthState {
  final int secondsRemaining;
  AuthTokenExpiringSoon(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}

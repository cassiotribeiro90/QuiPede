import 'package:equatable/equatable.dart';
import '../models/usuario_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthChecking extends AuthState {}
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String accessToken;
  final UsuarioModel? user;
  const AuthAuthenticated({required this.accessToken, this.user});

  @override
  List<Object?> get props => [accessToken, user];
}

class AuthGuest extends AuthState {
  final String accessToken;
  final UsuarioModel? user;
  const AuthGuest({required this.accessToken, this.user});

  @override
  List<Object?> get props => [accessToken, user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Estados para o Fluxo OTP ---

class AuthPhoneEnviado extends AuthState {
  final String telefone;
  const AuthPhoneEnviado({required this.telefone});
  @override
  List<Object?> get props => [telefone];
}

class AuthOtpVerificando extends AuthState {
  final String telefone;
  const AuthOtpVerificando({required this.telefone});
  @override
  List<Object?> get props => [telefone];
}

class AuthOtpErro extends AuthState {
  final String mensagem;
  const AuthOtpErro(this.mensagem);
  @override
  List<Object?> get props => [mensagem];
}

// ✅ Novo estado: perfil completado com sucesso
class AuthPerfilCompleto extends AuthState {
  final String accessToken;
  final UsuarioModel user;
  const AuthPerfilCompleto({required this.accessToken, required this.user});

  @override
  List<Object?> get props => [accessToken, user];
}
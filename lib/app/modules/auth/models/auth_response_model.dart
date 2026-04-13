import 'usuario_model.dart';

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final UsuarioModel user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'] ?? 7200,
      user: UsuarioModel.fromJson(json['user'] ?? json),
    );
  }
}

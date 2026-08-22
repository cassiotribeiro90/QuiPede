import 'package:equatable/equatable.dart';
import 'usuario_model.dart';
// 🔥 IMPORT CORRETO
import '../../enderecos/models/endereco_model.dart';

class AuthResponse extends Equatable {
  final UsuarioModel user;
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final EnderecoModel? endereco;
  final String? deviceId;
  final String? deviceToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.endereco,
    this.deviceId,
    this.deviceToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UsuarioModel.fromJson(json['user'] ?? json['usuario'] ?? {}),
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      endereco: json['endereco'] != null
          ? EnderecoModel.fromJson(json['endereco'])
          : null,
      deviceId: json['device_id'] as String?,
      deviceToken: json['device_token'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        user,
        accessToken,
        refreshToken,
        expiresIn,
        endereco,
        deviceId,
        deviceToken,
      ];
}

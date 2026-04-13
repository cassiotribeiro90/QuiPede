import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../shared/api/api_client.dart';
import '../models/auth_response_model.dart';

class SocialAuthService {
  final ApiClient _apiClient;

  SocialAuthService(this._apiClient);

  /// Google Sign-In
  Future<AuthResponse> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    final account = await googleSignIn.signIn();
    if (account == null) throw SocialAuthCanceledException();

    final auth = await account.authentication;
    final idToken = auth.idToken;
    final accessToken = auth.accessToken;

    if (idToken == null && accessToken == null) {
      throw Exception('Token do Google não obtido');
    }

    return _authenticate('google', idToken ?? accessToken!);
  }

  /// Facebook Sign-In
  Future<AuthResponse> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.cancelled) {
      throw SocialAuthCanceledException();
    }

    if (result.status != LoginStatus.success) {
      throw Exception('Login Facebook falhou: ${result.message}');
    }

    final token = result.accessToken!.tokenString;
    return _authenticate('facebook', token);
  }

  /// Apple Sign-In (apenas iOS)
  Future<AuthResponse> signInWithApple() async {
    if (!Platform.isIOS) {
      throw Exception('Apple Sign-In disponível apenas no iOS');
    }

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null) throw Exception('Token Apple não obtido');

    final additionalData = <String, dynamic>{};
    if (credential.givenName != null || credential.familyName != null) {
      additionalData['name'] = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
    }
    if (credential.email != null) {
      additionalData['email'] = credential.email;
    }

    return _authenticate('apple', identityToken, additionalData: additionalData);
  }

  /// Método unificado para chamar o backend
  Future<AuthResponse> _authenticate(
    String provider,
    String token, {
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'provider': provider,
      'token': token,
      if (additionalData != null) 'additionalData': additionalData,
    };

    try {
      final response = await _apiClient.post(
        'app/auth/social', 
        data: data,
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = response.data;
        if (json['success'] == true) {
          return AuthResponse.fromJson(json['data']);
        } else {
          throw Exception(json['message'] ?? 'Erro desconhecido');
        }
      }
      throw Exception('Erro no servidor: ${response.statusCode}');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Falha na conexão. Verifique sua internet.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}

/// Exceção para cancelamento (não deve logar erro)
class SocialAuthCanceledException implements Exception {}

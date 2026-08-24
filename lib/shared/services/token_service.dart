import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  
  static const String accessTokenKey = 'access_token';
  static const String guestTokenKey = 'guest_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiresKey = 'token_expires_at';
  static const String baseUrlKey = 'base_url';
  static const String isGuestKey = 'is_guest';

  late final SharedPreferences _prefs;

  TokenService._internal();

  static Future<void> initialize() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveTokens(
    String accessToken, 
    String? refreshToken, {
    int expiresIn = 7200,
    bool isGuest = false,
  }) async {
    developer.log('💾 [TokenService] Salvando tokens... isGuest: $isGuest', name: 'TOKEN');
    if (isGuest) {
      await _prefs.setString(guestTokenKey, accessToken);
      await _prefs.remove(accessTokenKey);
    } else {
      await _prefs.setString(accessTokenKey, accessToken);
      await _prefs.remove(guestTokenKey);
    }
    
    if (refreshToken != null) {
      await _prefs.setString(refreshTokenKey, refreshToken);
    } else {
      await _prefs.remove(refreshTokenKey);
    }
    
    await _prefs.setBool(isGuestKey, isGuest);
    final expiresAt = DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
    await _prefs.setString(tokenExpiresKey, expiresAt.toString());
    developer.log('✅ [TokenService] Tokens salvos', name: 'TOKEN');
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    developer.log('💾 [TokenService] saveUser chamado com: $userJson', name: 'TOKEN');
    await _prefs.setString(userKey, jsonEncode(userJson));
    developer.log('✅ [TokenService] Usuário salvo', name: 'TOKEN');
  }

  Map<String, dynamic>? getUser() {
    final data = _prefs.getString(userKey);
    developer.log('💾 [TokenService] getUser retornou: ${data != null ? "SIM" : "NÃO"}', name: 'TOKEN');
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      developer.log('❌ [TokenService] Erro ao decodificar user: $e', name: 'TOKEN');
      return null;
    }
  }

  /// Retorna o token disponível, priorizando o de usuário autenticado
  String? getAccessToken() {
    try {
      final token = _prefs.getString(accessTokenKey) ?? _prefs.getString(guestTokenKey);
      final isGuest = _prefs.getBool(isGuestKey) ?? false;
      developer.log('🔑 [TokenService] getAccessToken: ${token != null ? "SIM (${token.substring(0, min(10, token.length))}...)" : "NÃO"} (isGuest: $isGuest)', name: 'TOKEN');
      return token;
    } catch (e) {
      developer.log('❌ [TokenService] Erro ao ler token: $e', name: 'TOKEN');
      return null;
    }
  }

  /// Retorna o token disponível, priorizando o de usuário autenticado
  String? getRefreshToken() {
    try {
      final token = _prefs.getString(refreshTokenKey);
      developer.log('🔑 [TokenService] getRefreshToken: ${token != null ? "SIM (${token.substring(0, min(10, token.length))}...)" : "NÃO"}', name: 'TOKEN');
      return token;
    } catch (e) {
      developer.log('❌ [TokenService] Erro ao ler refresh token: $e', name: 'TOKEN');
      return null;
    }
  }
  
  bool isGuest() => _prefs.getBool(isGuestKey) ?? (_prefs.getString(guestTokenKey) != null);

  Map<String, String> getAuthHeader() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty 
        ? {'Authorization': 'Bearer $token'} 
        : {};
  }

  bool isTokenExpired() {
    final expiresAtStr = _prefs.getString(tokenExpiresKey);
    if (expiresAtStr == null) return true;
    final expiresAt = int.tryParse(expiresAtStr) ?? 0;
    // Margem de segurança de 30 segundos
    return DateTime.now().millisecondsSinceEpoch > (expiresAt - 30000);
  }

  bool hasToken() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Alias para verificar se há um token ativo e não expirado
  bool isLoggedIn() => hasToken() && !isTokenExpired();

  Future<void> saveAccessToken(String token) async {
    developer.log('💾 [TokenService] Salvando access token...', name: 'TOKEN');
    await _prefs.setString(accessTokenKey, token);
    developer.log('✅ [TokenService] Access token salvo', name: 'TOKEN');
  }

  Future<void> clearTokens() async {
    developer.log('🔐 [TokenService] 🧹 Limpando todos os tokens...', name: 'TOKEN');
    await _prefs.remove(accessTokenKey);
    await _prefs.remove(guestTokenKey);
    await _prefs.remove(userKey);
    await _prefs.remove(refreshTokenKey);
    await _prefs.remove(tokenExpiresKey);
    await _prefs.remove(isGuestKey);
    developer.log('🔐 [TokenService] ✅ Todos os tokens removidos', name: 'TOKEN');
  }

  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(baseUrlKey, url);
  }

  String? getBaseUrl() => _prefs.getString(baseUrlKey);

  Future<bool> refreshToken(Dio dio) async {
    try {
      final refreshToken = getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final baseUrl = getBaseUrl() ?? dio.options.baseUrl;
      
      final tempDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await tempDio.post(
        '/app/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['access_token']?.toString() ?? '';
        final newRefreshToken = data['refresh_token']?.toString();
        final expiresIn = data['expires_in'] ?? 900;

        if (newAccessToken.isNotEmpty) {
          // Refresh token geralmente é apenas para usuários autenticados
          await saveTokens(newAccessToken, newRefreshToken, expiresIn: expiresIn, isGuest: false);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

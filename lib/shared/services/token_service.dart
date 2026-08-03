import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  
  static const String ACCESS_TOKEN_KEY = 'access_token';
  static const String GUEST_TOKEN_KEY = 'guest_token'; // 🔥 Chave separada para convidados
  static const String USER_KEY = 'user_data';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const String TOKEN_EXPIRES_KEY = 'token_expires_at';
  static const String BASE_URL_KEY = 'base_url';
  static const String IS_GUEST_KEY = 'is_guest';

  late final SharedPreferences _prefs;

  TokenService._internal();

  static Future<void> initialize() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveTokens(
    String accessToken, 
    String? refreshToken, {
    int expiresIn = 900,
    bool isGuest = false,
    Map<String, dynamic>? userJson,
  }) async {
    if (isGuest) {
      await _prefs.setString(GUEST_TOKEN_KEY, accessToken);
      await _prefs.remove(ACCESS_TOKEN_KEY);
    } else {
      await _prefs.setString(ACCESS_TOKEN_KEY, accessToken);
      await _prefs.remove(GUEST_TOKEN_KEY);
    }
    
    if (userJson != null) {
      await saveUser(userJson);
    }

    if (refreshToken != null) {
      await _prefs.setString(REFRESH_TOKEN_KEY, refreshToken);
    } else {
      await _prefs.remove(REFRESH_TOKEN_KEY);
    }
    
    await _prefs.setBool(IS_GUEST_KEY, isGuest);
    final expiresAt = DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
    await _prefs.setString(TOKEN_EXPIRES_KEY, expiresAt.toString());
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _prefs.setString(USER_KEY, jsonEncode(userJson));
  }

  Map<String, dynamic>? getUser() {
    final data = _prefs.getString(USER_KEY);
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  /// Retorna o token disponível, priorizando o de usuário autenticado
  String? getAccessToken() {
    return _prefs.getString(ACCESS_TOKEN_KEY) ?? _prefs.getString(GUEST_TOKEN_KEY);
  }

  String? getRefreshToken() => _prefs.getString(REFRESH_TOKEN_KEY);
  
  bool isGuest() => _prefs.getBool(IS_GUEST_KEY) ?? (_prefs.getString(GUEST_TOKEN_KEY) != null);

  Map<String, String> getAuthHeader() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty 
        ? {'Authorization': 'Bearer $token'} 
        : {};
  }

  bool isTokenExpired() {
    final expiresAtStr = _prefs.getString(TOKEN_EXPIRES_KEY);
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

  Future<void> clearTokens() async {
    await _prefs.remove(ACCESS_TOKEN_KEY);
    await _prefs.remove(GUEST_TOKEN_KEY);
    await _prefs.remove(USER_KEY);
    await _prefs.remove(REFRESH_TOKEN_KEY);
    await _prefs.remove(TOKEN_EXPIRES_KEY);
    await _prefs.remove(IS_GUEST_KEY);
  }

  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(BASE_URL_KEY, url);
  }

  String? getBaseUrl() => _prefs.getString(BASE_URL_KEY);

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

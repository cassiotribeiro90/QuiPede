import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/token_service.dart';
import 'interceptors/refresh_interceptor.dart';

class ApiClient {
  // 🔥 Singleton manual igual ao gestor
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late final TokenService _tokenService;
  late final Dio _dio;
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ApiClient._internal() {
    _tokenService = TokenService();
    
    const String baseUrlEnv = String.fromEnvironment('API_URL');
    
    final options = BaseOptions(
      baseUrl: baseUrlEnv.isNotEmpty 
          ? baseUrlEnv 
          : (kIsWeb 
               ? 'http://localhost:8001/api/'
              : (defaultTargetPlatform == TargetPlatform.android 
                  ? 'http://10.0.2.2:8001/api/'
                  : 'http://localhost:8001/api/')),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        // ✅ Aceita 409 como resposta válida (não lança exceção automaticamente)
        return status != null && (status < 500 || status == 409);
      },
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    );

    _dio = Dio(options);
    
    _dio.interceptors.add(RefreshInterceptor(
      dio: _dio,
      tokenService: _tokenService,
      navigatorKey: navigatorKey,
    ));
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true, 
        requestBody: true,
        requestHeader: true,
      ));
    }
  }
  
  Future<Response> post(
    String path, {
    dynamic data, 
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true
  }) => _dio.post(
    path, 
    data: data, 
    queryParameters: queryParameters,
    options: Options(extra: {'requiresAuth': requiresAuth})
  );
      
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters, 
    bool requiresAuth = true
  }) => _dio.get(
    path, 
    queryParameters: queryParameters,
    options: Options(extra: {'requiresAuth': requiresAuth})
  );
      
  Future<Response> put(String path, {dynamic data, bool requiresAuth = true}) => 
      _dio.put(path, data: data, options: Options(extra: {'requiresAuth': requiresAuth}));
      
  Future<Response> delete(String path, {bool requiresAuth = true}) =>
      _dio.delete(path, options: Options(extra: {'requiresAuth': requiresAuth}));

  Dio get dio => _dio;
  TokenService get tokenService => _tokenService;
}

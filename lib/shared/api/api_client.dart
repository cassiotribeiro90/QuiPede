import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/device_id_service.dart';
import 'interceptors/refresh_interceptor.dart';

class ApiClient {
  // 🔥 Singleton manual
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
        // ✅ Deixa o RefreshInterceptor tratar o 401 (lançando exceção)
        // ✅ Aceita 409 como resposta de negócio válida
        return status != null && ((status >= 200 && status < 300) || status == 409);
      },
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    _dio = Dio(options);

    // 🔥 INTERCEPTOR PARA ADICIONAR DEVICE_ID EM TODAS AS REQUISIÇÕES
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adiciona device_id no header
          final deviceId = await DeviceIdService.getDeviceId();
          options.headers['X-Device-Id'] = deviceId;

          // 🔥 LOG DETALHADO DA REQUISIÇÃO
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('📤 [ApiClient] ENVIANDO REQUISIÇÃO');
          debugPrint('📤 URL: ${options.baseUrl}${options.path}');
          debugPrint('📤 Método: ${options.method}');
          debugPrint('📤 Headers: ${options.headers}');
          debugPrint('📤 Requer autenticação? ${options.extra['requiresAuth']}');
          if (options.data != null) {
            debugPrint('📤 Body: ${options.data}');
          }
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 🔥 LOG DETALHADO DA RESPOSTA
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('📥 [ApiClient] RESPOSTA RECEBIDA');
          debugPrint('📥 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
          debugPrint('📥 Status: ${response.statusCode}');
          debugPrint('📥 Headers: ${response.headers.map}');
          if (response.data != null) {
            debugPrint('📥 Body: ${response.data}');
          }
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          return handler.next(response);
        },
        onError: (error, handler) async {
          // 🔥 LOG DETALHADO DO ERRO
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('❌ [ApiClient] ERRO NA REQUISIÇÃO');
          debugPrint('❌ URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
          debugPrint('❌ Método: ${error.requestOptions.method}');
          debugPrint('❌ Tipo: ${error.type}');
          debugPrint('❌ Mensagem: ${error.message}');
          if (error.response != null) {
            debugPrint('❌ Status Code: ${error.response?.statusCode}');
            debugPrint('❌ Response Body: ${error.response?.data}');
          }
          debugPrint('❌ Stack Trace: ${error.stackTrace}');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          // Se houver erro, tenta novamente com o device_id (caso não tenha sido enviado)
          if (error.requestOptions.headers['X-Device-Id'] == null) {
            final deviceId = await DeviceIdService.getDeviceId();
            error.requestOptions.headers['X-Device-Id'] = deviceId;
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 🔥 REFRESH INTERCEPTOR (TOKEN)
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
        bool requiresAuth = true,
      }) => _dio.post(
    path,
    data: data,
    queryParameters: queryParameters,
    options: Options(extra: {'requiresAuth': requiresAuth}),
  );

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        bool requiresAuth = true,
      }) => _dio.get(
    path,
    queryParameters: queryParameters,
    options: Options(extra: {'requiresAuth': requiresAuth}),
  );

  Future<Response> put(
      String path, {
        dynamic data,
        bool requiresAuth = true,
      }) => _dio.put(
    path,
    data: data,
    options: Options(extra: {'requiresAuth': requiresAuth}),
  );

  Future<Response> delete(
      String path, {
        bool requiresAuth = true,
      }) => _dio.delete(
    path,
    options: Options(extra: {'requiresAuth': requiresAuth}),
  );

  Dio get dio => _dio;
  TokenService get tokenService => _tokenService;
}
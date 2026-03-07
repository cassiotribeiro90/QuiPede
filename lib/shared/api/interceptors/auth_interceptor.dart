import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/di/dependencies.dart';
import '../../../features/auth/bloc/auth_cubit.dart';

class AuthInterceptor extends Interceptor {
  final List<_PendingRequest> _pendingRequests = [];
  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final prefs = getIt<SharedPreferences>();
    final token = prefs.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add(_PendingRequest(err, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final success = await _refreshToken();
      
      if (success) {
        final prefs = getIt<SharedPreferences>();
        final newToken = prefs.getString('access_token');
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);

        await _retryFailedRequests();
      } else {
        _logout();
        handler.next(err);
      }
    } catch (e) {
      _logout();
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) return false;

      // TODO: Implementar chamada real de refresh token com o endpoint Yii2
      // final response = await Dio().post('${EnvConfig.baseUrl}/auth-lojista/refresh', data: {'refresh_token': refreshToken});
      // if (response.statusCode == 200) {
      //   await prefs.setString('access_token', response.data['access_token']);
      //   return true;
      // }
      
      return false; 
    } catch (e) {
      return false;
    }
  }

  Future<void> _retryFailedRequests() async {
    final prefs = getIt<SharedPreferences>();
    final token = prefs.getString('access_token');

    for (var request in _pendingRequests) {
      request.err.requestOptions.headers['Authorization'] = 'Bearer $token';
      try {
        final response = await Dio().fetch(request.err.requestOptions);
        request.handler.resolve(response);
      } catch (e) {
        request.handler.reject(DioException(requestOptions: request.err.requestOptions));
      }
    }
  }

  void _logout() {
    // Agora usando o AuthCubit para centralizar o estado de deslogado
    getIt<AuthCubit>().logout(message: 'Sessão expirada. Por favor, faça login novamente.');
  }
}

class _PendingRequest {
  final DioException err;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.err, this.handler);
}

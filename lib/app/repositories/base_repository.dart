import 'package:dio/dio.dart';
import '../../shared/api/api_client.dart';

abstract class BaseRepository {
  final Dio dio = ApiClient().dio;

  Exception handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          return Exception(message);
        }
      }
      return Exception(e.message ?? 'Erro desconhecido na API');
    }
    return Exception(e.toString());
  }
}

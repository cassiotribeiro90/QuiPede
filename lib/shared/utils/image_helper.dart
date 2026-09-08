import '../../app/core/constants/app_constants.dart';

class ImageHelper {
  /// 🔥 Converte caminho relativo para URL completa
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConstants.imageBaseUrl}/$cleanPath';
  }
}
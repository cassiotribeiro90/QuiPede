import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // ================================================================
  // 🔥 URL BASE DA API
  // ================================================================

  static String get apiBaseUrl {
    const String envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8001/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001/api';
    }

    return 'http://localhost:8001/api';
  }

  // 🔥 URL BASE PARA IMAGENS (SEM /api)
  static String get imageBaseUrl {
    String base = apiBaseUrl;
    if (base.endsWith('/api/')) {
      base = base.substring(0, base.length - 5);
    } else if (base.endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }
    return base;
  }
}
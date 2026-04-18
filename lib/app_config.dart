import 'package:flutter/foundation.dart';

class AppConfig {
  static const String LOGIN = 'app/auth/login';
  static const String VALIDAR_ETAPA1 = 'app/cadastro/validar-etapa1';
  static const String CADASTRAR = 'app/cadastro/cadastrar';
  static const String BUSCAR_CEP = 'app/cadastro/buscar-cep';
  static const String GEOCODIFICAR = 'app/localizacao/geocodificar';
  static const String BUSCAR_ENDERECO = 'app/localizacao/buscar-endereco';
  static const String REFRESH_TOKEN = 'app/auth/refresh-token';

  static String get baseUrl {
    // 1. Variável de ambiente via --dart-define=API_URL=...
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl.endsWith('/') ? envUrl : '$envUrl/';
    
    // 2. Definir seu IP manual para testes em dispositivos reais aqui:
    const myIp = '192.168.1.5'; // ← Troque pelo IP do seu PC se necessário

    // Web
    if (kIsWeb) return 'http://localhost:8001/api/';
    
    // Android Emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (myIp != 'localhost') return 'http://$myIp:8001/api/';
      return 'http://10.0.2.2:8001/api/';
    }
    
    // Desktop (Windows) e outros
    return 'http://localhost:8001/api/';
  }
}


enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment environment = Environment.dev;

  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost/qui-backend/web'; // Ajuste conforme seu backend
      case Environment.staging:
        return 'https://api.staging.quigestor.com';
      case Environment.prod:
        return 'https://api.quigestor.com';
    }
  }

  static const int tokenExpirationTime = 60; // 1 minuto para testes
}

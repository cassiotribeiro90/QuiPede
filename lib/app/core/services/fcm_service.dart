import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../storage/auth_storage.dart';
import 'device_service.dart';
import '../../../app_config.dart';

/// Serviço para gerenciar FCM e notificações push
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? _token;
  bool _isInitialized = false;

  /// 🔥 INICIALIZA O FCM E OBTÉM O TOKEN
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Solicita permissão
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('[FCM] ❌ Permissão negada');
        return;
      }

      // Obtém o token
      _token = await _fcm.getToken();
      print('[FCM] 📱 Token: $_token');

      // 🔥 ESCUTA MENSAGENS EM FOREGROUND
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('[FCM] 📨 Mensagem recebida: ${message.notification?.title}');
        _showInAppNotification(message);
      });

      // 🔥 ESCUTA QUANDO O APP É ABERTO POR NOTIFICAÇÃO
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('[FCM] 📨 App aberto por notificação');
        _handleNotificationTap(message);
      });

      // 🔥 TOKEN REFRESH
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('[FCM] 🔄 Token atualizado: $newToken');
        _token = newToken;
        _sendTokenToBackend(newToken);
      });

      _isInitialized = true;
      print('[FCM] ✅ Inicializado com sucesso');

    } catch (e) {
      print('[FCM] ❌ Erro: $e');
    }
  }

  /// 🔥 ENVIA O TOKEN PARA O BACKEND (chamado após login)
  Future<void> sendTokenToBackend(String authToken) async {
    if (_token == null) {
      _token = await _fcm.getToken();
    }
    if (_token != null) {
      await _sendTokenToBackend(_token!);
    }
  }

  /// 🔥 ENVIA O TOKEN PARA O BACKEND
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final authToken = await AuthStorage().getAccessToken();
      if (authToken == null) {
        print('[FCM] ⚠️ Usuário não autenticado');
        return;
      }

      final deviceId = await DeviceService().getDeviceId();

      final dio = Dio();
      await dio.post(
        '${AppConfig.baseUrl}app/auth/device-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'device_token': token,
          'device_id': deviceId,
        },
      );
      print('[FCM] ✅ Token enviado ao backend');
    } catch (e) {
      print('[FCM] ❌ Erro ao enviar token: $e');
    }
  }

  /// 🔥 MOSTRA NOTIFICAÇÃO IN-APP (FOREGROUND)
  void _showInAppNotification(RemoteMessage message) {
    // Implementar com flutter_local_notifications ou overlay
    print('[FCM] 🔔 ${message.notification?.title}: ${message.notification?.body}');
  }

  /// 🔥 NAVEGA PARA A TELA CORRETA AO CLICAR NA NOTIFICAÇÃO
  void _handleNotificationTap(RemoteMessage message) {
    final pedidoId = message.data['pedido_id'];
    if (pedidoId != null) {
      // Navegar para a tela de pedidos
    }
  }

  /// 🔥 GETTER
  String? get token => _token;
}

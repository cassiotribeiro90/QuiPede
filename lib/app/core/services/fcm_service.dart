import 'dart:io';
import 'package:flutter/foundation.dart';
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

  /// 🔥 INICIALIZA OS LISTENERS DO FCM (Não bloqueia a UI)
  Future<void> init() async {
    if (!kIsWeb && Platform.isWindows) {
      debugPrint('[FCM] ⏳ Windows não suporta Firebase Messaging');
      return;
    }

    if (_isInitialized) return;

    try {
      // 🔥 ESCUTA MENSAGENS EM FOREGROUND
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] 📨 Mensagem recebida: ${message.notification?.title}');
        _showInAppNotification(message);
      });

      // 🔥 ESCUTA QUANDO O APP É ABERTO POR NOTIFICAÇÃO
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM] 📨 App aberto por notificação');
        _handleNotificationTap(message);
      });

      // 🔥 TOKEN REFRESH
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] 🔄 Token atualizado: $newToken');
        _token = newToken;
        _sendTokenToBackend(newToken);
      });

      _isInitialized = true;
      debugPrint('[FCM] ✅ Listeners configurados');
    } catch (e) {
      debugPrint('[FCM] ❌ Erro ao configurar listeners: $e');
    }
  }

  /// 🔥 SOLICITA PERMISSÃO E OBTÉM O TOKEN (Chamado após o carregamento da UI)
  Future<bool> requestPermissionAndGetToken() async {
    try {
      if (!kIsWeb && Platform.isWindows) return false;

      debugPrint('[FCM] 🔔 Solicitando permissão de notificação...');
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _token = await _fcm.getToken();
        debugPrint('[FCM] ✅ Permissão concedida. Token: $_token');
        return true;
      } else {
        debugPrint('[FCM] ❌ Permissão negada ou restrita');
        return false;
      }
    } catch (e) {
      debugPrint('[FCM] ❌ Erro ao solicitar permissão: $e');
      return false;
    }
  }

  /// 🔥 ENVIA O TOKEN PARA O BACKEND (chamado após login)
  Future<void> sendTokenToBackend(String authToken) async {
    if (!kIsWeb && Platform.isWindows) return;

    _token ??= await _fcm.getToken();
    if (_token != null) {
      await _sendTokenToBackend(_token!);
    }
  }

  /// 🔥 ENVIA O TOKEN PARA O BACKEND
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final authToken = await AuthStorage().getAccessToken();
      if (authToken == null) return;

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
      debugPrint('[FCM] ✅ Token enviado ao backend');
    } catch (e) {
      debugPrint('[FCM] ❌ Erro ao enviar token: $e');
    }
  }

  /// 🔥 MOSTRA NOTIFICAÇÃO IN-APP (FOREGROUND)
  void _showInAppNotification(RemoteMessage message) {
    debugPrint('[FCM] 🔔 ${message.notification?.title}: ${message.notification?.body}');
  }

  /// 🔥 NAVEGA PARA A TELA CORRETA AO CLICAR NA NOTIFICAÇÃO
  void _handleNotificationTap(RemoteMessage message) {
    final pedidoId = message.data['pedido_id'];
    if (pedidoId != null) {
      // Implementar navegação
    }
  }

  /// 🔥 GETTER
  String? get token => _token;
}

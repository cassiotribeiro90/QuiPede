import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:go_router/go_router.dart';
import '../../shared/api/api_client.dart';
import '../../shared/services/token_service.dart';
import '../core/services/device_service.dart';
import '../../../app_config.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔥 [PushService] Background message received: ${message.messageId}');
}

class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  // Streams para eventos
  final _pedidoStatusController = BehaviorSubject<PedidoStatusEvent>();
  Stream<PedidoStatusEvent> get onPedidoStatus => _pedidoStatusController.stream;

  final _notificationController = BehaviorSubject<RemoteMessage>();
  Stream<RemoteMessage> get onNotificationReceived => _notificationController.stream;

  // Controle de polling/websocket
  Timer? _pollingTimer;
  WebSocketChannel? _webSocketChannel;
  bool _isWebSocketConnected = false;

  // Notificações locais (fallback)
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicialização principal – detecta plataforma e configura o método adequado
  Future<void> init() async {
    if (_isInitialized) return;
    
    debugPrint('🚀 [PushService] Inicializando...');

    // Inicializa notificações locais (para fallback e heads-up no Android)
    await _initLocalNotifications();

    if (kIsWeb) {
      // Web: usa FCM apenas em foreground + fallback polling
      await _initWeb();
    } else if (UniversalPlatform.isWindows) {
      // Windows: sem FCM, usa WebSocket + notificações locais
      await _initWindows();
    } else if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      // Android/iOS: FCM completo
      await _initMobile();
    }

    // Monitora conectividade para reconectar WebSocket
    Connectivity().onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) return;
      _reconnectIfNeeded();
    });

    _isInitialized = true;
    debugPrint('✅ [PushService] Inicializado para ${UniversalPlatform.isWindows ? 'Windows' : kIsWeb ? 'Web' : 'Mobile'}');

    // 🔥 Tenta obter token e enviar se já estiver logado
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS || kIsWeb) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _token = token;
        if (TokenService().hasToken()) {
          debugPrint('📤 [PushService] Usuário logado detectado, enviando token inicial...');
          await _sendTokenToBackend(token);
        } else {
          debugPrint('⏳ [PushService] Usuário não logado, adiando envio do token.');
        }
      }
    }
  }

  // ======================== MOBILE (Android/iOS) ========================

  Future<void> _initMobile() async {
    // Listeners FCM
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Mensagem inicial (app terminado)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenApp(initialMessage);
    }

    // Atualizar token quando renovado
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 [PushService] Token renovado pelo FCM');
      _token = newToken;
      _sendTokenToBackend(newToken);
    });

    // Obter token inicial se autorizado
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.instance.getToken().then((value) {
        if (value != null) {
          _token = value;
          debugPrint('🔑 [PushService] Token obtido com sucesso');
        }
      });
    }
  }

  String? _token;
  String? get token => _token;

  Future<bool> requestPermissionAndGetToken() async {
    try {
      if (UniversalPlatform.isWindows) return false;

      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _sendTokenToBackend(token);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ [PushService] Erro ao solicitar permissão: $e');
      return false;
    }
  }

  // ======================== WEB ========================

  Future<void> _initWeb() async {
    try {
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } catch (e) {
      debugPrint('FCM na Web não disponível: $e');
    }

    // Fallback: polling a cada 30 segundos
    _startPolling(const Duration(seconds: 30));
  }

  // ======================== WINDOWS ========================

  Future<void> _initWindows() async {
    // Windows não tem FCM. Tentar WebSocket + Polling fallback.
    await _connectWebSocket();
    _startPolling(const Duration(seconds: 20));
  }

  // ======================== WEBSOCKET ========================

  Future<void> _connectWebSocket() async {
    if (!UniversalPlatform.isWindows) return;
    
    final userId = await _getUserId();
    if (userId == null) return;

    final wsUrl = '${AppConfig.baseUrl.replaceFirst('http', 'ws')}ws/pedidos?usuario_id=$userId';
    try {
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isWebSocketConnected = true;

      _webSocketChannel!.stream.listen(
        (dynamic message) {
          _handleWebSocketMessage(message);
        },
        onDone: () {
          _isWebSocketConnected = false;
          Future.delayed(const Duration(seconds: 10), _reconnectIfNeeded);
        },
        onError: (error) {
          _isWebSocketConnected = false;
        },
      );
    } catch (e) {
      debugPrint('WebSocket falhou: $e');
    }
  }

  void _reconnectIfNeeded() {
    if (UniversalPlatform.isWindows && !_isWebSocketConnected) {
      _connectWebSocket();
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final pedidoId = data['pedido_id']?.toString();
      final status = data['status'];
      if (pedidoId != null && status != null) {
        _pedidoStatusController.add(PedidoStatusEvent(
          pedidoId: pedidoId,
          status: status,
          rawData: data,
        ));
        _showLocalNotification(
          'Atualização do Pedido',
          'O pedido #$pedidoId mudou para $status',
          payload: pedidoId,
        );
      }
    } catch (e) {
      debugPrint('Erro ao processar mensagem WebSocket: $e');
    }
  }

  // ======================== POLLING (FALLBACK) ========================

  void _startPolling(Duration interval) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (timer) {
      // Emite evento de refresh para a UI forçar recarregamento se necessário
      _pedidoStatusController.add(PedidoStatusEvent(
        pedidoId: 'polling',
        status: 'refresh',
        rawData: {},
      ));
    });
  }

  // ======================== NOTIFICAÇÕES LOCAIS ========================

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const LinuxInitializationSettings linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');
    
    // Windows settings might require additional setup but we'll use a basic one
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );
    
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handleNotificationPayload(details.payload!);
        }
      },
    );
  }

  Future<void> _showLocalNotification(String title, String body, {String? payload}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pedido_channel',
      'Atualizações de Pedido',
      channelDescription: 'Canal para atualizações de status de pedidos',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ======================== HANDLERS ========================

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📩 [PushService] Foreground message: ${message.notification?.title}');
    _notificationController.add(message);
    _processMessage(message);

    // No Android, se estiver em foreground, o sistema não mostra a notificação por padrão.
    // Podemos mostrar uma notificação local ou deixar o App lidar com Snackbar.
    if (UniversalPlatform.isAndroid && message.notification != null) {
      _showLocalNotification(
        message.notification!.title ?? 'QuiPede',
        message.notification!.body ?? '',
        payload: message.data['pedido_id'],
      );
    }
  }

  void _handleOpenApp(RemoteMessage message) {
    debugPrint('app aberto por notificação: ${message.data}');
    _processMessage(message);
    if (message.data['pedido_id'] != null) {
      _handleNotificationPayload(message.data['pedido_id']);
    }
  }

  void _handleNotificationPayload(String pedidoId) {
    final context = ApiClient.navigatorKey.currentContext;
    if (context != null) {
      context.push('/pedidos/detalhe/$pedidoId');
    }
  }

  void _processMessage(RemoteMessage message) {
    final data = message.data;
    final pedidoId = data['pedido_id']?.toString();
    final status = data['status'];
    if (pedidoId != null && status != null) {
      _pedidoStatusController.add(PedidoStatusEvent(
        pedidoId: pedidoId,
        status: status,
        rawData: data,
      ));
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final authToken = TokenService().getAccessToken();
      if (authToken == null) {
        debugPrint('⏳ [PushService] Pulando envio do token: Usuário não logado.');
        return;
      }

      final deviceId = await DeviceService().getDeviceId();
      debugPrint('📤 [PushService] Enviando token para o backend: ${token.substring(0, 10)}...');

      // Usar Dio ou ApiClient
      final dio = ApiClient().dio;
      final response = await dio.post(
        'app/auth/device-token',
        data: {
          'device_token': token,
          'device_id': deviceId,
          'platform': UniversalPlatform.isAndroid 
              ? 'android' 
              : UniversalPlatform.isIOS 
                  ? 'ios' 
                  : UniversalPlatform.isWeb 
                      ? 'web' 
                      : 'windows',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [PushService] Token enviado com sucesso ao backend');
      } else {
        debugPrint('❌ [PushService] Falha ao enviar token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [PushService] Erro ao enviar token: $e');
    }
  }

  Future<String?> _getUserId() async {
    try {
      final userJson = TokenService().getUser();
      if (userJson != null) {
        return userJson['id']?.toString();
      }
    } catch (e) {
      debugPrint('❌ [PushService] Erro ao obter userId: $e');
    }
    return null;
  }

  void dispose() {
    _pollingTimer?.cancel();
    _webSocketChannel?.sink.close(status.goingAway);
    _pedidoStatusController.close();
    _notificationController.close();
  }
}

class PedidoStatusEvent {
  final String pedidoId;
  final String status;
  final Map<String, dynamic> rawData;
  PedidoStatusEvent({required this.pedidoId, required this.status, required this.rawData});
}

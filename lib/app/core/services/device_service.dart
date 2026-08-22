import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Serviço para gerenciar o ID único do dispositivo
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  static const String _keyDeviceId = 'device_id';
  String? _cachedDeviceId;

  /// 🔥 OBTÉM OU CRIA UM DEVICE ID ÚNICO
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4();
      await prefs.setString(_keyDeviceId, deviceId);
      print('[DEVICE] 🔑 Novo device ID gerado: $deviceId');
    } else {
      print('[DEVICE] 🔑 Device ID carregado: $deviceId');
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// 🔥 REMOVE O DEVICE ID (LOGOUT)
  Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeviceId);
    _cachedDeviceId = null;
    print('[DEVICE] 🗑️ Device ID removido');
  }
}

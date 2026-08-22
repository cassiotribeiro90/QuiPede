import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const String _key = 'device_id';
  static String? _cachedDeviceId;

  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) {
      _cachedDeviceId = saved;
      return saved;
    }

    String? deviceId;
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceId = 'web_${webInfo.userAgent?.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Unique ID on Android
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor; // Unique ID on iOS
      }
    } catch (e) {
      debugPrint('❌ [DeviceIdService] Erro ao obter ID do dispositivo: $e');
    }

    // Fallback se falhar ou retornar nulo
    deviceId ??= 'device_${DateTime.now().millisecondsSinceEpoch}';

    _cachedDeviceId = deviceId;
    debugPrint('[DeviceIdService] 🔑 ID gerado/recuperado: $deviceId');
    await prefs.setString(_key, deviceId);
    return deviceId;
  }
}

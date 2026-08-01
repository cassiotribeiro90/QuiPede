import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

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

    // Gera um ID único baseado em timestamp + random
    final deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    _cachedDeviceId = deviceId;
    await prefs.setString(_key, deviceId);
    return deviceId;
  }
}
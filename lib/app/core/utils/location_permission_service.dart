import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationPermissionService {
  /// Verifica se a permissão foi concedida
  static Future<bool> hasPermission() async {
    if (kIsWeb) {
      final status = await Geolocator.checkPermission();
      return status == LocationPermission.whileInUse || status == LocationPermission.always;
    }
    return await ph.Permission.locationWhenInUse.isGranted;
  }

  /// Solicita permissão de localização (multi-plataforma)
  static Future<bool> requestPermission() async {
    try {
      if (!kIsWeb) {
        final status = await ph.Permission.locationWhenInUse.request();
        if (status.isGranted) return true;
        if (status.isPermanentlyDenied) return false;
      }
    } catch (e) {
      debugPrint('Erro ao solicitar permissão via permission_handler: $e');
    }

    // Fallback/Web: tenta via geolocator
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) return false;

      return true;
    } catch (e) {
      debugPrint('Erro ao solicitar permissão via geolocator: $e');
      return false;
    }
  }

  /// Abre as configurações do aplicativo
  static Future<void> goToSettings() async {
    await ph.openAppSettings();
  }
}

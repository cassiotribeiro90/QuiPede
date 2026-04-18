import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  /// Verifica se a plataforma atual é mobile (Android ou iOS)
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  /// Verifica se a plataforma atual é web
  static bool get isWeb => kIsWeb;
  
  /// Verifica se a plataforma atual é desktop (Windows, macOS, Linux)
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
}

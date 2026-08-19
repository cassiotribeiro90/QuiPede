// lib/app/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  // 🔥 TÍTULOS
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // 🔥 CORPO
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // 🔥 LABELS
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // 🔥 BOTÕES
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // 🔥 PREÇOS
  static const TextStyle price = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
}

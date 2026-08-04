// lib/app/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  // 🔥 TÍTULOS (diminuídos -2px)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 26,  // 28 → 26
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,  // 24 → 22
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 20,  // 22 → 20
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // 🔥 CORPO (diminuídos -2px)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,  // 20 → 18
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,  // 18 → 16
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,  // 16 → 14
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // 🔥 LABELS (diminuídos -2px)
  static const TextStyle label = TextStyle(
    fontSize: 14,  // 16 → 14
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,  // 15 → 13
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // 🔥 BOTÕES (diminuídos -2px)
  static const TextStyle button = TextStyle(
    fontSize: 16,  // 18 → 16
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // 🔥 PREÇOS (diminuídos -2px)
  static const TextStyle price = TextStyle(
    fontSize: 16,  // 18 → 16
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
}
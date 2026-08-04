// lib/app/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  // 🔥 TÍTULOS (reduzidos -1px)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 25,  // 26 → 25
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 21,  // 22 → 21
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 19,  // 20 → 19
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // 🔥 CORPO (reduzidos -1px)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,  // 18 → 17
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,  // 16 → 15
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,  // 14 → 13
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // 🔥 LABELS (reduzidos -1px)
  static const TextStyle label = TextStyle(
    fontSize: 13,  // 14 → 13
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,  // 13 → 12
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // 🔥 BOTÕES (reduzidos -1px)
  static const TextStyle button = TextStyle(
    fontSize: 18,  // 16 → 15
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // 🔥 PREÇOS (reduzidos -1px)
  static const TextStyle price = TextStyle(
    fontSize: 15,  // 16 → 15
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
}
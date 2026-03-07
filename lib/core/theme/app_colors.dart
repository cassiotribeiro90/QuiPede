import 'package:flutter/material.dart';

class AppColors {
  // Cores principais (fornecidas)
  static const Color primary = Color(0xFFC82158); // Rosa vibrante - ação, destaque
  static const Color secondary = Color(0xFF274084); // Azul profundo - confiança, estabilidade

  // Variações da primary
  static const Color primaryLight = Color(0xFFE63E7A); // Mais clara para hover/states
  static const Color primaryDark = Color(0xFFA01A46); // Mais escura para profundidade

  // Variações da secondary
  static const Color secondaryLight = Color(0xFF3A5AB0); // Mais clara
  static const Color secondaryDark = Color(0xFF1C2E5C); // Mais escura

  // Neutros (escala cinza)
  static const Color background = Color(0xFFF5F7FA); // Fundo geral
  static const Color surface = Color(0xFFFFFFFF); // Cards, superfícies
  static const Color surfaceVariant = Color(0xFFF0F2F5); // Superfícies secundárias

  static const Color textPrimary = Color(0xFF1A1F2E); // Texto principal
  static const Color textSecondary = Color(0xFF5F6570); // Texto secundário
  static const Color textHint = Color(0xFF9BA3AF); // Placeholders

  // Feedback
  static const Color success = Color(0xFF10B981); // Verde
  static const Color warning = Color(0xFFF59E0B); // Laranja
  static const Color error = Color(0xFFEF4444); // Vermelho
  static const Color info = Color(0xFF3B82F6); // Azul

  // Bordas e divisores
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // Gradientes sugeridos
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
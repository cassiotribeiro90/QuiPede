import 'package:flutter/material.dart';

class AppColors {
  // ================================================================
  // 🔥 CORES DA MARCA (LARANJA)
  // ================================================================
  static const Color primary = Color(0xFFF57C00);      // Laranja principal
  static const Color primaryDark = Color(0xFFE65100);   // Laranja escuro
  static const Color primaryLight = Color(0xFFFF9800);  // Laranja claro
  static const Color primaryBackground = Color(0xFFFFF3E0); // Fundo laranja suave
  static const Color primarySurface = Color(0xFFFFF8E1);    // Superfície laranja
  static const Color primaryOrangeBackground = Color(0xFFFFF3E0); // 🔥 NOVO
  // ================================================================
  // 🔥 CORES DO CHAT E COMUNICAÇÃO (AZUL)
  // ================================================================
// ================================================================
// 🔥 CORES DO CHAT (LARANJA DA MARCA)
// ================================================================
  static const Color chatPrimary = Color(0xFFFF6B35);      // Laranja principal da marca
  static const Color chatLight = Color(0xFFFF8A65);         // Laranja claro
  static const Color chatDark = Color(0xFFE64A19);          // Laranja escuro
  static const Color chatPastel = Color(0xFFFFCCBC);        // Laranja pastel
  static const Color chatBackground = Color(0xFFFFF3E0);    // Fundo laranja claríssimo

  // Cores neutras
  static const Color background = Color(0xFFFFFFFF);     // Fundo branco
  static const Color surface = Color(0xFFF5F5F5);        // Superfície cinza claro
  static const Color card = Color(0xFFFFFFFF);           // Cards brancos
  
  // Texto
  static const Color textPrimary = Color(0xFF212121);    // Texto principal
  static const Color textSecondary = Color(0xFF757575);  // Texto secundário
  static const Color textHint = Color(0xFF9E9E9E);       // Texto de dica
  static const Color textDisabled = Color(0xFFBDBDBD);   // Texto desabilitado
  
  // Bordas e divisores
  static const Color border = Color(0xFFE0E0E0);         // Borda padrão
  static const Color divider = Color(0xFFEEEEEE);        // Divisor
  
  // Estados
  static const Color error = Color(0xFFD32F2F);          // Vermelho erro
  static const Color success = Color(0xFF388E3C);        // Verde sucesso
  static const Color warning = Color(0xFFFFA000);        // Amarelo aviso
  static const Color info = Color(0xFF1976D2);           // Azul info
  
  // Cores de destaque
  static const Color rating = Color(0xFFFFB300);         // Cor das estrelas
  static const Color verified = Color(0xFF2196F3);       // Azul verificado
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient drawerHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  // Sombras
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}

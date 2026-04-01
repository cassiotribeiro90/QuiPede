import 'package:flutter/material.dart';

class TextUtils {
  /// Regex para identificar emojis (cobertura completa)
  static final RegExp emojiRegex = RegExp(
    r'[\u{1F000}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F300}-\u{1F6FF}\u{1F900}-\u{1FAFF}]',
    unicode: true,
  );
  
  /// Regex para letras acentuadas e caracteres válidos
  static final RegExp validCharsRegex = RegExp(
    r'[^a-zA-Zà-úÀ-Ú0-9\s&-]', // Mantém & e -
    unicode: true,
  );
  
  /// Remove emojis e caracteres especiais, mantendo estrutura legível
  static String cleanCategory(String text) {
    if (text.isEmpty) return text;
    
    // Passo 1: Remove emojis
    String result = text.replaceAll(emojiRegex, '');
    
    // Passo 2: Remove caracteres inválidos (mantém letras, números, &, - e espaços)
    result = result.replaceAll(validCharsRegex, '');
    
    // Passo 3: Normaliza espaços
    result = result.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Passo 4: Ajusta espaços em volta de & e -
    result = result.replaceAll(RegExp(r'\s*&\s*'), ' & ');
    result = result.replaceAll(RegExp(r'\s*-\s*'), ' - ');
    
    return result.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Versão para exibição em chips e cards
  static String getDisplayCategory(String categoryWithEmoji) {
    final cleaned = cleanCategory(categoryWithEmoji);
    
    // Casos especiais: se ficou vazio, retorna "Outros"
    if (cleaned.isEmpty) return 'Outros';
    
    return cleaned;
  }
}

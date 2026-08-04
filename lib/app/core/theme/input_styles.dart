import 'package:flutter/material.dart';

class InputStyles {
  // Estilo para campos de texto com borda (Outlined) - Moderno e limpo
  static InputDecorationTheme get outlinedDecorationTheme {
    return const InputDecorationTheme(
      // Define a borda padrão
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      // Borda quando o campo está habilitado
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      // Borda quando o campo está em foco (com a cor principal do app)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Color(0xFFF57C00), width: 2.0),
      ),
      // Borda quando o campo tem erro
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      // Borda quando o campo está em foco e com erro
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      // Espaçamento interno
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      // Estilo do label (flutuante ou estático)
      labelStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
      // Estilo do placeholder
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
      // Cor do ícone de prefixo
      prefixIconColor: Colors.grey,
      // Cor do ícone de sufixo
      suffixIconColor: Colors.grey,
      // Fundo do campo (transparente para outlined)
      filled: false,
    );
  }

  // Método prático para criar a decoração de um campo
  static InputDecoration decoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool isRequired = false,
  }) {
    return InputDecoration(
      labelText: isRequired ? '$label *' : label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      errorText: errorText,
      // Aplica o tema definido acima, mas permite sobrescrita
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Color(0xFFF57C00), width: 2.0),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 16.0),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
      prefixIconColor: Colors.grey,
      suffixIconColor: Colors.grey,
      filled: false,
    );
  }
}
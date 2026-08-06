// lib/app/core/theme/input_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class InputStyles {
  static const Color _surfaceColor = AppColors.surface;
  static const double _borderRadius = 16.0;

  // 🔥 TODAS AS VARIÁVEIS DE TAMANHO EM UM ÚNICO LUGAR
  static const double labelFontSize = 22.0;
  static const double floatingLabelFontSize = 18.0;
  static const double hintFontSize = 22.0;
  static const double inputTextFontSize = 22.0;

  static InputDecorationTheme get borderlessDecorationTheme {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: _surfaceColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: _surfaceColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),

      // 🔥 USANDO AS VARIÁVEIS
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: labelFontSize,
        fontWeight: FontWeight.w500,
      ),

      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: floatingLabelFontSize,
        fontWeight: FontWeight.w600,
      ),

      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: hintFontSize,
        fontWeight: FontWeight.w400,
      ),

      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.primary,
      filled: true,
      fillColor: _surfaceColor,
    );
  }

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

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.surface, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.surface, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),

      // 🔥 USANDO AS VARIÁVEIS
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: labelFontSize,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: floatingLabelFontSize,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: hintFontSize,
        fontWeight: FontWeight.w400,
      ),

      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.primary,
      filled: true,
      fillColor: AppColors.surface,
    );
  }

  static InputDecoration transparentDecoration({
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

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),

      // 🔥 USANDO AS VARIÁVEIS
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: labelFontSize,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: floatingLabelFontSize,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: hintFontSize,
        fontWeight: FontWeight.w400,
      ),

      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.primary,
      filled: false,
    );
  }
}
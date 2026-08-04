// lib/app/core/theme/app_decoration.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_theme_extension.dart';

class AppDecoration {
  // ============ BORDAS ============
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(8);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(12);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(16);
  static BorderRadius get borderRadiusXLarge => BorderRadius.circular(24);

  // ============ INPUTS ============
  static InputBorder get inputEnabledBorder => OutlineInputBorder(
    borderRadius: borderRadiusMedium,
    borderSide: const BorderSide(color: AppColors.border),
  );

  static InputBorder get inputFocusedBorder => OutlineInputBorder(
    borderRadius: borderRadiusMedium,
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  );

  // ============ CARDS ============
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.card,
    borderRadius: borderRadiusMedium,
    border: Border.all(color: AppColors.border),
    boxShadow: AppColors.cardShadow,
  );

  // ============ SEARCH ============
  static BoxDecoration get searchDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: borderRadiusMedium,
    border: Border.all(color: AppColors.border),
  );

  // ============ CHIPS ============

  /// 🔥 PADDING PADRÃO PARA CHIPS
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);

  /// 🔥 ESTILO DE CHIP PADRÃO
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.primarySurface,
    padding: chipPadding,
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusLarge,
      side: BorderSide(color: AppColors.border),
    ),
    labelStyle: AppTextStyles.bodyLarge,
    secondaryLabelStyle: AppTextStyles.bodyLarge,
    brightness: Brightness.light,
  );

  /// 🔥 MÉTODO PARA CRIAR CHIP COM ESTILO PERSONALIZADO
  static ChipThemeData chipStyle({
    required bool selected,
    required BuildContext context,
  }) {
    return ChipThemeData(
      backgroundColor: context.surfaceColor,
      selectedColor: context.primarySurface,
      padding: chipPadding,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadiusLarge,
        side: BorderSide(
          color: selected ? context.primaryColor : context.borderColor,
        ),
      ),
      labelStyle: AppTextStyles.bodyLarge.copyWith(
        color: selected ? context.primaryColor : context.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      secondaryLabelStyle: AppTextStyles.bodyLarge.copyWith(
        color: selected ? context.primaryColor : context.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      brightness: Brightness.light,
    );
  }

  static BoxDecoration chipDecoration({required bool selected}) {
    return BoxDecoration(
      color: selected ? AppColors.primarySurface : AppColors.surface,
      borderRadius: borderRadiusLarge,
      border: Border.all(
        color: selected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  // ============ BOTÕES ============

  /// 🔥 BOTÃO PRIMÁRIO (ElevatedButton) - PADRÃO
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24), // 🔥 MEIO TERMO (18→24)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button,
    elevation: 0,
  );

  /// 🔥 BOTÃO PRIMÁRIO GRANDE - PARA TELAS PRINCIPAIS
  static ButtonStyle get primaryLargeButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30), // 🔥 MEIO TERMO (22→30)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusLarge),
    textStyle: AppTextStyles.button.copyWith(fontSize: 18),
    elevation: 0,
  );

  /// 🔥 BOTÃO SECUNDÁRIO (OutlinedButton)
  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24), // 🔥 MEIO TERMO (18→24)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button,
  );

  /// 🔥 BOTÃO DE LIMPAR (OutlinedButton) - PARA FILTROS
  static ButtonStyle get clearButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    side: BorderSide(color: AppColors.border),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // 🔥 MEIO TERMO (18→24)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button.copyWith(
      color: AppColors.textSecondary,
    ),
  );

  /// 🔥 BOTÃO DE AÇÃO (ElevatedButton) - PARA BOTTOM SHEETS
  static ButtonStyle get actionButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28), // 🔥 MEIO TERMO (20→28)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
    elevation: 0,
  );

  /// 🔥 BOTÃO DE FILTRO (ElevatedButton) - PARA BOTTOM SHEETS DE FILTRO
  static ButtonStyle get filterButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22), // 🔥 MEIO TERMO (16→22)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
    elevation: 0,
  );

  /// 🔥 BOTÃO TEXTO (TextButton) - PARA LINKS E AÇÕES SECUNDÁRIAS
  static ButtonStyle get textButton => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), // 🔥 MEIO TERMO (14→18)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusSmall),
    textStyle: AppTextStyles.bodyMedium.copyWith(
      fontWeight: FontWeight.w500,
    ),
  );

  /// 🔥 BOTÃO PEQUENO - PARA CHIPS E TAGS
  static ButtonStyle get smallButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // 🔥 MEIO TERMO (10→14)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusSmall),
    textStyle: AppTextStyles.bodySmall.copyWith(
      fontWeight: FontWeight.w500,
    ),
    elevation: 0,
  );

  /// 🔥 BOTÃO DE CONFIRMAÇÃO (ElevatedButton) - PARA MODAIS
  static ButtonStyle get confirmButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28), // 🔥 MEIO TERMO (20→28)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusLarge),
    textStyle: AppTextStyles.button.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    elevation: 0,
  );

  /// 🔥 BOTÃO DE CANCELAR (OutlinedButton) - PARA MODAIS
  static ButtonStyle get cancelButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    side: BorderSide(color: AppColors.border),
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28), // 🔥 MEIO TERMO (20→28)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusLarge),
    textStyle: AppTextStyles.button.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
  );

  /// 🔥 BOTÃO PERIGO (ElevatedButton) - PARA EXCLUSÕES
  static ButtonStyle get dangerButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24), // 🔥 MEIO TERMO (18→24)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button,
    elevation: 0,
  );

  /// 🔥 BOTÃO DESABILITADO
  static ButtonStyle get disabledButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.border,
    foregroundColor: AppColors.textHint,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24), // 🔥 MEIO TERMO (18→24)
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button,
    elevation: 0,
  );
}

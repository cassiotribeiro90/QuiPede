// lib/app/core/theme/app_decoration.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppDecoration {
  // ============ BORDAS ============
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(8);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(12);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(16);
  static BorderRadius get borderRadiusXLarge => BorderRadius.circular(24);

  // ============ INPUTS ============
  static InputBorder get inputEnabledBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.border),
  );

  static InputBorder get inputFocusedBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  );

  // ============ CARDS ============
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
    boxShadow: AppColors.cardShadow,
  );

  // ============ SEARCH ============
  static BoxDecoration get searchDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  );

  // ============ CHIPS ============

  static const EdgeInsets chipPadding =
  EdgeInsets.symmetric(horizontal: 20, vertical: 14);

  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.primarySurface,
    padding: chipPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    labelStyle: AppTextStyles.bodyLarge,
    secondaryLabelStyle: AppTextStyles.bodyLarge,
    brightness: Brightness.light,
  );

  static ChipThemeData chipStyle({
    required bool selected,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return ChipThemeData(
      backgroundColor: theme.cardColor,
      selectedColor: theme.primaryColor.withValues(alpha: 0.1),
      padding: chipPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? theme.primaryColor : theme.dividerColor,
        ),
      ),
      labelStyle: AppTextStyles.bodyLarge.copyWith(
        color: selected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      secondaryLabelStyle: AppTextStyles.bodyLarge.copyWith(
        color: selected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      brightness: Brightness.light,
    );
  }

  static BoxDecoration chipDecoration({required bool selected}) {
    final color = selected ? AppColors.primarySurface : AppColors.surface;
    final borderColor = selected ? AppColors.primary : AppColors.border;
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
    );
  }

  // ============ BOTÕES ============

  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
    elevation: 0,
  );

  static ButtonStyle get primaryLargeButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: AppTextStyles.button.copyWith(fontSize: 18),
    elevation: 0,
  );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
  );

  static ButtonStyle get clearButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    side: const BorderSide(color: AppColors.border),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button.copyWith(
      color: AppColors.textSecondary,
    ),
  );

  static ButtonStyle get actionButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
    elevation: 0,
  );

  static ButtonStyle get filterButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
    elevation: 0,
  );

  static ButtonStyle get textButton => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: AppTextStyles.bodyMedium.copyWith(
      fontWeight: FontWeight.w500,
    ),
  );

  static ButtonStyle get smallButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: AppTextStyles.bodySmall.copyWith(
      fontWeight: FontWeight.w500,
    ),
    elevation: 0,
  );

  static ButtonStyle get confirmButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: AppTextStyles.button.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    elevation: 0,
  );

  static ButtonStyle get cancelButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    side: const BorderSide(color: AppColors.border),
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: AppTextStyles.button.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w500,
    ),
  );

  static ButtonStyle get dangerButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
    elevation: 0,
  );

  static ButtonStyle get disabledButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.border,
    foregroundColor: AppColors.textHint,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
    elevation: 0,
  );
}
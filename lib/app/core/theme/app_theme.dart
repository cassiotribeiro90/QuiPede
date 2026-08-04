import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_decoration.dart';
import 'input_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: Colors.black),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.titleLarge,
        displayMedium: AppTextStyles.titleMedium,
        displaySmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
      ),
      
      inputDecorationTheme: InputStyles.outlinedDecorationTheme,
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppDecoration.primaryButton,
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppDecoration.secondaryButton,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySurface,
        labelStyle: AppTextStyles.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: AppDecoration.borderRadiusLarge,
        ),
        side: const BorderSide(color: AppColors.border),
      ),
      
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppDecoration.borderRadiusMedium,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

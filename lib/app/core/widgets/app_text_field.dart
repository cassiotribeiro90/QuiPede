// lib/app/core/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/input_styles.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool isRequired;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onTap,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      onTap: onTap,
      readOnly: readOnly,
      textAlign: textAlign,
      inputFormatters: inputFormatters,
      autofocus: autofocus,

      // 🔥 USANDO A VARIÁVEL DO InputStyles
      style: const TextStyle(
        fontSize: InputStyles.inputTextFontSize,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),

      decoration: InputStyles.decoration(
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isRequired: isRequired,
      ).copyWith(counterText: ''),
    );
  }
}
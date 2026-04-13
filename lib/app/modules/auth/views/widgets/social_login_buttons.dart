import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_cubit.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Ou continue com', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        // Google
        _SocialButton(
          onPressed: () => context.read<AuthCubit>().socialLogin('google'),
          icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.red), // Usando ícone como fallback se não houver imagem
          label: 'Google',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        const SizedBox(height: 12),
        // Facebook
        _SocialButton(
          onPressed: () => context.read<AuthCubit>().socialLogin('facebook'),
          icon: const Icon(Icons.facebook, color: Colors.white, size: 24),
          label: 'Facebook',
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 12),
          // Apple (apenas iOS)
          _SocialButton(
            onPressed: () => context.read<AuthCubit>().socialLogin('apple'),
            icon: const Icon(Icons.apple, color: Colors.white, size: 24),
            label: 'Apple',
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          'Continuar com $label',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: backgroundColor == Colors.white
              ? const BorderSide(color: Color(0xFFE0E0E0))
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

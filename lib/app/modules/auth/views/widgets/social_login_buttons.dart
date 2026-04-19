import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_cubit.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou continue br',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 24),
        // Google
        _SocialButton(
          onPressed: () => context.read<AuthCubit>().socialLogin('google'),
          icon: const Icon(Icons.g_mobiledata, color: Colors.black87, size: 24),
          label: 'Google',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          hasBorder: true,
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
        if (!kIsWeb && Platform.isIOS) ...[
          const SizedBox(height: 12),
          // Apple (apenas iOS nativo)
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
  final bool hasBorder;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: hasBorder ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              'Entrar br $label',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

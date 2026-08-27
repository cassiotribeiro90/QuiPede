import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_cubit.dart';
import '../../../../core/widgets/primary_button.dart';

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
                'ou continue com',
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
          icon: Icons.g_mobiledata,
          label: 'Google',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        const SizedBox(height: 12),
        // Facebook
        _SocialButton(
          onPressed: () => context.read<AuthCubit>().socialLogin('facebook'),
          icon: Icons.facebook,
          label: 'Facebook',
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
        ),
        if (!kIsWeb && Platform.isIOS) ...[
          const SizedBox(height: 12),
          // Apple (apenas iOS nativo)
          _SocialButton(
            onPressed: () => context.read<AuthCubit>().socialLogin('apple'),
            icon: Icons.apple,
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
  final IconData icon;
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
    return PrimaryButton(
      onPressed: onPressed,
      label: 'Entrar com $label',
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      height: 48,
    );
  }
}

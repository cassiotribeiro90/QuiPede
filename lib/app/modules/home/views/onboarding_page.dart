import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quipede/app/core/theme/app_text_styles.dart';
import 'package:quipede/app/routes/app_routes.dart';
import 'widgets/onboarding_option_card.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../core/constants/navigation_origins.dart';

class OnboardingPage extends StatefulWidget {
  final String? origem;
  const OnboardingPage({super.key, this.origem});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // ✅ Navegação com go_router usando context.go (substitui a pilha)
  void _irParaCepPage() {
    context.go(Routes.cepInput);
  }

  void _irParaBuscaEndereco() {
    context.go(Routes.buscaEndereco);
  }

  void _irParaPhoneInput() {
    context.go(
      Routes.phoneInput,
      extra: {
        'origem': widget.origem ?? NavigationOrigins.onboarding,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF57C00);

    return _buildContent(context, primaryColor);
  }

  Widget _buildContent(BuildContext context, Color primaryColor) {
    return AppScaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delivery_dining_rounded,
                    size: 100,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Como você quer começar?',
                style: AppTextStyles.titleLarge.copyWith(
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha uma forma de definir seu endereço de entrega e encontre as melhores lojas.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              OnboardingOptionCard(
                icon: Icons.markunread_mailbox_rounded,
                title: 'Informar CEP',
                subtitle: 'Rápido e preciso',
                onTap: _irParaCepPage,
              ),
              OnboardingOptionCard(
                icon: Icons.search_rounded,
                title: 'Buscar endereço',
                subtitle: 'Digite rua ou bairro',
                onTap: _irParaBuscaEndereco,
              ),
              OnboardingOptionCard(
                icon: Icons.person_outline_rounded,
                title: 'Já tenho uma conta',
                subtitle: 'Entrar com seu número de telefone',
                onTap: _irParaPhoneInput,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
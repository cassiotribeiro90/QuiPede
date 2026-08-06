import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/routes/app_routes.dart';
import 'package:quipede/app/core/utils/platform_utils.dart';
import 'package:quipede/app/core/theme/app_text_styles.dart';
import '../services/localizacao_service.dart';
import 'busca_endereco_page.dart';
import 'cep_input_page.dart';
import 'localizacao_confirmacao_page.dart';
import 'widgets/onboarding_option_card.dart';
import '../../../widgets/app_scaffold.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../auth/bloc/auth_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _localizacaoService = LocalizacaoService(getIt<ApiClient>());
  bool _isLoading = false;

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  void _irParaCepPage() {
    print('📂 [OnboardingPage] Navegando para CepInputPage');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: getIt<EnderecoCubit>(),
          child: const CepInputPage(),
        ),
      ),
    );
  }

  void _irParaBuscaEndereco() {
    print('📂 [OnboardingPage] Navegando para BuscaEnderecoPage');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: getIt<EnderecoCubit>(),
          child: const BuscaEnderecoPage(),
        ),
      ),
    );
  }

  void _usarLocalizacaoAtual() async {
    if (!PlatformUtils.isMobile) return;

    _setLoading(true);
    try {
      final status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition();
        final response = await _localizacaoService.geocodificar(
          position.latitude,
          position.longitude,
        );

        if (response['success'] == true && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: getIt<EnderecoCubit>(),
                child: LocalizacaoConfirmacaoPage(
                  endereco: response['data'],
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
              ),
            ),
          );
        } else {
          _showError(response['message'] ?? 'Não foi possível identificar seu endereço.');
        }
      } else {
        _showError('Permissão de localização negada.');
      }
    } catch (e) {
      _showError('Erro ao obter localização.');
    } finally {
      _setLoading(false);
    }
  }

  void _showError(String message) {
    print('⚠️ [OnboardingPage] Erro: $message');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ [OnboardingPage] build() chamado');
    final primaryColor = const Color(0xFFF57C00);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<EnderecoCubit>()),
      ],
      child: _buildContent(context, primaryColor),
    );
  }

  Widget _buildContent(BuildContext context, Color primaryColor) {
    return AppScaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
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
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delivery_dining_rounded, size: 100, color: primaryColor),
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
                    style: AppTextStyles.bodyLarge.copyWith(
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
                  if (PlatformUtils.isMobile)
                    OnboardingOptionCard(
                      icon: Icons.my_location_rounded,
                      title: 'Usar localização atual',
                      subtitle: 'Encontre lojas próximas',
                      onTap: _usarLocalizacaoAtual,
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
                    onTap: () => Navigator.pushNamed(context, Routes.phoneInput),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Ao continuar, você concorda com nossos Termos de Uso.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF57C00)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
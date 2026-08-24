// lib/app/modules/auth/views/phone_input_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../navigation/navigation_cubit.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/app_text_field.dart';

class PhoneInputPage extends StatelessWidget {
  final bool redirectToCheckout;
  final String? origem;

  const PhoneInputPage({
    super.key,
    this.redirectToCheckout = false,
    this.origem,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 [PhoneInputPage] foi construída. origem: $origem, redirectToCheckout: $redirectToCheckout');
    return _PhoneInputBody(
      redirectToCheckout: redirectToCheckout,
      origem: origem,
    );
  }
}

class _PhoneInputBody extends StatefulWidget {
  final bool redirectToCheckout;
  final String? origem;

  const _PhoneInputBody({
    required this.redirectToCheckout,
    this.origem,
  });

  @override
  State<_PhoneInputBody> createState() => _PhoneInputBodyState();
}

class _PhoneInputBodyState extends State<_PhoneInputBody> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _maskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 [PhoneInputPage] initState - redirectToCheckout: ${widget.redirectToCheckout}, origem: ${widget.origem}');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ [PhoneInputPage] Formulário inválido');
      return;
    }

    // ✅ Remove caracteres não numéricos
    final telefone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    debugPrint('📞 [PhoneInputPage] Telefone original: ${_phoneController.text}');
    debugPrint('📞 [PhoneInputPage] Telefone limpo: "$telefone"');
    debugPrint('📞 [PhoneInputPage] Telefone length: ${telefone.length}');

    if (telefone.isEmpty) {
      debugPrint('❌ [PhoneInputPage] Telefone vazio após limpeza!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Telefone inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (telefone.length != 11) {
      debugPrint('❌ [PhoneInputPage] Telefone com tamanho incorreto: ${telefone.length} (esperado: 11)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Telefone inválido. Use DDD + 9 dígitos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ✅ CORRIGIDO: Usa context.read em vez de getIt
    debugPrint('🚀 [PhoneInputPage] Chamando AuthCubit.enviarTelefone com: "$telefone"');
    context.read<AuthCubit>().enviarTelefone(telefone);
  }

  @override
  Widget build(BuildContext context) {
    final navigationCubit = context.read<NavigationCubit>();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        debugPrint('📡 [PhoneInputPage] Estado recebido: ${state.runtimeType}');

        if (state is AuthPhoneEnviado) {
          debugPrint('✅ [PhoneInputPage] AuthPhoneEnviado - telefone: ${state.telefone}');
          setState(() => _isLoading = false);
          // 🔥 Navegação para OTP via NavigationCubit
          navigationCubit.goToOtpVerify(
            state.telefone,
            redirectToCheckout: widget.redirectToCheckout,
            origem: widget.origem,
          );
        } else if (state is AuthOtpErro) {
          debugPrint('❌ [PhoneInputPage] AuthOtpErro: ${state.mensagem}');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensagem),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthLoading) {
          debugPrint('⏳ [PhoneInputPage] AuthLoading');
          setState(() => _isLoading = true);
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Entrar'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.onboarding);
              }
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Qual é o seu número?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enviaremos um código de verificação para você.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Telefone',
                      hint: '(11) 99999-8888',
                      prefixIcon: Icons.phone_android,
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      inputFormatters: [_maskFormatter],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Digite seu telefone';
                        }
                        final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleaned.length != 11) {
                          return 'Digite um telefone válido com DDD (11 dígitos)';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _enviar(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _enviar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
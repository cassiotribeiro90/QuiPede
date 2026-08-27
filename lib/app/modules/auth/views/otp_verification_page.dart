// lib/app/modules/auth/views/otp_verification_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quipede/app/routes/app_routes.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class OtpVerificationPage extends StatefulWidget {
  final String telefone;
  final bool redirectToCheckout;
  final String? origem;

  const OtpVerificationPage({
    super.key,
    required this.telefone,
    this.redirectToCheckout = false,
    this.origem,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _phone = widget.telefone;
    debugPrint('📞 [OtpVerificationPage] initState - telefone: "$_phone"');
    debugPrint('📞 [OtpVerificationPage] initState - redirectToCheckout: ${widget.redirectToCheckout}');
    debugPrint('📞 [OtpVerificationPage] initState - origem: ${widget.origem}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔥 Restaura o telefone no AuthCubit se não estiver definido
    final phone = widget.telefone;
    if (phone.isNotEmpty) {
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state is! AuthPhoneEnviado) {
        debugPrint('📞 [OtpVerificationPage] Restaurando telefone no AuthCubit: "$phone"');
        authCubit.restaurarTelefone(phone);
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verificarOTP() {
    if (!_formKey.currentState!.validate()) return;

    final code = _codeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    debugPrint('🔢 [OtpVerificationPage] Código digitado: "$code"');

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite os 6 dígitos do código')),
      );
      return;
    }

    // ✅ Usa o telefone do widget ou do estado
    final telefone = _phone ?? widget.telefone;
    debugPrint('📞 [OtpVerificationPage] Verificando OTP com telefone: "$telefone" e código: "$code"');

    if (telefone.isEmpty) {
      debugPrint('❌ [OtpVerificationPage] Telefone vazio!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: telefone não encontrado'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<AuthCubit>().verificarOTP(
      telefone,
      code,
      redirectToCheckout: widget.redirectToCheckout,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ [OtpVerificationPage] build - telefone: "${widget.telefone}"');

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        debugPrint('📡 [OtpVerificationPage] Estado recebido: ${state.runtimeType}');

        if (state is AuthAuthenticated) {
          debugPrint('✅ [OtpVerificationPage] AuthAuthenticated');
          setState(() => _isLoading = false);
        } else if (state is AuthOtpErro) {
          debugPrint('❌ [OtpVerificationPage] AuthOtpErro: ${state.mensagem}');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensagem), backgroundColor: Colors.red),
          );
        } else if (state is AuthOtpVerificando) {
          debugPrint('⏳ [OtpVerificationPage] AuthOtpVerificando');
          setState(() => _isLoading = true);
        }
      },
      builder: (context, state) {
        return ResponsivePageScaffold(
          appBar: AppBar(
            title: const Text('Verificar Código'),
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
                        'Digite o código',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enviamos um código de verificação para ${_phone ?? 'seu telefone'}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        controller: _codeController,
                        label: 'Código',
                        hint: '000000',
                        prefixIcon: Icons.vpn_key,
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (v) {
                          if (v == null || v.replaceAll(RegExp(r'[^0-9]'), '').length != 6) {
                            return 'Digite os 6 dígitos do código';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _verificarOTP(),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: _verificarOTP,
                        label: 'Verificar',
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
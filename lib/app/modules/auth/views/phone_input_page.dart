import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../di/dependencies.dart';
import '../../../routes/app_routes.dart';
import '../../../services/navigation_service.dart';
import '../../../core/widgets/app_text_field.dart';

class PhoneInputPage extends StatelessWidget {
  final bool redirectToCheckout;
  const PhoneInputPage({super.key, this.redirectToCheckout = false});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 [LOG] PhoneInputPage foi construída');
    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: _PhoneInputBody(redirectToCheckout: redirectToCheckout),
    );
  }
}

class _PhoneInputBody extends StatefulWidget {
  final bool redirectToCheckout;
  const _PhoneInputBody({required this.redirectToCheckout});

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
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final telefone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    getIt<AuthCubit>().enviarTelefone(telefone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        if (state is AuthPhoneEnviado) {
          setState(() => _isLoading = false);
          getIt<NavigationService>().pushNamed(
            Routes.otpVerify,
            arguments: {
              'telefone': state.telefone,
              'redirectToCheckout': widget.redirectToCheckout,
            },
          ).then((result) {
            if (result == true && mounted) {
              debugPrint('🧭 [PhoneInputPage] OTP sucesso - substituindo esta tela pelo destino correto');
              // ✅ Substitui PhoneInput pelo próximo passo (Carrinho ou CompletarPerfil)
              // O AppRouter fará a validação síncrona
              getIt<NavigationService>().pushReplacementNamed(Routes.carrinho);
            }
          });
        } else if (state is AuthOtpErro) {
          debugPrint('🧭 [PhoneInputPage] AuthOtpErro: ${state.mensagem}');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensagem), backgroundColor: Colors.red),
          );
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Entrar'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enviaremos um código de verificação para você.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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
                        if (v == null || v.replaceAll(RegExp(r'[^0-9]'), '').length != 11) {
                          return 'Digite um telefone válido com DDD';
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/services/navigation_service.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/theme/app_text_styles.dart';

class CompletarPerfilPage extends StatelessWidget {
  final bool redirectToCheckout;

  const CompletarPerfilPage({
    super.key,
    this.redirectToCheckout = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AuthCubit>(),
      child: _CompletarPerfilBody(redirectToCheckout: redirectToCheckout),
    );
  }
}

class _CompletarPerfilBody extends StatefulWidget {
  final bool redirectToCheckout;
  const _CompletarPerfilBody({required this.redirectToCheckout});

  @override
  State<_CompletarPerfilBody> createState() => _CompletarPerfilBodyState();
}

class _CompletarPerfilBodyState extends State<_CompletarPerfilBody> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    print('📝 [CompletarPerfil] Salvando perfil: nome=$nome, email=$email');

    // ✅ Não passa voltarPara — o Cubit apenas salva e emite AuthPerfilCompleto
    context.read<AuthCubit>().completarPerfil(
      nome: nome,
      email: email.isNotEmpty ? email : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return current is AuthPerfilCompleto || current is AuthError;
      },
      listener: (context, state) {
        if (state is AuthPerfilCompleto) {
          print('✅ [CompletarPerfil] Perfil completado, voltando...');
          // ✅ Simplesmente volta para a tela anterior (AppRouter que redirecionará para o carrinho)
          if (mounted) {
            getIt<NavigationService>().pop(true);
          }
        } else if (state is AuthError) {
          print('❌ [CompletarPerfil] Erro: ${state.message}');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Completar Cadastro'),
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
                    Text(
                      'Quase lá!',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preencha seus dados para finalizar o cadastro.',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _nomeController,
                      label: 'Nome completo',
                      hint: 'Seu nome completo',
                      prefixIcon: Icons.person_outline,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
                        if (value.trim().length < 3) return 'Nome muito curto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: 'E-mail (opcional)',
                      hint: 'seu@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                            return 'E-mail inválido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Finalizar Cadastro', style: AppTextStyles.button.copyWith(color: Colors.white)),
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
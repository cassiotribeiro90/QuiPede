import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../routes/app_routes.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../../../widgets/app_scaffold.dart';
import 'widgets/social_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    context.read<AuthCubit>().login(email, password);
  }

  Future<void> _processarAcaoPendente(Map<String, dynamic> acao) async {
    if (acao['tipo'] == 'adicionar_ao_carrinho') {
      final dados = acao['dados'] as Map<String, dynamic>;
      try {
        await context.read<CarrinhoCubit>().adicionarItem(
          produtoId: dados['produto_id'],
          quantidade: dados['quantidade'],
          observacao: dados['observacao'],
          applyDebounce: false,
        );
        print('✅ Ação pendente executada: Produto ${dados['produto_id']} adicionado');
      } catch (e) {
        print('❌ Erro ao executar ação pendente: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    const primaryColor = Color(0xFFF57C00);

    return AppScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            final acaoPendente = args?['acaoPendente'];
            if (acaoPendente != null) {
              await _processarAcaoPendente(acaoPendente);
            }

            if (mounted) {
              final redirectTo = args?['redirectTo'] as String?;
              final params = args?['params'];

              if (redirectTo != null) {
                Navigator.pushReplacementNamed(context, redirectTo, arguments: params);
                return;
              }

              // ✅ Lógica de correção: Se logou com sucesso, verificar endereço
              final localState = context.read<LocalizacaoCubit>().state;
              if (localState is LocalizacaoCarregada) {
                // Se tem endereço (retornado pelo login e salvo no Cubit), vai para Home
                Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
              } else {
                // Caso raro de não ter endereço nem após o login, vai para Onboarding
                Navigator.pushNamedAndRemoveUntil(context, Routes.onboarding, (route) => false);
              }
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, size: 64, color: primaryColor),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça login para continuar sua experiência.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Esqueceu a senha?', style: TextStyle(color: primaryColor)),
                ),
              ),
              const SizedBox(height: 16),

              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
              const SocialLoginButtons(),
              
              const SizedBox(height: 32),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta?', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.cadastro),
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

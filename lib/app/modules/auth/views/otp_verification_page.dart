import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/services/navigation_service.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/app_text_field.dart';

class OtpVerificationPage extends StatelessWidget {
  final String telefone;
  final bool redirectToCheckout;

  const OtpVerificationPage({
    super.key,
    required this.telefone,
    this.redirectToCheckout = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AuthCubit>(),
      child: _OtpBody(telefone: telefone, redirectToCheckout: redirectToCheckout),
    );
  }
}

class _OtpBody extends StatefulWidget {
  final String telefone;
  final bool redirectToCheckout;
  const _OtpBody({required this.telefone, required this.redirectToCheckout});

  @override
  State<_OtpBody> createState() => _OtpBodyState();
}

class _OtpBodyState extends State<_OtpBody> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _autoVerifying = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _codeController.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    if (_codeController.text.length == 6 && !_autoVerifying) {
      _autoVerifying = true;
      setState(() => _isLoading = true);
      context.read<AuthCubit>().verificarOTP(
        widget.telefone,
        _codeController.text,
        redirectToCheckout: widget.redirectToCheckout,
      );
    }
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🧭 [OtpVerificationPage] build() - canPop: ${ModalRoute.of(context)?.canPop}, isFirst: ${ModalRoute.of(context)?.isFirst}');
    
    debugPrint('🔍 [LOG] OtpVerificationPage foi construída');
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (_navigated) return;

        if (state is AuthOtpErro) {
          setState(() {
            _isLoading = false;
            _autoVerifying = false;
          });
          _codeController.clear();
          _focusNode.requestFocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensagem), backgroundColor: Colors.red),
          );
        } else if (state is AuthAuthenticated) {
          print('🧭 [OtpVerificationPage] AuthAuthenticated - canPop: ${Navigator.canPop(context)}');
          _navigated = true;
          
          final user = getIt<AuthCubit>().usuario;
          if (user != null && user.nome.isNotEmpty) {
            // ✅ Usuário completo → volta limpando a pilha até Home/Loja e abre Carrinho
            print('🧭 [OtpVerificationPage] Usuário completo - abrindo carrinho');
            getIt<NavigationService>().pushNamedAndRemoveUntil(
              Routes.carrinho,
              (route) => route.settings.name == Routes.lojaHome || 
                         route.settings.name == Routes.home || 
                         route.isFirst,
            );
          } else {
            // ✅ Usuário sem nome → volta limpando a pilha até Home/Loja e abre Carrinho
            // O AppRouter processará o novo /carrinho e redirecionará para completarPerfil
            print('🧭 [OtpVerificationPage] Usuário sem nome - redirecionando para completarPerfil via /carrinho');
            getIt<NavigationService>().pushNamedAndRemoveUntil(
              Routes.carrinho,
              (route) => route.settings.name == Routes.lojaHome || 
                         route.settings.name == Routes.home || 
                         route.isFirst,
            );
          }
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Verificar código'),
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
                    'Enviamos um código de 6 dígitos para ${widget.telefone}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _codeController,
                    label: 'Código de verificação',
                    hint: '000000',
                    prefixIcon: Icons.security,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Digite o código de 6 dígitos';
                      }
                      return null;
                    },
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
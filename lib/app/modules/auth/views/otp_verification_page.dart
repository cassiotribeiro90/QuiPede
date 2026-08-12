import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../routes/app_routes.dart';

class OtpVerificationPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AuthCubit>(),
      child: _OtpBody(telefone: telefone, redirectToCheckout: redirectToCheckout, origem: origem),
    );
  }
}

class _OtpBody extends StatefulWidget {
  final String telefone;
  final bool redirectToCheckout;
  final String? origem;
  const _OtpBody({required this.telefone, required this.redirectToCheckout, this.origem});

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
    debugPrint('🔍 [LOG] OtpVerificationPage foi construída. redirectToCheckout=${widget.redirectToCheckout}');
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
          _navigated = true;
          final destino = widget.redirectToCheckout ? Routes.carrinho : Routes.home;
          
          debugPrint('🚦 [OTP] AuthAuthenticated disparado');
          debugPrint('🚦 [OTP] redirectToCheckout = ${widget.redirectToCheckout}');
          debugPrint('🚦 [OTP] canPop (antes de navegar) = ${Navigator.canPop(context)}');
          debugPrint('🚦 [OTP] Rota atual = ${ModalRoute.of(context)?.settings.name}');
          debugPrint('🧭 [OtpVerificationPage] Destino: $destino. Removendo apenas telas de autenticação.');
          
          if (mounted) {
            // ✅ Preserva Home e Loja na pilha, removendo apenas OTP e PhoneInput
            Navigator.of(context).pushNamedAndRemoveUntil(
              destino,
              (route) => route.settings.name == Routes.home ||
                         route.settings.name == Routes.lojaHome ||
                         route.isFirst,
              arguments: widget.redirectToCheckout ? {'origem': widget.origem} : null,
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

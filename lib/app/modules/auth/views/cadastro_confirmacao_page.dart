import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quipede/app/modules/auth/bloc/auth_cubit.dart';
import 'package:quipede/app/modules/auth/bloc/auth_state.dart';
import 'package:quipede/app/modules/auth/models/cadastro_models.dart';
import 'package:quipede/app/modules/home/bloc/localizacao_cubit.dart';
import 'package:quipede/app/modules/home/bloc/localizacao_state.dart';
import 'package:quipede/app/routes/app_routes.dart';
import 'package:quipede/app/navigation/navigation_cubit.dart';

class CadastroConfirmacaoPage extends StatelessWidget {
  final CadastroInfoModel dadosPessoais;

  const CadastroConfirmacaoPage({
    super.key,
    required this.dadosPessoais,
  });

  Future<void> _finalizar(BuildContext context) async {
    final locState = context.read<LocalizacaoCubit>().state;
    if (locState is! LocalizacaoCarregada) return;

    final payload = {
      ...dadosPessoais.toJson(),
      ...locState.endereco.toJson(),
    };

    context.read<AuthCubit>().cadastrar(payload);
  }

  @override
  Widget build(BuildContext context) {

    debugPrint('🔍 [LOG] CadastroConfirmacaoPage foi construída');

    const primaryColor = Color(0xFFF57C00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Confirmar Cadastro'), elevation: 0),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            debugPrint('✅ [CadastroConfirmacao] Autenticado. NavigationCubit cuidará do redirecionamento.');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Quase lá!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirme seus dados e o endereço de entrega para finalizar seu cadastro.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _finalizar(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('FINALIZAR E ENTRAR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

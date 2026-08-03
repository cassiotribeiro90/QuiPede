import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/cadastro_form_widget.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_scaffold.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class CompletarCadastroPage extends StatelessWidget {
  const CompletarCadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF57C00);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // ✅ Cadastro concluído com sucesso, volta para finalizar a compra
          Navigator.pushNamedAndRemoveUntil(
            context, 
            Routes.carrinho, 
            (route) => false
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: AppScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Quase lá!'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete seu cadastro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Identifique-se para finalizar seu pedido com segurança.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              const CadastroFormWidget(
                isCompletarCadastro: true,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.login,
                      arguments: {'redirectTo': Routes.carrinho},
                    );
                  },
                  child: const Text(
                    'Já tem conta? Entrar',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

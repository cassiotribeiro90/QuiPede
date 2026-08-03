import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/endereco_selecionado_widget.dart';
import '../../../widgets/app_scaffold.dart';
import 'widgets/cadastro_form_widget.dart';

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: AppScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Criar conta'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: BlocBuilder<LocalizacaoCubit, LocalizacaoState>(
          builder: (context, locState) {
            final isEnderecoDefinido = locState is LocalizacaoCarregada;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '📍 Endereço de entrega',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  
                  EnderecoSelecionadoWidget(
                    endereco: isEnderecoDefinido ? locState.endereco : null,
                    onTap: () => Navigator.pushNamed(context, Routes.onboarding),
                  ),
                  
                  if (!isEnderecoDefinido)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        '⚠️ Defina um endereço para continuar',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Dados Pessoais',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  const CadastroFormWidget(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

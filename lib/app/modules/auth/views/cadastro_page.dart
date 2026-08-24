import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_routes.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/endereco_selecionado_widget.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../core/theme/app_text_styles.dart'; // 🔥 ADICIONADO
import 'widgets/cadastro_form_widget.dart';

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 [LOG] CadastroPage foi construída');
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          debugPrint('✅ [CadastroPage] Autenticado. NavigationCubit cuidará do redirecionamento.');
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
                  // 🔥 Título "📍 Endereço de entrega"
                  Text(
                    '📍 Endereço de entrega',
                    style: AppTextStyles.bodyLarge.copyWith( // 20px
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  EnderecoSelecionadoWidget(
                    endereco: isEnderecoDefinido ? locState.endereco : null,
                    onTap: () => context.push(Routes.onboarding),
                  ),

                  // 🔥 Mensagem de aviso "Defina um endereço para continuar"
                  if (!isEnderecoDefinido)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '⚠️ Defina um endereço para continuar',
                        style: AppTextStyles.bodySmall.copyWith( // 16px
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // 🔥 Título "Dados Pessoais"
                  Text(
                    'Dados Pessoais',
                    style: AppTextStyles.bodyLarge.copyWith( // 20px
                      fontWeight: FontWeight.bold,
                    ),
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/endereco_cubit.dart';
import '../bloc/endereco_state.dart';
import '../widgets/endereco_action_cards.dart';
import '../models/endereco_model.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../routes/app_routes.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class EnderecosListView extends StatefulWidget {
  const EnderecosListView({super.key});

  @override
  State<EnderecosListView> createState() => _EnderecosListViewState();
}

class _EnderecosListViewState extends State<EnderecosListView> {
  @override
  void initState() {
    super.initState();
    context.read<EnderecoCubit>().carregarEnderecos();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnderecoCubit, EnderecoState>(
      listenWhen: (previous, current) {
        return current is EnderecoOperacaoSucesso || current is EnderecoError;
      },
      listener: (context, state) {
        if (state is EnderecoOperacaoSucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensagem),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is EnderecoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return ResponsivePageScaffold(
          appBar: AppBar(
            title: const Text('Meus Endereços'),
            backgroundColor: context.surfaceColor,
            foregroundColor: context.textPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, Routes.home);
                }
              },
            ),
          ),
          backgroundColor: context.backgroundColor,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, EnderecoState state) {
    if (state is EnderecoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EnderecoLoaded) {
      if (state.enderecos.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () => context.read<EnderecoCubit>().carregarEnderecos(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.enderecos.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == state.enderecos.length) {
              return const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 32),
                child: EnderecoActionCards(),
              );
            }

            final endereco = state.enderecos[index];

            // 🔥 CONTAINER SIMPLES PARA TESTE (SUBSTITUI O ENDERECOCARD)
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    endereco.logradouro,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${endereco.bairro}, ${endereco.cidade} - ${endereco.uf}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'CEP: ${endereco.cep}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (endereco.principal == true) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Principal',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    }

    if (state is EnderecoError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<EnderecoCubit>().carregarEnderecos(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 80, color: context.textHint.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              'Nenhum endereço cadastrado',
              style: context.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione um endereço para encontrar as melhores lojas e receber seus pedidos com segurança.',
              textAlign: TextAlign.center,
              style: context.bodyMedium.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: 40),
            const EnderecoActionCards(),
          ],
        ),
      ),
    );
  }
}
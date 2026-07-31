import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/endereco_cubit.dart';
import '../bloc/endereco_state.dart';
import '../widgets/endereco_card.dart';
import '../models/endereco_model.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../routes/app_routes.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../../shared/widgets/web_back_button_handler.dart';

class EnderecosListView extends StatefulWidget {
  const EnderecosListView({super.key});

  @override
  State<EnderecosListView> createState() => _EnderecosListViewState();
}

class _EnderecosListViewState extends State<EnderecosListView> {
  @override
  void initState() {
    super.initState();
    // 🔥 CARREGA OS ENDEREÇOS AO ENTRAR
    context.read<EnderecoCubit>().carregarEnderecos();
  }

  @override
  Widget build(BuildContext context) {
    return WebBackButtonHandler(
      child: BlocConsumer<EnderecoCubit, EnderecoState>(
        // 🔥 SÓ ESCUTA ESTADOS QUE PRECISAM DE FEEDBACK VISUAL
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _navigateToForm(context),
                ),
              ],
            ),
            backgroundColor: context.backgroundColor,
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, EnderecoState state) {
    // 🔥 ESTADO DE CARREGAMENTO
    if (state is EnderecoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 🔥 ESTADO CARREGADO
    if (state is EnderecoLoaded) {
      if (state.enderecos.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () => context.read<EnderecoCubit>().carregarEnderecos(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.enderecos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final endereco = state.enderecos[index];
            final isPrincipal = endereco.principal == true;
            return EnderecoCard(
              endereco: endereco,
              isPrincipal: isPrincipal,
              onEdit: () => _navigateToForm(context, endereco: endereco),
              onDelete: () => _confirmarExclusao(context, endereco.id!),
              onSetPrincipal: () => context.read<EnderecoCubit>().definirPrincipal(endereco.id!),
            );
          },
        ),
      );
    }

    // 🔥 ESTADO DE ERRO
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

    // 🔥 ESTADO INICIAL - MOSTRA CARREGAMENTO
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: context.textHint),
          const SizedBox(height: 16),
          Text(
            'Nenhum endereço cadastrado',
            style: context.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione um endereço para receber seus pedidos',
            style: context.bodyMedium.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToForm(context),
            child: const Text('Adicionar endereço'),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, {EnderecoModel? endereco}) {
    Navigator.pushNamed(
      context,
      Routes.enderecoForm,
      arguments: {
        'endereco': endereco,
        'isEditing': endereco != null,
      },
    ).then((_) {
      // 🔥 SÓ RECARREGA SE O WIDGET AINDA ESTIVER MONTADO
      if (mounted) {
        try {
          context.read<EnderecoCubit>().carregarEnderecos();
        } catch (e) {
          print('Erro ao recarregar endereços: $e');
        }
      }
    });
  }

  void _confirmarExclusao(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir endereço'),
        content: const Text('Tem certeza que deseja excluir este endereço?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EnderecoCubit>().deletarEndereco(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

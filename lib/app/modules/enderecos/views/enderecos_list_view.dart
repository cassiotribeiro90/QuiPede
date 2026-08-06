import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/endereco_cubit.dart';
import '../bloc/endereco_state.dart';
import '../widgets/endereco_action_cards.dart';
import '../models/endereco_model.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../../di/dependencies.dart';
import '../../../services/navigation_service.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../home/bloc/localizacao_cubit.dart';

class EnderecosListView extends StatefulWidget {
  const EnderecosListView({super.key});

  @override
  State<EnderecosListView> createState() => _EnderecosListViewState();
}

class _EnderecosListViewState extends State<EnderecosListView> {
  List<EnderecoModel>? _cachedEnderecos;
  EnderecoModel? _cachedPrincipal;

  @override
  void initState() {
    super.initState();
    context.read<EnderecoCubit>().carregarEnderecos();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnderecoCubit, EnderecoState>(
      listenWhen: (previous, current) {
        return current is EnderecoError ||
            current is EnderecoCriado ||
            current is EnderecoExcluido ||
            current is EnderecoPrincipalDefinido;
      },
      listener: (context, state) {
        if (state is EnderecoError) {
          print('❌ [EnderecosListView] Erro: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is EnderecoCriado) {
          print('✅ [EnderecosListView] Endereço criado: ID ${state.endereco.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Endereço adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is EnderecoExcluido) {
          print('✅ [EnderecosListView] Endereço excluído: ID ${state.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Endereço removido com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is EnderecoPrincipalDefinido) {
          print('✅ [EnderecosListView] Principal definido: ID ${state.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Endereço selecionado!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        return current is EnderecoLoading ||
            current is EnderecoLoaded ||
            current is EnderecoError ||
            current is EnderecoInitial;
      },
      builder: (context, state) {
        if (state is EnderecoLoaded) {
          _cachedEnderecos = state.enderecos;
          _cachedPrincipal = state.enderecoPrincipal;
        }

        if (state is EnderecoLoaded && state.enderecoPrincipal != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<LocalizacaoCubit>().definirEnderecoCompleto(
                state.enderecoPrincipal!,
                origem: 'endereco_padrao',
              );
            }
          });
        }

        return ResponsivePageScaffold(
          appBar: AppBar(
            title: const Text('Meus Endereços'),
            backgroundColor: context.surfaceColor,
            foregroundColor: context.textPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (getIt<NavigationService>().canPop()) {
                  getIt<NavigationService>().pop();
                } else {
                  getIt<NavigationService>().goToHomeAndRemoveAll();
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
    if (state is EnderecoLoading && _cachedEnderecos == null) {
      print('⏳ [EnderecosListView] Mostrando loading inicial');
      return const Center(child: CircularProgressIndicator());
    }

    final enderecos = state is EnderecoLoaded ? state.enderecos : _cachedEnderecos;
    final principal = state is EnderecoLoaded ? state.enderecoPrincipal : _cachedPrincipal;

    if (enderecos == null) {
      print('⏳ [EnderecosListView] Aguardando primeira carga');
      return const Center(child: CircularProgressIndicator());
    }

    if (enderecos.isEmpty) {
      print('📭 [EnderecosListView] Lista vazia');
      return _buildEmptyState(context);
    }

    print('📋 [EnderecosListView] Exibindo ${enderecos.length} endereços');

    return RefreshIndicator(
      onRefresh: () => context.read<EnderecoCubit>().carregarEnderecos(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: enderecos.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == enderecos.length) {
            return const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 32),
              child: EnderecoActionCards(),
            );
          }

          final endereco = enderecos[index];
          final isSelected = principal?.id == endereco.id;

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                print('👆 [EnderecosListView] Selecionando endereço ID ${endereco.id}');
                context.read<EnderecoCubit>().definirPrincipal(endereco.id!);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: isSelected ? 2.5 : 1.0,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          endereco.logradouro,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              print('✏️ [EnderecosListView] Editando endereço ID ${endereco.id}');
                              // ✅ Recarrega a lista ao voltar da edição
                              getIt<NavigationService>().pushNamed(
                                Routes.enderecoEdit,
                                arguments: endereco,
                              ).then((_) {
                                print('🔄 [EnderecosListView] Voltou da edição, recarregando lista');
                                context.read<EnderecoCubit>().carregarEnderecos(mostrarLoading: false);
                              });
                            },
                            tooltip: 'Editar',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmarExclusao(context, endereco),
                            tooltip: 'Excluir',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (endereco.numero.isNotEmpty && endereco.numero != 'S/N')
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Nº ${endereco.numero}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 4),

                  Text(
                    '${endereco.bairro}, ${endereco.cidade} - ${endereco.uf}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  Text(
                    'CEP: ${endereco.cep}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione um endereço para encontrar as melhores lojas e receber seus pedidos com segurança.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: 40),
            const EnderecoActionCards(),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao(BuildContext context, EnderecoModel endereco) async {
    print('🗑️ [EnderecosListView] Confirmando exclusão do endereço ID ${endereco.id}');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir endereço'),
        content: const Text('Tem certeza que deseja excluir este endereço?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      print('✅ [EnderecosListView] Exclusão confirmada');
      context.read<EnderecoCubit>().deletarEndereco(endereco.id!);
    }
  }
}
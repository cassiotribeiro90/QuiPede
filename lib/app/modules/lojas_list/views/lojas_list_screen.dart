import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_state.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/loja_item.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../widgets/app_drawer.dart';
import '../../../models/lojas_list_filter_option_model.dart';
import '../../../navigation/navigation_cubit.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/navigation_origins.dart';
import '../../carrinho/widgets/carrinho_bottom_bar.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../../di/dependencies.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class LojasListScreen extends StatefulWidget {
  const LojasListScreen({super.key});

  @override
  State<LojasListScreen> createState() => _LojasListScreenState();
}

class _LojasListScreenState extends State<LojasListScreen> with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;
  bool _firstLoad = true;
  bool _enderecoCarregado = false;
  StreamSubscription? _localizacaoSubscription;

  // 🛡️ Throttles específicos
  final Throttle _lojasThrottle = Throttle(const Duration(seconds: 10));
  final Throttle _usuarioThrottle = Throttle(const Duration(minutes: 1));
  final Throttle _loadMoreThrottle = Throttle(const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 [LojasListScreen] initState()');
    _scrollController.addListener(_onScroll);

    _localizacaoSubscription = context.read<LocalizacaoCubit>().stream.listen((state) {
      if (state is LocalizacaoCarregada) {
        _carregarLojas();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🟢 [LojasListScreen] PostFrameCallback');

      final locState = context.read<LocalizacaoCubit>().state;
      if (locState is LocalizacaoCarregada) {
        _carregarLojas();
      } else {
        _verificarEnderecoELojas();
      }

      _firstLoad = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _initialized = true);
      }
    });
  }

  @override
  void dispose() {
    _localizacaoSubscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _carregarLojas() {
    final lojasCubit = context.read<LojasCubit>();
    if (lojasCubit.state is LojasLoaded) {
      debugPrint('✅ [LojasListScreen] Lojas já carregadas, ignorando fetch');
      return;
    }

    if (!_lojasThrottle.shouldRun) {
      debugPrint('⏳ [LojasListScreen] Throttle: fetchLojas ignorado');
      return;
    }

    final locState = context.read<LocalizacaoCubit>().state;
    if (locState is LocalizacaoCarregada) {
      debugPrint('🔍 [LojasListScreen] Carregando lojas pela primeira vez...');
      lojasCubit.fetchLojas(perPage: 10);
    }
  }

  Future<void> _verificarEnderecoELojas() async {
    if (!mounted) return;

    final locCubit = context.read<LocalizacaoCubit>();
    final authCubit = context.read<AuthCubit>();

    debugPrint('🏠 [LojasListScreen] _verificarEnderecoELojas: locState=${locCubit.state.runtimeType}');

    if (locCubit.state is LocalizacaoCarregada) {
      debugPrint('🏠 [LojasListScreen] Endereço carregado, carregando lojas');
      _carregarLojas();
      if (_usuarioThrottle.shouldRun) {
        authCubit.recarregarUsuario();
      }
    } else {
      debugPrint('🔁 [LojasListScreen] Sem endereço, tentando recarregar via EnderecoCubit...');
      final authState = authCubit.state;
      if (authState is AuthAuthenticated || authState is AuthGuest || authState is AuthPerfilCompleto) {
        await context.read<EnderecoCubit>().carregarEnderecos(mostrarLoading: false);
      }
    }
  }

  void _verificarEndereco() {
    if (!_initialized) {
      debugPrint('⏳ [LojasListScreen] _verificarEndereco ignorado: app ainda inicializando');
      return;
    }

    final locState = context.read<LocalizacaoCubit>().state;
    debugPrint('🔍 [LojasListScreen] _verificarEndereco: locState=${locState.runtimeType}');

    if (locState is LocalizacaoNaoEncontrada) {
      context.read<NavigationCubit>().goToHome();
    }
  }

  void _onScroll() {
    if (!_loadMoreThrottle.shouldRun) return;

    final cubit = context.read<LojasCubit>();
    final state = cubit.state;

    if (cubit.hasMorePages && state is LojasLoaded && !state.isLoadingMore) {
      debugPrint('🔄 [LojasListScreen] Carregando mais lojas (página ${cubit.currentPage + 1})');
      cubit.fetchLojas(
        page: cubit.currentPage + 1,
        perPage: 10,
        isLoadMore: true,
      );
    }
  }

  void _showFilter(LojasLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        categorias: state.categorias,
        selectedCategoria: state.categoriaSelecionada,
        selectedOrdenacao: state.ordenacaoAtual,
        initialSearch: _searchController.text,
        onApply: (search, categoria, ordenacao) {
          _searchController.text = search ?? '';
          context.read<LojasCubit>().applyFilters(
            categoria: categoria,
            ordenacao: ordenacao,
            search: search,
          );
        },
        onClear: () {
          _searchController.clear();
          context.read<LojasCubit>().clearAllFilters();
        },
      ),
    );
  }

  void _navegarParaEnderecos(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final String? status = authState.user?.status;

    if (status == 'ativo' || status == 'pendente' || status == 'convidado') {
      context.push(Routes.meusEnderecos).then((_) {
        _verificarEndereco();
      });
    } else {
      context.push(Routes.login, extra: {'origem': NavigationOrigins.home});
    }
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return BlocBuilder<LocalizacaoCubit, LocalizacaoState>(
      builder: (context, state) {
        debugPrint('🔍 [LojasListScreen] LocalizacaoState: ${state.runtimeType}');
        String titulo = 'Selecionar endereço';

        if (state is LocalizacaoCarregada) {
          titulo = state.enderecoFormatado;
          debugPrint('🔍 [LojasListScreen] Exibindo endereço: $titulo');
        }

        return GestureDetector(
          onTap: () => _navegarParaEnderecos(context),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  titulo,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint('🏗️ [LojasListScreen] build() iniciado');
    return BlocListener<LocalizacaoCubit, LocalizacaoState>(
      listener: (context, state) {
        if (state is LocalizacaoCarregada) {
          _enderecoCarregado = true;
        }

        if (_initialized && state is LocalizacaoNaoEncontrada) {
          if (_enderecoCarregado) {
            _verificarEndereco();
          }
        }
      },
      child: BlocBuilder<LojasCubit, LojasState>(
        builder: (context, state) {
          debugPrint('📢 [LojasListScreen] BlocBuilder LojasState: ${state.runtimeType}');
          return ResponsivePageScaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            drawer: const AppDrawer(),
            appBar: AppBar(
              title: _buildAppBarTitle(context),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {},
                ),
              ],
            ),
            bottomNavigationBar: const CarrinhoBottomBar(),
            body: RefreshIndicator(
              onRefresh: () => context.read<LojasCubit>().refreshList(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.extentAfter < 300) {
                    _onScroll();
                  }
                  return false;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildSearchTrigger(state),
                    ),
                    _buildSliverBody(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchTrigger(LojasState state) {
    String summary = 'Pesquisar lojas...';
    bool hasFilters = false;

    if (state is LojasLoaded) {
      final List<String> parts = [];
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        parts.add('"${state.searchQuery}"');
      }
      if (state.categoriaSelecionada != null) {
        parts.add(_getCategoriaLabel(state.categoriaSelecionada!, state.categorias));
      }
      if (state.ordenacaoAtual != null) {
        parts.add(_getOrdenacaoLabel(state.ordenacaoAtual!));
      }

      if (parts.isNotEmpty) {
        summary = parts.join(' • ');
        hasFilters = true;
      }
    }

    final primaryColor = Theme.of(context).primaryColor;
    final hintColor = Theme.of(context).hintColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GestureDetector(
        onTap: () {
          if (state is LojasLoaded) _showFilter(state);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFilters ? primaryColor : Colors.grey.shade300,
              width: hasFilters ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: hasFilters ? primaryColor : hintColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: hasFilters ? Theme.of(context).textTheme.bodyLarge?.color : hintColor,
                    fontWeight: hasFilters ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasFilters)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context.read<LojasCubit>().clearAllFilters();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.close, size: 20, color: Colors.orange),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoriaLabel(String value, List<LojasListFilterOptionModel> categorias) {
    try {
      return categorias.firstWhere((c) => c.value == value).label;
    } catch (_) {
      return value;
    }
  }

  String _getOrdenacaoLabel(String value) {
    switch (value) {
      case 'nota':
        return 'Melhor avaliados';
      case 'tempo_entrega':
        return 'Menor tempo';
      case 'taxa_entrega':
        return 'Menor taxa';
      case 'pedido_minimo':
        return 'Menor pedido mínimo';
      default:
        return value;
    }
  }

  Widget _buildSliverBody(LojasState state) {
    if (state is LojasLoading || state is LojasInitial) {
      return SliverToBoxAdapter(child: _buildLoadingState());
    }

    if (state is LojasLoaded) {
      final lojas = state.lojasFiltradas;
      if (lojas.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(state.lojas.isEmpty),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= lojas.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final loja = lojas[index];
            return Column(
              children: [
                LojaItem(
                  loja: loja,
                  onTap: () => context.read<NavigationCubit>().goToLojaHome(loja.id),
                ),
                if (index < lojas.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.shade300.withValues(alpha: 0.5),
                  ),
              ],
            );
          },
          childCount: lojas.length + (state.isLoadingMore ? 1 : 0),
        ),
      );
    }

    if (state is LojasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(state.message)),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox());
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            LoadingSkeleton(width: 52, height: 52, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingSkeleton(width: 150, height: 16),
                  const SizedBox(height: 8),
                  LoadingSkeleton(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isOverallEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 80,
            color: Theme.of(context).hintColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma loja encontrada',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isOverallEmpty ? 'Volte mais tarde!' : 'Tente outros filtros',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          if (!isOverallEmpty)
            TextButton(
              onPressed: () => context.read<LojasCubit>().clearAllFilters(),
              child: const Text('Limpar filtros'),
            ),
        ],
      ),
    );
  }
}

// 🛡️ Classe Throttle simples para controle de intervalo
class Throttle {
  final Duration interval;
  DateTime? _lastRun;

  Throttle(this.interval);

  bool get shouldRun {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      return true;
    }
    return false;
  }
}
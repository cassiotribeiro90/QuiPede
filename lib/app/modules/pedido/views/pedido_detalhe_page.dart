// lib/app/modules/pedido/views/pedido_detalhe_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/core/theme/app_colors.dart';
import 'package:quipede/app/core/widgets/primary_button.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../navigation/navigation_cubit.dart';
import '../bloc/pedido_cubit.dart';
import '../../chat/views/chat_screen.dart';
import '../models/pedido_detalhe_model.dart';
import '../widgets/pedido_status_timeline.dart';
import '../widgets/avaliacao_bottom_sheet.dart';
import '../widgets/star_rating.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../services/push_service.dart';

class PedidoDetalhePage extends StatefulWidget {
  final int pedidoId;

  const PedidoDetalhePage({super.key, required this.pedidoId});

  @override
  State<PedidoDetalhePage> createState() => _PedidoDetalhePageState();
}

class _PedidoDetalhePageState extends State<PedidoDetalhePage> {
  StreamSubscription? _pushSubscription;
  Timer? _pollingTimer;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<PedidoDetalheModel?> _pedidoNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidoCubit>().carregarDetalhes(widget.pedidoId);
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _atualizarSilenciosamente();
    });

    _pushSubscription = PushService().onPedidoStatus.listen((event) {
      if (!mounted) return;
      if (event.pedidoId == 'polling' || event.pedidoId == widget.pedidoId.toString()) {
        _atualizarSilenciosamente();
      }
    });
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    _pollingTimer?.cancel();
    _scrollController.dispose();
    _pedidoNotifier.dispose();
    super.dispose();
  }

  Future<void> _atualizarSilenciosamente() async {
    try {
      final cubit = context.read<PedidoCubit>();
      final novoPedido = await cubit.service.getPedidoDetalhe(widget.pedidoId);
      if (mounted) {
        _pedidoNotifier.value = novoPedido;
      }
    } catch (_) {}
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final navigationCubit = context.read<NavigationCubit>();

    return BlocConsumer<PedidoCubit, PedidoState>(
      listener: (context, state) {
        if (state is PedidoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is PedidoDetalheCarregado) {
          _pedidoNotifier.value = state.pedido;
        }
      },
      builder: (context, state) {
        return ResponsivePageScaffold(
          appBar: AppBar(
            title: Text('Pedido #${widget.pedidoId}'),
            backgroundColor: context.surfaceColor,
            foregroundColor: context.textPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => navigationCubit.goToPedidos(),
            ),
          ),
          backgroundColor: context.backgroundColor,
          body: _buildBody(context, state),
          floatingActionButton: _buildFab(context, state),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget? _buildFab(BuildContext context, PedidoState state) {
    if (state is PedidoDetalheCarregado) {
      final pedido = state.pedido;
      if (pedido.chatDisponivel) {
        return FloatingActionButton.extended(
          onPressed: () => _iniciarChat(context, pedido),
          icon: const Icon(Icons.chat_bubble_outline),
          label: Row(
            children: [
              const Text('Falar sobre o pedido'),
              if (pedido.totalMensagens > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${pedido.totalMensagens}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          backgroundColor: AppColors.chatPrimary,
          foregroundColor: Colors.white,
        );
      }
    }
    return null;
  }

  void _iniciarChat(BuildContext context, dynamic pedido) {
    final mensagem = 'Olá! Estou com uma dúvida sobre o pedido #${pedido.pedidoCodigo ?? pedido.id}.';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          pedidoId: pedido.id,
          mensagemInicial: mensagem,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PedidoState state) {
    final navigationCubit = context.read<NavigationCubit>();

    if (state is PedidoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PedidoDetalheCarregado) {
      return ValueListenableBuilder<PedidoDetalheModel?>(
        valueListenable: _pedidoNotifier,
        builder: (context, pedidoAtual, _) {
          final pedido = pedidoAtual ?? state.pedido;

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 AVALIAÇÃO DO PEDIDO NO TOPO ABSOLUTO (se entregue)
                if (pedido.status == 'entregue') ...[
                  _buildAvaliacaoPedidoCard(context, pedido),
                  const SizedBox(height: 16),
                ],

                // Status do Pedido
                _buildSectionTitle(context, 'Status do Pedido'),
                const SizedBox(height: 12),
                PedidoStatusTimeline(
                  status: pedido.status,
                  timestamps: {
                    'criado_at': pedido.criadoEm,
                    'confirmado_at': pedido.confirmadoEm,
                    'em_preparo_at': pedido.emPreparoEm,
                    'saiu_entrega_at': pedido.saiuEntregaEm,
                    'entregue_at': pedido.entregueEm,
                    'cancelado_at': pedido.canceladoEm,
                  },
                ),
                const Divider(height: 32, thickness: 1),

                _buildSectionTitle(context, 'Itens do Pedido'),
                const SizedBox(height: 8),
                ...pedido.itens.map((item) {
                  final avaliacao = item.avaliacao;
                  final podeAvaliar = pedido.status == 'entregue';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        if (podeAvaliar)
                          IconButton(
                            onPressed: () => _abrirAvaliacaoProduto(pedido, item),
                            icon: Icon(
                              avaliacao != null
                                  ? Icons.thumb_up_rounded
                                  : Icons.thumb_up_outlined,
                              size: 18,
                              color: avaliacao != null
                                  ? AppColors.primary
                                  : Colors.grey[400],
                            ),
                            padding: const EdgeInsets.all(12), // 🔥 Mais padding
                            constraints: const BoxConstraints(),
                            tooltip: avaliacao != null
                                ? (avaliacao.status == 'pendente'
                                ? 'Editar avaliação'
                                : 'Avaliação aprovada')
                                : 'Avaliar produto',
                            visualDensity: VisualDensity.compact,
                          ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.nome, style: context.bodyLarge),
                              Text(
                                '${item.quantidade}x ${_formatarMoeda(item.precoUnitario)}',
                                style: context.bodySmall.copyWith(color: context.textSecondary),
                              ),
                              if (avaliacao != null)
                                StarRating(
                                  nota: avaliacao.nota,
                                  interactive: false,
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                        Text(
                          _formatarMoeda(item.precoTotal),
                          style: context.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 32, thickness: 1),

                // Endereço, Pagamento, Resumo, botões...
                _buildSectionTitle(context, 'Endereço de Entrega'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, color: context.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${pedido.endereco.logradouro}, ${pedido.endereco.numero}${pedido.endereco.complemento != null && pedido.endereco.complemento!.isNotEmpty ? " - ${pedido.endereco.complemento}" : ""}\n${pedido.endereco.bairro}, ${pedido.endereco.cidade} - ${pedido.endereco.uf}',
                        style: context.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, thickness: 1),

                _buildSectionTitle(context, 'Pagamento'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payments_outlined, color: context.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pedido.formaPagamentoLabel, style: context.bodyLarge),
                          if (pedido.trocoPara != null)
                            Text(
                              'Troco para ${_formatarMoeda(pedido.trocoPara!)}',
                              style: context.bodySmall.copyWith(color: context.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, thickness: 1),

                _buildSectionTitle(context, 'Resumo'),
                const SizedBox(height: 8),
                _buildResumoRow(context, 'Subtotal', _formatarMoeda(pedido.subtotal)),
                const SizedBox(height: 6),
                _buildResumoRow(context, 'Taxa de entrega', _formatarMoeda(pedido.taxaEntrega)),
                const Divider(height: 16, thickness: 1),
                _buildResumoRow(context, 'Total', _formatarMoeda(pedido.total), isTotal: true),
                const SizedBox(height: 32),

                if (pedido.status == 'pendente' || pedido.status == 'confirmado' || pedido.status == 'novo')
                  SecondaryOutlineButton(
                    onPressed: () => _confirmarCancelamento(context, pedido.id),
                    label: 'Cancelar Pedido',
                    color: Colors.red,
                    height: 50,
                  ),
                const SizedBox(height: 12),
                SecondaryOutlineButton(
                  onPressed: () => navigationCubit.goToPedidos(),
                  label: 'Ver Meus Pedidos',
                  height: 50,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  onPressed: () {
                    navigationCubit.goToHomeAndRemoveAll();
                  },
                  label: 'Voltar para Lojas',
                  height: 50,
                ),
                const SizedBox(height: 68),
              ],
            ),
          );
        },
      );
    }

    return const Center(child: Text('Nenhum dado encontrado para este pedido.'));
  }

  // 🔥 Card de avaliação do pedido com destaque (usa estrela)
  Widget _buildAvaliacaoPedidoCard(BuildContext context, dynamic pedido) {
    final theme = Theme.of(context);
    final lojaNome = pedido.lojaNome ?? 'Loja';
    final temAvaliacao = pedido.avaliacaoPedido != null;
    final isPendente = temAvaliacao && pedido.avaliacaoPedido!.status == 'pendente';

    // Cores do fundo
    final Color bgColor = temAvaliacao
        ? theme.colorScheme.primary.withValues(alpha: 0.08) // pastel
        : theme.colorScheme.primary;
    final Color textColor = temAvaliacao
        ? theme.colorScheme.onSurface
        : Colors.white;
    final Color subTextColor = temAvaliacao
        ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
        : Colors.white70;

    return Card(
      elevation: temAvaliacao ? 1 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: temAvaliacao
            ? BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          gradient: temAvaliacao
              ? null
              : LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rate_rounded,
                  color: temAvaliacao ? Colors.amber : Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Avaliar pedido - $lojaNome',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              temAvaliacao
                  ? (isPendente
                  ? 'Você já avaliou este pedido. Toque para editar.'
                  : 'Sua avaliação deste pedido foi aprovada.')
                  : 'Aproveite para avaliar sua experiência geral!',
              style: TextStyle(color: subTextColor),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _abrirAvaliacaoPedido(pedido),
              icon: Icon(
                pedido.avaliacaoPedido != null
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: textColor,
              ),
              label: Text(
                temAvaliacao ? 'Ver/Editar Avaliação' : 'Avaliar Pedido',
                style: TextStyle(color: textColor),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: temAvaliacao
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
                side: BorderSide(
                  color: temAvaliacao ? theme.colorScheme.primary : Colors.white,
                ),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirAvaliacaoPedido(dynamic pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AvaliacaoBottomSheet(
        pedidoId: pedido.id,
        lojaId: pedido.lojaId,
        tipo: TipoAvaliacao.pedido,
        avaliacaoExistente: pedido.avaliacaoPedido,
        lojaNome: pedido.lojaNome,
        onSuccess: () {
          _atualizarSilenciosamente();
        },
      ),
    );
  }

  void _abrirAvaliacaoProduto(dynamic pedido, dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AvaliacaoBottomSheet(
        pedidoId: pedido.id,
        produtoId: item.produtoId,
        lojaId: pedido.lojaId,
        tipo: TipoAvaliacao.produto,
        avaliacaoExistente: item.avaliacao,
        produtoNome: item.nome,
        onSuccess: () {
          _atualizarSilenciosamente();
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildResumoRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? context.titleLarge.copyWith(fontWeight: FontWeight.bold)
              : context.bodyMedium.copyWith(color: context.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? context.titleLarge.copyWith(fontWeight: FontWeight.bold, color: context.primaryColor)
              : context.bodyLarge,
        ),
      ],
    );
  }

  Future<void> _confirmarCancelamento(BuildContext context, int pedidoId) async {
    final cubit = context.read<PedidoCubit>();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('Deseja realmente cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Não'),
          ),
          PrimaryButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            label: 'Sim, cancelar',
            backgroundColor: Colors.red,
            isFullWidth: false,
          ),
        ],
      ),
    );

    if (confirmado == true) {
      cubit.cancelarPedido(pedidoId);
    }
  }
}
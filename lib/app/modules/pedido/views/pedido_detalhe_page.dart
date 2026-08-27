import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/core/widgets/primary_button.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../navigation/navigation_cubit.dart';
import '../bloc/pedido_cubit.dart';
import '../widgets/pedido_status_timeline.dart';
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

  @override
  void initState() {
    super.initState();
    // 🔥 Chamada imediata para carregar os dados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidoCubit>().carregarDetalhes(widget.pedidoId);
    });

    _pushSubscription = PushService().onPedidoStatus.listen((event) {
      if (!mounted) return;

      // Se for polling ou atualização específica deste pedido
      if (event.pedidoId == 'polling' || event.pedidoId == widget.pedidoId.toString()) {
        context.read<PedidoCubit>().carregarDetalhes(widget.pedidoId);
      }
    });
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    super.dispose();
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
          final status = state.pedido.status.toLowerCase();
          if (status == 'entregue' || status == 'cancelado') {
            // Polling removido, PushService cuida das atualizações
          }
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
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PedidoState state) {
    final navigationCubit = context.read<NavigationCubit>();

    if (state is PedidoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PedidoDetalheCarregado) {
      final pedido = state.pedido;
      final timestamps = {
        'criado_at': pedido.criadoEm,
        'confirmado_at': pedido.confirmadoEm,
        'em_preparo_at': pedido.emPreparoEm,
        'saiu_entrega_at': pedido.saiuEntregaEm,
        'entregue_at': pedido.entregueEm,
        'cancelado_at': pedido.canceladoEm,
      };

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Status do Pedido'),
            const SizedBox(height: 12),
            PedidoStatusTimeline(
              status: pedido.status,
              timestamps: timestamps,
            ),
            const Divider(height: 32, thickness: 1),

            _buildSectionTitle(context, 'Itens do Pedido'),
            const SizedBox(height: 8),
            ...pedido.itens.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
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
                      ],
                    ),
                  ),
                  Text(
                    _formatarMoeda(item.precoTotal),
                    style: context.bodyLarge,
                  ),
                ],
              ),
            )),
            const Divider(height: 32, thickness: 1),

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
            _buildResumoRow(
              context,
              'Total',
              _formatarMoeda(pedido.total),
              isTotal: true,
            ),
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
            const SizedBox(height: 32),
          ],
        ),
      );
    }

    return const Center(child: Text('Nenhum dado encontrado para este pedido.'));
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
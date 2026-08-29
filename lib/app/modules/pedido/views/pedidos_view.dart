import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../navigation/navigation_cubit.dart';
import '../bloc/pedido_cubit.dart';
import '../models/pedido_detalhe_model.dart';
import '../../../services/push_service.dart';
import '../../../core/widgets/primary_button.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../../shared/widgets/chat_button.dart';
import '../../../shared/widgets/badge_widget.dart';

class PedidosView extends StatefulWidget {
  const PedidosView({super.key});

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {
  StreamSubscription? _pushSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PedidoCubit>().carregarPedidos();
      }
    });

    _pushSubscription = PushService().onPedidoStatus.listen((event) {
      if (mounted && event.pedidoId != 'polling') {
        context.read<PedidoCubit>().carregarPedidos();
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

  String _formatarData(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final navigationCubit = context.read<NavigationCubit>();

    return BlocProvider(
      create: (context) => ChatBloc(),
      child: BlocBuilder<PedidoCubit, PedidoState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.backgroundColor,
            appBar: AppBar(
              title: const Text('Meus Pedidos'),
              backgroundColor: context.surfaceColor,
              foregroundColor: context.textPrimary,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => navigationCubit.goToHomeAndRemoveAll(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<PedidoCubit>().carregarPedidos(),
                  tooltip: 'Atualizar pedidos',
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PedidoState state) {
    if (state is PedidoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PedidoError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<PedidoCubit>().carregarPedidos(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (state is PedidoListaCarregada) {
      return _buildLista(context, state.pedidos);
    }

    if (state is PedidoDetalheCarregado) {
      return _buildLista(context, state.pedidos);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLista(BuildContext context, List<PedidoDetalheModel> pedidos) {
    final navigationCubit = context.read<NavigationCubit>();

    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: context.textHint),
            const SizedBox(height: 16),
            Text('Você ainda não fez nenhum pedido', style: context.bodyLarge),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () => navigationCubit.goToHomeAndRemoveAll(),
              label: 'Ir às compras',
              isFullWidth: false,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<PedidoCubit>().carregarPedidos(),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: pedidos.length,
        separatorBuilder: (_, __) => const Divider(height: 0.5),
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          return _buildPedidoItem(context, pedido);
        },
      ),
    );
  }

  Widget _buildPedidoItem(BuildContext context, PedidoDetalheModel pedido) {
    final navigationCubit = context.read<NavigationCubit>();

    return InkWell(
      onTap: () => navigationCubit.goToPedidoDetalhe(pedido.id),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // 🔥 PADDING INTERNO
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔥 ÍCONE DA LOJA
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: pedido.lojaLogo != null && pedido.lojaLogo!.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(pedido.lojaLogo!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: pedido.lojaLogo == null || pedido.lojaLogo!.isEmpty
                  ? Icon(Icons.store, size: 28, color: Colors.grey[400])
                  : null,
            ),
            const SizedBox(width: 14),

            // 🔥 INFORMAÇÕES DO PEDIDO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pedido.lojaNome ?? 'Loja Desconhecida',
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Pedido #${pedido.id}', style: context.bodySmall),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: context.textHint),
                      const SizedBox(width: 4),
                      Text(
                        _formatarData(pedido.criadoEm),
                        style: context.bodySmall.copyWith(color: context.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 🔥 STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: pedido.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: pedido.statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pedido.statusIcon,
                              size: 14,
                              color: pedido.statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pedido.statusLabel,
                              style: TextStyle(
                                color: pedido.statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 🔥 ITENS
                      Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 14, color: context.textHint),
                          const SizedBox(width: 4),
                          Text(
                            '${pedido.itemCount} ${pedido.itemCount == 1 ? 'item' : 'itens'}',
                            style: context.bodySmall.copyWith(color: context.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 🔥 VALOR E CHAT
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatarMoeda(pedido.total),
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                if (pedido.chatDisponivel) ...[
                  const SizedBox(height: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ChatButton(
                        pedidoId: pedido.id,
                        mensagemInicial: 'Olá! Estou com uma dúvida sobre o pedido #${pedido.pedidoCodigo ?? pedido.id}.',
                        showLabel: false,
                      ),
                      if (pedido.totalMensagens > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: BadgeWidget(
                            count: pedido.totalMensagens,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: context.textHint),
          ],
        ),
      ),
    );
  }
}
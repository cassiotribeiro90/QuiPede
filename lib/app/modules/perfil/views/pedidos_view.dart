import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../di/dependencies.dart';
import '../../../services/navigation_service.dart';
import '../../pedido/bloc/pedido_cubit.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class PedidosView extends StatefulWidget {
  const PedidosView({super.key});

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {
  @override
  void initState() {
    super.initState();
    context.read<PedidoCubit>().carregarPedidos();
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedidoCubit, PedidoState>(
      builder: (context, state) {
        return ResponsivePageScaffold(
          appBar: AppBar(
            title: const Text('Meus Pedidos'),
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
      if (state.pedidos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: context.textHint),
              const SizedBox(height: 16),
              Text('Você ainda não fez nenhum pedido', style: context.bodyLarge),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => getIt<NavigationService>().goToHomeAndRemoveAll(),
                child: const Text('Ir às compras'),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<PedidoCubit>().carregarPedidos(),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.pedidos.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final pedido = state.pedidos[index];
                  return _buildPedidoItem(context, pedido);
                },
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // 🔥 ITEM DA LISTA COM LOGO E PREÇO CENTRALIZADOS
  Widget _buildPedidoItem(BuildContext context, dynamic pedido) {
    return InkWell(
      onTap: () => getIt<NavigationService>().goToPedidoDetalhe(pedido.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 🔥 CENTRALIZA VERTICALMENTE
          children: [
            // 🔥 LOGO DA LOJA
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
                  // ID e data
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
                  // Status e itens
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: pedido.statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: pedido.statusColor.withOpacity(0.3),
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

            // 🔥 TOTAL (CENTRALIZADO VERTICALMENTE)
            Text(
              _formatarMoeda(pedido.total),
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: context.textHint),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../routes/app_routes.dart';
import '../../pedido/bloc/pedido_cubit.dart';

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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregue': return Colors.green;
      case 'cancelado': return Colors.red;
      case 'saiu_entrega':
      case 'em_preparo': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
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
      body: BlocBuilder<PedidoCubit, PedidoState>(
        builder: (context, state) {
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
                  OutlinedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, Routes.home),
                    child: const Text('Voltar para o início'),
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
                      onPressed: () => Navigator.pushReplacementNamed(context, Routes.home),
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
                      padding: const EdgeInsets.all(16),
                      itemCount: state.pedidos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pedido = state.pedidos[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(
                              context, 
                              Routes.pedidoDetalhe, 
                              arguments: pedido.id
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          pedido.lojaNome ?? 'Loja Desconhecida',
                                          style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(pedido.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          pedido.statusLabel,
                                          style: TextStyle(
                                            color: _getStatusColor(pedido.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: context.surfaceColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${pedido.itens.length}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              pedido.itens.map((i) => i.nome).join(', '),
                                              style: context.bodySmall.copyWith(color: context.textSecondary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              _formatarData(pedido.criadoEm),
                                              style: context.bodySmall.copyWith(color: context.textHint),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _formatarMoeda(pedido.total),
                                        style: context.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, Routes.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Voltar para o Início'),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

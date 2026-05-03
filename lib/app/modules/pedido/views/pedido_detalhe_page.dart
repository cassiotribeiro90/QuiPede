import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../routes/app_routes.dart';
import '../bloc/pedido_cubit.dart';
import '../widgets/pedido_status_timeline.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class PedidoDetalhePage extends StatefulWidget {
  final int pedidoId;

  const PedidoDetalhePage({super.key, required this.pedidoId});

  @override
  State<PedidoDetalhePage> createState() => _PedidoDetalhePageState();
}

class _PedidoDetalhePageState extends State<PedidoDetalhePage> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<PedidoCubit>().carregarDetalhes(widget.pedidoId);
      }
    });
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
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
            _pollingTimer?.cancel();
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
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, Routes.pedidos);
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: PedidoStatusTimeline(
                status: pedido.status,
                timestamps: timestamps,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Itens do Pedido'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              child: Column(
                children: pedido.itens.map((item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.nome, style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.quantidade}x ${_formatarMoeda(item.precoUnitario)}'),
                    trailing: Text(_formatarMoeda(item.precoTotal), style: context.bodyLarge),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Endereço de Entrega'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: context.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${pedido.endereco.logradouro}, ${pedido.endereco.numero}${pedido.endereco.complemento != null ? " - ${pedido.endereco.complemento}" : ""}\n${pedido.endereco.bairro}, ${pedido.endereco.cidade} - ${pedido.endereco.uf}',
                      style: context.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Pagamento'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              child: Row(
                children: [
                  Icon(Icons.payments_outlined, color: context.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pedido.formaPagamentoLabel, style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        if (pedido.trocoPara != null)
                          Text('Troco para ${_formatarMoeda(pedido.trocoPara!)}', style: context.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Resumo'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              child: Column(
                children: [
                  _buildResumoRow(context, 'Subtotal', _formatarMoeda(pedido.subtotal)),
                  const SizedBox(height: 8),
                  _buildResumoRow(context, 'Taxa de entrega', _formatarMoeda(pedido.taxaEntrega)),
                  const Divider(height: 24),
                  _buildResumoRow(
                    context, 
                    'Total', 
                    _formatarMoeda(pedido.total),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (pedido.status == 'pendente' || pedido.status == 'confirmado' || pedido.status == 'novo')
              OutlinedButton(
                onPressed: () => _confirmarCancelamento(context, pedido.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancelar Pedido'),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, Routes.pedidos);
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ver Meus Pedidos'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Voltar para Lojas'),
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

  Widget _buildInfoCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor.withOpacity(0.5)),
      ),
      child: child,
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
      builder: (context) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('Deseja realmente cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      cubit.cancelarPedido(pedidoId);
    }
  }
}

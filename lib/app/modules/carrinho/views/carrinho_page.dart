import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/carrinho_cubit.dart';
import '../../pedido/bloc/pedido_cubit.dart';
import '../widgets/quantity_selector.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../../../../shared/widgets/endereco_selecionado_widget.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../routes/app_routes.dart';

class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({super.key});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  final _trocoController = TextEditingController();
  final _observacaoController = TextEditingController();

  @override
  void dispose() {
    _trocoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF57C00);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Minha Sacola'),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimary,
        elevation: 0,
        actions: [
          BlocBuilder<CarrinhoCubit, CarrinhoState>(
            builder: (context, state) {
              if (state is CarrinhoLoaded && state.itens.isNotEmpty) {
                final bool isBlocked = state.isDebouncing || state.isRequesting;
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: isBlocked ? null : () => _confirmarLimparCarrinho(context),
                  tooltip: 'Limpar sacola',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: context.backgroundColor,
      body: MultiBlocListener(
        listeners: [
          BlocListener<CarrinhoCubit, CarrinhoState>(
            listener: (context, state) {
              if (state is CarrinhoError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
          BlocListener<PedidoCubit, PedidoState>(
            listener: (context, state) {
              if (state is PedidoCriado) {
                context.read<CarrinhoCubit>().limparCarrinho();
                Navigator.pushReplacementNamed(
                  context,
                  Routes.pedidoDetalhe,
                  arguments: state.pedidoId,
                );
              } else if (state is PedidoError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<CarrinhoCubit, CarrinhoState>(
          builder: (context, state) {
            if (state is CarrinhoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CarrinhoLoaded) {
              if (state.itens.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 80, color: context.textHint),
                      const SizedBox(height: 16),
                      Text(
                        'Sua sacola está vazia',
                        style: context.titleMedium.copyWith(color: context.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Continuar Comprando'),
                      ),
                    ],
                  ),
                );
              }

              final bool isOperationPending = state.isDebouncing || state.isRequesting;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.lojaNome != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            color: primaryColor,
                            child: Text(
                              state.lojaNome!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            color: context.surfaceColor,
                            child: BlocBuilder<LocalizacaoCubit, LocalizacaoState>(
                              builder: (context, locState) {
                                return EnderecoSelecionadoWidget(
                                  endereco: locState is LocalizacaoCarregada ? locState.endereco : null,
                                  onTap: () {
                                    // Pode abrir modal de troca de endereço ou onboarding
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    const Divider(height: 1),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: state.itens.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = state.itens[index];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.imagem != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imagem!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.nome,
                                      style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    if (item.observacao != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          item.observacao!,
                                          style: context.bodySmall.copyWith(color: context.textSecondary),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatarMoeda(item.precoTotal),
                                          style: context.bodyLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isOperationPending ? context.textHint : context.primaryColor,
                                          ),
                                        ),
                                        QuantitySelector(
                                          quantity: item.quantidade,
                                          itemName: item.nome,
                                          onChanged: (novaQtd) {
                                            context.read<CarrinhoCubit>().atualizarQuantidade(item.id, novaQtd);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    _buildObservacoes(context),
                    _buildFormaPagamentoSection(context, state),
                    _buildResumo(context, state),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildObservacoes(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Observações do pedido',
            style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observacaoController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Alguma preferência? Ex: Tirar cebola, campainha estragada...',
              hintStyle: context.bodySmall.copyWith(color: context.textHint),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormaPagamentoSection(BuildContext context, CarrinhoLoaded state) {
    final formasDisponiveis = state.formasPagamento.keys.toList();
    if (formasDisponiveis.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como deseja pagar?',
            style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecione uma opção abaixo',
            style: context.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: formasDisponiveis.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final key = formasDisponiveis[index];
              final forma = state.formasPagamento[key];
              final label = forma['label'] ?? key;
              final selecionado = state.formaPagamentoSelecionada == key;
              final icone = _getIconePagamento(key);
              final descricao = _getDescricaoPagamento(key);

              return Card(
                margin: EdgeInsets.zero,
                elevation: selecionado ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selecionado ? context.primaryColor : Colors.grey.shade300,
                    width: selecionado ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    context.read<CarrinhoCubit>().selecionarFormaPagamento(key);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(icone, size: 32, color: context.primaryColor),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: context.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                descricao,
                                style: context.bodySmall.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selecionado ? Icons.check_circle : Icons.circle_outlined,
                          color: selecionado ? context.primaryColor : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (state.formaPagamentoSelecionada == 'dinheiro' && 
              state.formasPagamento['dinheiro']?['troco'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precisa de troco?',
                      style: context.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _trocoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}'))],
                      decoration: InputDecoration(
                        labelText: 'Troco para quanto?',
                        hintText: 'Ex: 50,00',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: context.primaryColor),
                        ),
                      ),
                      onChanged: (val) {
                        final valor = double.tryParse(val.replaceAll(',', '.'));
                        context.read<CarrinhoCubit>().atualizarTrocoPara(valor);
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconePagamento(String key) {
    switch (key.toLowerCase()) {
      case 'dinheiro':
        return Icons.attach_money;
      case 'cartao_entrega':
      case 'cartao':
        return Icons.credit_card;
      case 'pix':
        return Icons.pix;
      case 'cartao_online':
        return Icons.credit_card_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  String _getDescricaoPagamento(String key) {
    switch (key.toLowerCase()) {
      case 'dinheiro':
        return 'Pague diretamente ao entregador';
      case 'cartao_entrega':
      case 'cartao':
        return 'Cartão de débito/crédito na entrega';
      case 'pix':
        return 'Pagamento instantâneo via PIX';
      case 'cartao_online':
        return 'Cartão de crédito online';
      default:
        return 'Selecione sua forma de pagamento';
    }
  }

  Widget _buildResumo(BuildContext context, CarrinhoLoaded state) {
    final bool isBlocked = state.isDebouncing || state.isRequesting;
    final bool temFrete = state.taxaEntrega != null;
    final valorTotal = state.total ?? state.subtotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: context.bodyMedium.copyWith(color: context.textSecondary)),
                Text(
                  _formatarMoeda(state.subtotal),
                  style: context.bodyLarge,
                ),
              ],
            ),
            if (temFrete) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Taxa de entrega', style: context.bodyMedium.copyWith(color: context.textSecondary)),
                  Text(
                    state.taxaEntrega! > 0 
                      ? _formatarMoeda(state.taxaEntrega!)
                      : 'Grátis',
                    style: context.bodyLarge.copyWith(
                      color: state.taxaEntrega! == 0 ? Colors.green : null,
                      fontWeight: state.taxaEntrega! == 0 ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: context.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  _formatarMoeda(valorTotal),
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isBlocked ? context.textHint : context.primaryColor,
                  ),
                ),
              ],
            ),
            if (state.distanciaKm != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: context.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Distância: ${state.distanciaKm!.toStringAsFixed(1)} km',
                      style: context.bodySmall.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            BlocBuilder<PedidoCubit, PedidoState>(
              builder: (context, pedidoState) {
                final isCriando = pedidoState is PedidoCriando;
                return ElevatedButton(
                  onPressed: (isBlocked || isCriando || state.formaPagamentoSelecionada == null) ? null : () {
                    _finalizarPedido(context, state);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: (isBlocked || isCriando)
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        'Finalizar Pedido',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizarPedido(BuildContext context, CarrinhoLoaded state) async {
    final locCubit = context.read<LocalizacaoCubit>();
    final locState = locCubit.state;
    
    if (locState is! LocalizacaoCarregada || locState.endereco.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um endereço de entrega salvo'), backgroundColor: Colors.orange),
      );
      return;
    }

    context.read<PedidoCubit>().criarPedido(
      enderecoId: locState.endereco.id!,
      formaPagamento: state.formaPagamentoSelecionada!,
      trocoPara: state.formaPagamentoSelecionada == 'dinheiro' ? state.trocoPara : null,
      observacao: _observacaoController.text.isNotEmpty ? _observacaoController.text : null,
    );
  }

  Future<void> _confirmarLimparCarrinho(BuildContext context) async {
    final cubit = context.read<CarrinhoCubit>();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar sacola'),
        content: const Text('Deseja remover todos os itens da sua sacola?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      cubit.limparCarrinho();
    }
  }
}

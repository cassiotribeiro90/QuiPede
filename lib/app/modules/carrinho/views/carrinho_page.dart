import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/carrinho_cubit.dart';
import '../widgets/quantity_selector.dart';
import '../../../core/theme/app_theme_extension.dart';

class CarrinhoPage extends StatelessWidget {
  const CarrinhoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Sacola'),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimary,
        elevation: 0,
        actions: [
          BlocBuilder<CarrinhoCubit, CarrinhoState>(
            builder: (context, state) {
              if (state is CarrinhoLoaded && state.itens.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmarLimparCarrinho(context),
                  tooltip: 'Limpar sacola',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: context.backgroundColor,
      body: BlocConsumer<CarrinhoCubit, CarrinhoState>(
        listener: (context, state) {
          if (state is CarrinhoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
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

            return Column(
              children: [
                if (state.lojaNome != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: context.primarySurface,
                    child: Text(
                      'Pedido em ${state.lojaNome}',
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.itens.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = state.itens[index];
                      final isUpdating = state.isUpdating && state.updatingItemId == item.id;
                      
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
                                        'R\$ ${item.precoTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                        style: context.bodyLarge.copyWith(
                                          color: context.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      QuantitySelector(
                                        quantity: item.quantidade,
                                        itemName: item.nome,
                                        isLoading: isUpdating,
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
                ),
                _buildResumo(context, state),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildResumo(BuildContext context, CarrinhoLoaded state) {
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
                Text('Total do pedido', style: context.bodyLarge),
                Text(
                  'R\$ ${state.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.isUpdating ? null : () {
                // TODO: Navegar para checkout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isUpdating 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Text(
                    'Finalizar Pedido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            ),
          ],
        ),
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/carrinho_cubit.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../routes/app_routes.dart';

class CarrinhoBottomBar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? lojaNome;
  final bool isLoading;

  const CarrinhoBottomBar({
    super.key,
    this.onTap,
    this.lojaNome,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarrinhoCubit, CarrinhoState>(
      builder: (context, state) {
        if (state is CarrinhoInitial) {
          context.read<CarrinhoCubit>().carregarCarrinho();
          return const SizedBox.shrink();
        }

        int totalItens = 0;
        double subtotal = 0;
        String? nomeLojaDisplay = lojaNome;
        bool isAnyOperationPending = false;
        
        if (state is CarrinhoLoaded) {
          totalItens = state.totalItens;
          subtotal = state.subtotal;
          nomeLojaDisplay ??= state.lojaNome;
          isAnyOperationPending = state.isDebouncing || state.isRequesting;
        }
        
        if (totalItens == 0 && !isAnyOperationPending) {
          return const SizedBox.shrink();
        }

        final VoidCallback onTapAction = onTap ?? () {
          Navigator.pushNamed(context, Routes.carrinho);
        };
        
        final bool isBarLoading = isLoading || isAnyOperationPending;
        
        return Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: InkWell(
              onTap: isBarLoading ? null : onTapAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: isBarLoading 
                  ? Row(
                      children: [
                        const LoadingSkeleton(width: 40, height: 40, borderRadius: 12),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LoadingSkeleton(width: 120, height: 16, borderRadius: 4),
                              const SizedBox(height: 6),
                              LoadingSkeleton(width: 60, height: 12, borderRadius: 4),
                            ],
                          ),
                        ),
                        const LoadingSkeleton(width: 70, height: 20, borderRadius: 4),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sacola - ${nomeLojaDisplay ?? "Loja"}',
                                style: context.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalItens ${totalItens == 1 ? 'item' : 'itens'}',
                                style: context.bodySmall.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Row(
                          children: [
                            Text(
                              'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: context.titleSmall.copyWith(
                                color: context.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios, 
                              size: 14, 
                              color: context.primaryColor
                            ),
                          ],
                        ),
                      ],
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

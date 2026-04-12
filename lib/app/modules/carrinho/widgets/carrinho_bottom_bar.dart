import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/carrinho_cubit.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
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
        
        if (state is CarrinhoLoaded) {
          totalItens = state.totalItens;
          subtotal = state.subtotal;
          nomeLojaDisplay ??= state.lojaNome;
        }
        
        if (totalItens == 0) {
          return const SizedBox.shrink();
        }

        final VoidCallback onTapAction = onTap ?? () {
          Navigator.pushNamed(context, Routes.carrinho);
        };
        
        final bool isBarLoading = isLoading || (state is CarrinhoLoaded && state.isUpdating);
        
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isBarLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
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
                          if (isBarLoading)
                            ShimmerLoading(
                              isLoading: true,
                              child: Container(
                                width: 150,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          else
                            Text(
                              'Sacola - ${nomeLojaDisplay ?? "Loja"}',
                              style: context.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 4),
                          if (isBarLoading)
                            ShimmerLoading(
                              isLoading: true,
                              child: Container(
                                width: 80,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          else
                            Text(
                              '$totalItens ${totalItens == 1 ? 'item' : 'itens'}',
                              style: context.bodySmall.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    if (isBarLoading)
                      ShimmerLoading(
                        isLoading: true,
                        child: Container(
                          width: 80,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                    else
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

import 'package:flutter/material.dart';
import '../../../../app/core/theme/app_theme_extension.dart';
import '../models/secao_produto_model.dart';
import 'produto_card_widget.dart';

class ProdutosListWidget extends StatelessWidget {
  final List<SecaoProdutoModel> secoes;
  final Function(int) onProdutoTap;

  const ProdutosListWidget({
    super.key,
    required this.secoes,
    required this.onProdutoTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = context;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final secao = secoes[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  '${secao.icone ?? ""} ${secao.nome.toUpperCase()}',
                  style: textStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ...secao.produtos.map((produto) => Column(
                    children: [
                      ProdutoCardWidget(
                        produto: produto,
                        onTap: () => onProdutoTap(produto.id),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1),
                      ),
                    ],
                  )),
            ],
          );
        },
        childCount: secoes.length,
      ),
    );
  }
}

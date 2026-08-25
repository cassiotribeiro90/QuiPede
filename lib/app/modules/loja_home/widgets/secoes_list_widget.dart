import 'package:flutter/material.dart';
import '../../../models/secao_model.dart';
import '../../../models/produto_model.dart';
import 'produto_card_unificado.dart';
import '../../../core/theme/app_theme_extension.dart';

class SecoesListWidget extends StatelessWidget {
  final List<SecaoModel> secoes;
  final int lojaId;
  final Function(ProdutoModel) onProdutoTap;
  final Map<int, int> quantidadesPorProduto;
  final Map<int, int> itemIdsPorProduto;
  final Map<int, GlobalKey>? sectionKeys;

  const SecoesListWidget({
    super.key,
    required this.secoes,
    required this.lojaId,
    required this.onProdutoTap,
    required this.quantidadesPorProduto,
    required this.itemIdsPorProduto,
    this.sectionKeys,
  });

  @override
  Widget build(BuildContext context) {
    if (secoes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Nenhum produto encontrado',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final nomesVistosGlobal = <String>{};
    final List<Widget> children = [];

    for (int i = 0; i < secoes.length; i++) {
      final secao = secoes[i];
      final produtosUnicos = secao.produtos.where((p) {
        final chaveUnica = p.nome.trim().toLowerCase();
        final jaVisto = nomesVistosGlobal.contains(chaveUnica);
        if (!jaVisto) nomesVistosGlobal.add(chaveUnica);
        return !jaVisto;
      }).toList();

      final GlobalKey? sectionKey = sectionKeys?[secao.id];

      children.add(
        Container(
          key: sectionKey,
          color: context.surfaceColor,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              if (secao.icone != null && secao.icone!.isNotEmpty) ...[
                Text(secao.icone!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  secao.nome,
                  style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${secao.totalProdutos}',
                  style: context.caption.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (produtosUnicos.isNotEmpty) {
        for (final produto in produtosUnicos) {
          children.add(
            ProdutoCardUnificado(
              key: ValueKey('prod_${produto.id}_${quantidadesPorProduto[produto.id] ?? 0}'),
              produto: produto,
              lojaId: lojaId,
              quantidadeNoCarrinho: quantidadesPorProduto[produto.id] ?? 0,
              itemIdNoCarrinho: itemIdsPorProduto[produto.id],
              onTap: () => onProdutoTap(produto),
            ),
          );
        }
      } else if (secao.hasMore) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }

      children.add(
        Column(
          children: [
            if (secao.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            Divider(
              height: 1,
              thickness: 8,
              color: context.dividerColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
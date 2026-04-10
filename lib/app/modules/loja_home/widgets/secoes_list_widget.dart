// lib/modules/loja_home/widgets/secoes_list_widget.dart

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

  static int _buildCount = 0;

  const SecoesListWidget({
    super.key,
    required this.secoes,
    required this.lojaId,
    required this.onProdutoTap,
    required this.quantidadesPorProduto,
    required this.itemIdsPorProduto,
  });

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 [SecoesListWidget] BUILD #$_buildCount');
    print('📋 Recebeu: ${secoes.length} seções');

    if (secoes.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Nenhum produto encontrado', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // ✅ Usar um Set de NOMES para evitar duplicatas visuais quando os IDs da API estão vindo errados
    final nomesVistosGlobal = <String>{};
    final List<Widget> sliverChildren = [];

    for (var secao in secoes) {
      final produtosUnicos = secao.produtos.where((p) {
        // Criamos uma chave baseada no nome para detectar duplicatas "zumbis" da API
        final chaveUnica = p.nome.trim().toLowerCase();
        final jaVisto = nomesVistosGlobal.contains(chaveUnica);
        if (!jaVisto) nomesVistosGlobal.add(chaveUnica);
        return !jaVisto;
      }).toList();

      if (produtosUnicos.isEmpty) continue;

      // Cabeçalho da seção
      sliverChildren.add(
        Container(
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
                  '${produtosUnicos.length}',
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

      // Cards dos produtos
      for (var produto in produtosUnicos) {
        sliverChildren.add(
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

      // Divisor entre seções
      sliverChildren.add(
        Divider(height: 1, thickness: 8, color: context.dividerColor.withOpacity(0.5)),
      );
    }

    print('📋 [SecoesListWidget] BUILD #$_buildCount FINALIZADO');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return SliverList(
      delegate: SliverChildListDelegate(sliverChildren),
    );
  }
}

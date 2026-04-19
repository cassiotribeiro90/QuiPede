// lib/app/widgets/sectioned_list_widget.dart
import 'package:flutter/material.dart';

/// Modelo genérico para um item da lista
class SectionItem<T> {
  final T data;
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final String? price;
  final bool? isHighlighted;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Map<String, dynamic>? metadata; // Para dados extras

  SectionItem({
    required this.data,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.price,
    this.isHighlighted,
    this.onTap,
    this.trailing,
    this.metadata,
  });
}

/// Modelo para uma seção da lista
class SectionModel<T> {
  final String title;
  final List<SectionItem<T>> items;
  final String? icon; // Emoji ou ícone
  final bool showCount;

  SectionModel({
    required this.title,
    required this.items,
    this.icon,
    this.showCount = true,
  });
}

/// Widget genérico de lista br seções
class SectionedListWidget<T> extends StatelessWidget {
  final List<SectionModel<T>> sections;
  final VoidCallback? onRefresh;
  final Widget? emptyState;
  final bool showDivider;
  final EdgeInsets padding;

  const SectionedListWidget({
    super.key,
    required this.sections,
    this.onRefresh,
    this.emptyState,
    this.showDivider = true,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {

    // Se não há seções ou todas estão vazias
    if (sections.isEmpty || sections.every((s) => s.items.isEmpty)) {
      return emptyState ?? _buildEmptyState(context);
    }

    Widget listView = ListView.builder(
      padding: padding,
      itemCount: _getTotalItems(),
      itemBuilder: (context, index) => _buildItem(context, index),
    );

    // Adiciona RefreshIndicator se necessário
    if (onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        child: listView,
      );
    }

    return listView;
  }

  int _getTotalItems() {
    int total = 0;
    for (final section in sections) {
      // +1 para o título da seção (se houver items)
      if (section.items.isNotEmpty) {
        total += 1; // título
        total += section.items.length; // items
      }
    }
    return total;
  }

  Widget _buildItem(BuildContext context, int index) {
    // Encontra qual seção e item baseado no índice
    int currentIndex = 0;
    for (final section in sections) {
      if (section.items.isEmpty) continue;

      // Título da seção
      if (currentIndex == index) {
        return _buildSectionHeader(context, section);
      }
      currentIndex++;

      // Items da seção
      for (int i = 0; i < section.items.length; i++) {
        if (currentIndex == index) {
          final item = section.items[i];
          final isLastInSection = i == section.items.length - 1;
          return _buildSectionItem(context, item, isLastInSection);
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(BuildContext context, SectionModel section) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          if (section.icon != null) ...[
            Text(
              section.icon!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              section.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (section.showCount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${section.items.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionItem(
      BuildContext context, SectionItem item, bool isLastInSection) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagem (se houver)
                if (item.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported,
                            size: 24, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Conteúdo principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: item.isHighlighted == true
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.price != null)
                            Text(
                              item.price!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEA1D2C), // Vermelho iFood
                              ),
                            ),
                        ],
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing customizado
                if (item.trailing != null) item.trailing!,
              ],
            ),
          ),
        ),
        // Divider (menos no último item da seção)
        if (showDivider && !isLastInSection)
          const Divider(
            height: 1,
            indent: 84, // Começa depois da imagem (56 + 12 + 16)
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum item encontrado',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

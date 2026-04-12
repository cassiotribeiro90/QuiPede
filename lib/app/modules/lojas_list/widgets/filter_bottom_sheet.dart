import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../models/lojas_list_filter_option_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<LojasListFilterOptionModel> categorias;
  final String? selectedCategoria;
  final String? selectedOrdenacao;
  final String? initialSearch;
  final Function(String? search, String? categoria, String? ordenacao) onApply;
  final VoidCallback onClear;

  const FilterBottomSheet({
    super.key,
    required this.categorias,
    this.selectedCategoria,
    this.selectedOrdenacao,
    this.initialSearch,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _tempCategoria;
  late String? _tempOrdenacao;
  late TextEditingController _searchController;

  final List<Map<String, String>> _ordenacoes = [
    {'value': 'nota', 'label': 'Melhor avaliados', 'icon': '⭐'},
    {'value': 'tempo_entrega', 'label': 'Menor tempo', 'icon': '⏱️'},
    {'value': 'taxa_entrega', 'label': 'Menor taxa', 'icon': '💰'},
    {'value': 'pedido_minimo', 'label': 'Menor pedido mínimo', 'icon': '📉'},
  ];

  @override
  void initState() {
    super.initState();
    _tempCategoria = widget.selectedCategoria;
    _tempOrdenacao = widget.selectedOrdenacao;
    _searchController = TextEditingController(text: widget.initialSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          // Cabeçalho fixo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrar lojas',
                  style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Barra de pesquisa (fixa)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: _buildSearchField(),
          ),
          // Conteúdo rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildOrderSection(),
                  const SizedBox(height: 24),
                  _buildCategoriesSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Rodapé fixo com botões
          _buildFixedFooter(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.textHint.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Pesquisar lojas...',
        prefixIcon: Icon(Icons.search, color: context.textHint),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
              )
            : null,
        filled: true,
        fillColor: context.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5),
        ),
      ),
      onChanged: (val) => setState(() {}),
    );
  }

  Widget _buildOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ordenar por', style: context.titleSmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _ordenacoes.map((option) {
            final isSelected = _tempOrdenacao == option['value'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(option['icon']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(option['label']!),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempOrdenacao = selected ? option['value'] : null;
                });
              },
              selectedColor: context.primarySurface,
              backgroundColor: context.surfaceColor,
              labelStyle: context.bodyMedium.copyWith(
                color: isSelected ? context.primaryColor : context.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: isSelected ? context.primaryColor : context.borderColor,
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    if (widget.categorias.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categorias', style: context.titleSmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.categorias.map((cat) {
            final isSelected = _tempCategoria == cat.value;
            return ChoiceChip(
              label: Text('${cat.label} (${cat.count})'.trim()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempCategoria = selected ? cat.value : null;
                });
              },
              selectedColor: context.primarySurface,
              backgroundColor: context.surfaceColor,
              labelStyle: context.bodyMedium.copyWith(
                color: isSelected ? context.primaryColor : context.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: isSelected ? context.primaryColor : context.borderColor,
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFixedFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _tempCategoria = null;
                  _tempOrdenacao = null;
                  _searchController.clear();
                });
                widget.onClear();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: context.borderColor),
              ),
              child: Text('Limpar', style: TextStyle(color: context.textPrimary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
                  _tempCategoria,
                  _tempOrdenacao,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Aplicar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

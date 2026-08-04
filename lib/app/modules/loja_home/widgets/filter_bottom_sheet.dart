import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_decoration.dart';
import '../../../models/categoria_filter_model.dart';
import '../../../core/theme/input_styles.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<CategoriaFilterModel> categorias;
  final int? selectedCategoriaId;
  final String? selectedOrderBy;
  final String? initialSearch;
  final Function(String? search, int? categoriaId, String? orderBy) onApply;
  final VoidCallback onClear;

  const FilterBottomSheet({
    super.key,
    required this.categorias,
    this.selectedCategoriaId,
    this.selectedOrderBy,
    this.initialSearch,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late int? _tempCategoriaId;
  late String? _tempOrderBy;
  late TextEditingController _searchController;

  final List<Map<String, dynamic>> _orderOptions = [
    {'value': 'relevancia', 'label': 'Relevância', 'icon': '⭐'},
    {'value': 'avaliacao', 'label': 'Melhor avaliados', 'icon': '⭐'},
    {'value': 'destaque', 'label': 'Destaques', 'icon': '🔥'},
    {'value': 'preco_asc', 'label': 'Menor preço', 'icon': '💰'},
    {'value': 'preco_desc', 'label': 'Maior preço', 'icon': '💸'},
  ];

  @override
  void initState() {
    super.initState();
    _tempCategoriaId = widget.selectedCategoriaId;
    _tempOrderBy = widget.selectedOrderBy;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrar produtos',
                  style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold) ??
                      AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: _buildSearchField(),
          ),
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
      decoration: InputStyles.decoration(
        label: 'Pesquisar produtos',
        hint: 'Ex: Pizza, Hambúrguer...',
        prefixIcon: Icons.search,
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
      ),
      onChanged: (val) => setState(() {}),
    );
  }

  Widget _buildOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenar por',
          style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold) ??
              AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _orderOptions.map((option) {
            final isSelected = _tempOrderBy == option['value'];
            final chipTheme = AppDecoration.chipStyle(
              selected: isSelected,
              context: context,
            );
            
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option['icon'],
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    option['label'],
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempOrderBy = selected ? option['value'] : null;
                });
              },
              selectedColor: chipTheme.selectedColor,
              backgroundColor: chipTheme.backgroundColor,
              labelStyle: chipTheme.labelStyle,
              shape: chipTheme.shape,
              showCheckmark: false,
              padding: AppDecoration.chipPadding, // 🔥 PADDING CENTRALIZADO
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
        Text(
          'Categorias',
          style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold) ??
              AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.categorias.map((cat) {
            final isSelected = _tempCategoriaId == cat.id;
            final chipTheme = AppDecoration.chipStyle(
              selected: isSelected,
              context: context,
            );
            
            return ChoiceChip(
              label: Text(
                '${cat.icone ?? ''} ${cat.nome}'.trim(),
                style: AppTextStyles.bodyLarge,
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempCategoriaId = selected ? cat.id : null;
                });
              },
              selectedColor: chipTheme.selectedColor,
              backgroundColor: chipTheme.backgroundColor,
              labelStyle: chipTheme.labelStyle,
              shape: chipTheme.shape,
              showCheckmark: false,
              padding: AppDecoration.chipPadding, // 🔥 PADDING CENTRALIZADO
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
                  _tempCategoriaId = null;
                  _tempOrderBy = null;
                  _searchController.clear();
                });
                widget.onClear();
                Navigator.pop(context);
              },
              style: AppDecoration.clearButton,
              child: Text(
                'Limpar',
                style: AppTextStyles.button.copyWith(
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
                  _tempCategoriaId,
                  _tempOrderBy,
                );
                Navigator.pop(context);
              },
              style: AppDecoration.filterButton,
              child: Text(
                'Aplicar',
                style: AppTextStyles.button.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../models/categoria_filter_model.dart';

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
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  _buildCategoriesSection(),
                  const SizedBox(height: 24),
                  _buildOrderSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                ],
              ),
            ),
          ),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Filtrar produtos',
          style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Pesquisar produtos...',
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
          children: _orderOptions.map((option) {
            final isSelected = _tempOrderBy == option['value'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(option['icon'], style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(option['label']),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempOrderBy = selected ? option['value'] : null;
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
            final isSelected = _tempCategoriaId == cat.id;
            return ChoiceChip(
              label: Text('${cat.icone ?? ''} ${cat.nome}'.trim()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempCategoriaId = selected ? cat.id : null;
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
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: context.borderColor),
            ),
            child: Text('Limpar tudo', style: TextStyle(color: context.textPrimary)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Aplicar filtros',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

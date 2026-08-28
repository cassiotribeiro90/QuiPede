// lib/app/modules/lojas_list/widgets/search_with_filters_lojas.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/lojas_list_filter_option_model.dart';
import 'filter_bottom_sheet.dart';

class SearchWithFiltersLojas extends StatefulWidget {
  final List<LojasListFilterOptionModel> categorias;
  final String? selectedCategoria;
  final String? selectedOrdenacao;
  final String? searchQuery;
  final bool isSearching;
  final Function(String? search, String? categoria, String? ordenacao) onApply;
  final VoidCallback onClearFilters;
  final VoidCallback onClearSearch; // 🔥 Novo: limpar somente a busca

  const SearchWithFiltersLojas({
    super.key,
    required this.categorias,
    this.selectedCategoria,
    this.selectedOrdenacao,
    this.searchQuery,
    this.isSearching = false,
    required this.onApply,
    required this.onClearFilters,
    required this.onClearSearch,
  });

  @override
  State<SearchWithFiltersLojas> createState() => _SearchWithFiltersLojasState();
}

class _SearchWithFiltersLojasState extends State<SearchWithFiltersLojas> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  String? _lastSearchedValue;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
    _lastSearchedValue = widget.searchQuery;
    debugPrint('🔍 [SearchWithFiltersLojas] initState: searchQuery=${widget.searchQuery}');
  }

  @override
  void didUpdateWidget(SearchWithFiltersLojas oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🔍 [SearchWithFiltersLojas] didUpdateWidget: old=${oldWidget.searchQuery}, new=${widget.searchQuery}');
    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchController.text = widget.searchQuery ?? '';
      _lastSearchedValue = widget.searchQuery;
      debugPrint('🔍 [SearchWithFiltersLojas] Atualizando texto para: "${widget.searchQuery}"');
      setState(() {});
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    final has = widget.selectedCategoria != null ||
        widget.selectedOrdenacao != null ||
        (widget.searchQuery != null && widget.searchQuery!.isNotEmpty);
    debugPrint('🔍 [SearchWithFiltersLojas] _hasActiveFilters: $has (searchQuery=${widget.searchQuery})');
    return has;
  }

  String _getFilterSummary() {
    final List<String> parts = [];

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      parts.add('"${widget.searchQuery!}"');
    }

    if (widget.selectedCategoria != null) {
      try {
        final cat = widget.categorias.firstWhere(
              (c) => c.value == widget.selectedCategoria,
        );
        parts.add(cat.label);
      } catch (_) {}
    }

    if (widget.selectedOrdenacao != null) {
      parts.add(_getOrdenacaoLabel(widget.selectedOrdenacao!));
    }

    final summary = parts.isEmpty ? '' : parts.join(' • ');
    debugPrint('🔍 [SearchWithFiltersLojas] _getFilterSummary: "$summary"');
    return summary;
  }

  String _getOrdenacaoLabel(String value) {
    switch (value) {
      case 'nota': return 'Melhor avaliados';
      case 'tempo_entrega': return 'Menor tempo';
      case 'taxa_entrega': return 'Menor taxa';
      case 'pedido_minimo': return 'Menor pedido mínimo';
      default: return value;
    }
  }

  void _performSearch(String value) {
    final trimmedValue = value.trim();
    final searchValue = trimmedValue.isEmpty ? null : trimmedValue;
    if (searchValue == _lastSearchedValue) return;
    _lastSearchedValue = searchValue;
    debugPrint('🔍 [SearchWithFiltersLojas] _performSearch: "$searchValue"');
    widget.onApply(searchValue, widget.selectedCategoria, widget.selectedOrdenacao);
  }

  void _handleSearchChanged(String value) {
    _debounceTimer?.cancel();
    final trimmedValue = value.trim();
    final searchValue = trimmedValue.isEmpty ? null : trimmedValue;

    if (searchValue == null) {
      _performSearch(value);
      return;
    }
    if (searchValue == _lastSearchedValue) return;

    _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
      _performSearch(value);
    });
  }

  void _handleSearchSubmit(String value) {
    _debounceTimer?.cancel();
    _performSearch(value);
    _focusNode.unfocus();
  }

  // 🔥 Limpa TUDO (busca + filtros) - usado pelo botão "Limpar" do resumo
  void _clearSearch() {
    debugPrint('🔍 [SearchWithFiltersLojas] _clearSearch chamado!');
    _debounceTimer?.cancel();
    _searchController.clear();
    _lastSearchedValue = null;
    debugPrint('🔍 [SearchWithFiltersLojas] _clearSearch: chamando onClearFilters');
    widget.onClearFilters();
    setState(() {});
    debugPrint('🔍 [SearchWithFiltersLojas] _clearSearch: setState chamado');
  }

  // 🔥 Limpa somente a busca textual - usado pelo X no campo de texto
  void _clearSearchOnly() {
    debugPrint('🔍 [SearchWithFiltersLojas] _clearSearchOnly chamado!');
    _debounceTimer?.cancel();
    _searchController.clear();
    _lastSearchedValue = null;
    debugPrint('🔍 [SearchWithFiltersLojas] _clearSearchOnly: chamando onClearSearch');
    widget.onClearSearch();
    setState(() {});
    debugPrint('🔍 [SearchWithFiltersLojas] _clearSearchOnly: setState chamado');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _hasActiveFilters;
    final filterSummary = _getFilterSummary();
    final isSearching = widget.isSearching;

    debugPrint('🔍 [SearchWithFiltersLojas] build: hasActiveFilters=$hasActiveFilters, summary="$filterSummary", isSearching=$isSearching');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    enabled: !isSearching,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar lojas...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: hasActiveFilters ? theme.primaryColor : theme.hintColor,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty && !isSearching)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: _clearSearchOnly, // 🔥 Agora limpa só a busca
                              splashRadius: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Icon(
                                Icons.filter_list,
                                size: 20,
                                color: hasActiveFilters
                                    ? theme.primaryColor
                                    : theme.hintColor,
                              ),
                              onPressed: isSearching ? null : () => _showFilterBottomSheet(context),
                              splashRadius: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: hasActiveFilters ? theme.primaryColor : theme.dividerColor,
                          width: hasActiveFilters ? 2 : 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: hasActiveFilters ? theme.primaryColor : theme.dividerColor,
                          width: hasActiveFilters ? 2 : 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: _handleSearchChanged,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _handleSearchSubmit,
                  ),
                ),
              ),
            ],
          ),

          if (hasActiveFilters) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 14,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      filterSummary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: isSearching ? null : _clearSearch, // 🔥 "Limpar" limpa tudo
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Limpar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isSearching ? theme.hintColor : theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    FilterBottomSheet.show(
      context: context,
      categorias: widget.categorias,
      selectedCategoria: widget.selectedCategoria,
      selectedOrdenacao: widget.selectedOrdenacao,
      onApply: (categoria, ordenacao) {
        widget.onApply(
          _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
          categoria,
          ordenacao,
        );
      },
      onClear: () {
        _clearSearch();
        widget.onClearFilters();
      },
    );
  }
}
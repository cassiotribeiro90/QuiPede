// lib/app/modules/loja_home/widgets/search_with_filters.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'filter_bottom_sheet.dart';

class SearchWithFilters extends StatefulWidget {
  final String? searchQuery;
  final String? selectedOrderBy;
  final bool isSearching;
  final Function(String? search) onSearch;
  final Function(String? orderBy) onOrderBy;
  final VoidCallback onClearFilters;
  final VoidCallback onClearSearch; // 🔥 Novo: limpar somente a busca

  const SearchWithFilters({
    super.key,
    this.searchQuery,
    this.selectedOrderBy,
    this.isSearching = false,
    required this.onSearch,
    required this.onOrderBy,
    required this.onClearFilters,
    required this.onClearSearch,
  });

  @override
  State<SearchWithFilters> createState() => _SearchWithFiltersState();
}

class _SearchWithFiltersState extends State<SearchWithFilters> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  String? _lastSearchedValue;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
    _lastSearchedValue = widget.searchQuery;
    debugPrint('🔍 [SearchWithFilters] initState: searchQuery=${widget.searchQuery}');
  }

  @override
  void didUpdateWidget(SearchWithFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🔍 [SearchWithFilters] didUpdateWidget: old=${oldWidget.searchQuery}, new=${widget.searchQuery}');
    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchController.text = widget.searchQuery ?? '';
      _lastSearchedValue = widget.searchQuery;
      debugPrint('🔍 [SearchWithFilters] Atualizando texto para: "${widget.searchQuery}"');
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
    final has = (widget.selectedOrderBy != null && widget.selectedOrderBy != 'relevancia') ||
        (widget.searchQuery != null && widget.searchQuery!.isNotEmpty);
    debugPrint('🔍 [SearchWithFilters] _hasActiveFilters: $has (searchQuery=${widget.searchQuery})');
    return has;
  }

  String _getFilterSummary() {
    final List<String> parts = [];

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      parts.add('"${widget.searchQuery!}"');
    }

    if (widget.selectedOrderBy != null && widget.selectedOrderBy != 'relevancia') {
      parts.add(_getOrderByLabel(widget.selectedOrderBy!));
    }

    final summary = parts.isEmpty ? '' : parts.join(' • ');
    debugPrint('🔍 [SearchWithFilters] _getFilterSummary: "$summary"');
    return summary;
  }

  String _getOrderByLabel(String orderBy) {
    switch (orderBy) {
      case 'relevancia': return 'Relevância';
      case 'avaliacao': return 'Melhor avaliados';
      case 'destaque': return 'Destaques';
      case 'preco_asc': return 'Menor preço';
      case 'preco_desc': return 'Maior preço';
      default: return orderBy;
    }
  }

  void _performSearch(String value) {
    final trimmedValue = value.trim();
    final searchValue = trimmedValue.isEmpty ? null : trimmedValue;
    if (searchValue == _lastSearchedValue) return;
    _lastSearchedValue = searchValue;
    debugPrint('🔍 [SearchWithFilters] _performSearch: "$searchValue"');
    widget.onSearch(searchValue);
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
    debugPrint('🔍 [SearchWithFilters] _clearSearch chamado!');
    _debounceTimer?.cancel();
    _searchController.clear();
    _lastSearchedValue = null;
    debugPrint('🔍 [SearchWithFilters] _clearSearch: chamando onClearFilters');
    widget.onClearFilters();
    setState(() {});
    debugPrint('🔍 [SearchWithFilters] _clearSearch: setState chamado');
  }

  // 🔥 Limpa somente a busca textual - usado pelo X no campo de texto
  void _clearSearchOnly() {
    debugPrint('🔍 [SearchWithFilters] _clearSearchOnly chamado!');
    _debounceTimer?.cancel();
    _searchController.clear();
    _lastSearchedValue = null;
    debugPrint('🔍 [SearchWithFilters] _clearSearchOnly: chamando onClearSearch');
    widget.onClearSearch();
    setState(() {});
    debugPrint('🔍 [SearchWithFilters] _clearSearchOnly: setState chamado');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _hasActiveFilters;
    final filterSummary = _getFilterSummary();
    final isSearching = widget.isSearching;

    debugPrint('🔍 [SearchWithFilters] build: hasActiveFilters=$hasActiveFilters, summary="$filterSummary", isSearching=$isSearching');

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
                      hintText: 'Pesquisar produtos...',
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
                              onPressed: isSearching ? null : () => _showOrderBottomSheet(context),
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

  void _showOrderBottomSheet(BuildContext context) {
    FilterBottomSheet.show(
      context: context,
      selectedOrderBy: widget.selectedOrderBy,
      onApply: (orderBy) {
        widget.onOrderBy(orderBy);
      },
      onClear: () {
        _clearSearch();
        widget.onClearFilters();
      },
    );
  }
}
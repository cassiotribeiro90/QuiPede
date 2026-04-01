import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qui/app/core/utils/text_utils.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';

class FilterSearchBottomSheet extends StatefulWidget {
  final Function(String? search, String? categoria, String? ordenacao) onApplyFilters;

  const FilterSearchBottomSheet({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<FilterSearchBottomSheet> createState() => _FilterSearchBottomSheetState();
}

class _FilterSearchBottomSheetState extends State<FilterSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoria;
  String? _selectedOrdenacao;

  final List<Map<String, String>> _ordenacoes = [
    {'value': 'nota', 'label': 'Melhor avaliados'},
    {'value': 'tempo_entrega', 'label': 'Mais rápidos'},
    {'value': 'distancia', 'label': 'Mais próximos'},
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<LojasCubit>().state;
    if (state is LojasLoaded) {
      _selectedCategoria = state.categoriaSelecionada;
      _selectedOrdenacao = state.ordenacaoAtual;
      _searchController.text = state.searchQuery ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  _buildOrdenacaoSection(),
                  const SizedBox(height: 24),
                  _buildCategoriasSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
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
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Text(
          'Filtrar lojas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Pesquisar lojas ou categorias',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (val) => setState(() {}),
    );
  }

  Widget _buildOrdenacaoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ordenar por',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _ordenacoes.map((ordenacao) {
            final isSelected = _selectedOrdenacao == ordenacao['value'];
            return ChoiceChip(
              label: Text(ordenacao['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedOrdenacao = selected ? ordenacao['value'] : null;
                });
              },
              selectedColor: Colors.orange.withOpacity(0.2),
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.orange[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoriasSection() {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        if (state is! LojasLoaded || state.categorias.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.categorias.map((categoria) {
                final isSelected = _selectedCategoria == categoria.value;
                return ChoiceChip(
                  label: Text('${TextUtils.getDisplayCategory(categoria.label)} (${categoria.count})'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoria = selected ? categoria.value : null;
                    });
                  },
                  selectedColor: Colors.orange.withOpacity(0.2),
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.orange[700] : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearAllFilters,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Limpar tudo'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Aplicar filtros',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    final search = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();
    widget.onApplyFilters(
      search,
      _selectedCategoria,
      _selectedOrdenacao,
    );
    Navigator.pop(context);
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoria = null;
      _selectedOrdenacao = null;
    });
    widget.onApplyFilters(null, null, null);
    Navigator.pop(context);
  }
}

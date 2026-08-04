import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/input_styles.dart';

class LojaSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController? controller;

  const LojaSearchBar({super.key, required this.onSearch, this.controller});

  @override
  State<LojaSearchBar> createState() => _LojaSearchBarState();
}

class _LojaSearchBarState extends State<LojaSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // To show/hide clear icon
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _controller,
        decoration: InputStyles.decoration(
          label: 'Pesquisar lojas...',
          prefixIcon: Icons.search,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
        ).copyWith(
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: _onChanged,
      ),
    );
  }
}

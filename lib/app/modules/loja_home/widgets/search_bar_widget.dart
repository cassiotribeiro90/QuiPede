import 'package:flutter/material.dart';
import '../../../../app/core/theme/app_theme_extension.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearch;
  final VoidCallback onFilterTap;
  final String? activeFilters;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
    this.activeFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context;
    final textStyles = context;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: colors.searchDecoration,
                  child: TextField(
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar produtos...',
                      hintStyle: textStyles.bodyMedium.copyWith(color: colors.textHint),
                      prefixIcon: Icon(Icons.search, color: colors.primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onFilterTap,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: colors.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.borderColor),
                  ),
                  child: Icon(Icons.tune, color: colors.primaryColor),
                ),
              ),
            ],
          ),
          if (activeFilters != null) ...[
            const SizedBox(height: 8),
            Text(
              activeFilters!,
              style: textStyles.caption.copyWith(color: colors.primaryColor, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}

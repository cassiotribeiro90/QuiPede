import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme_extension.dart';
import '../modules/home/bloc/address_cubit.dart';
import '../modules/home/bloc/address_state.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onAddressTap;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  
  const HomeAppBar({
    super.key,
    required this.onMenuTap,
    required this.onAddressTap,
    required this.onSearchTap,
    required this.onProfileTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final colors = context;
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return AppBar(
      elevation: 0,
      backgroundColor: colors.backgroundColor,
      leading: IconButton(
        icon: Icon(Icons.menu, color: colors.textPrimary),
        onPressed: onMenuTap,
        tooltip: 'Menu',
      ),
      title: _buildAddressTitle(context),
      actions: const [/*
        if (isMobile) ...[
          IconButton(
            icon: Icon(Icons.search_outlined, color: colors.textSecondary),
            onPressed: onSearchTap,
            tooltip: 'Filtrar e pesquisar',
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: colors.textSecondary),
            onPressed: onProfileTap,
            tooltip: 'Perfil',
          ),
        ] else ...[
          TextButton.icon(
            onPressed: onSearchTap,
            icon: Icon(Icons.search, color: colors.textSecondary),
            label: Text('Filtrar', style: TextStyle(color: colors.textSecondary)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onProfileTap,
            icon: Icon(Icons.person_outline, color: colors.textSecondary),
            label: Text('Perfil', style: TextStyle(color: colors.textSecondary)),
          ),
          const SizedBox(width: 8),
        ],*/
      ],
    );
  }
  
  Widget _buildAddressTitle(BuildContext context) {
    final colors = context;
    
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        String addressText = "Selecionar endereço";
        if (state is AddressLoaded && state.address != null) {
          addressText = state.address!.formattedShort;
        }

        return GestureDetector(
          onTap: onAddressTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 18, color: colors.primaryColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  addressText,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: colors.textHint),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

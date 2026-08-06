import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme_extension.dart';

class EnderecoBar extends StatelessWidget {
  const EnderecoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizacaoCubit, LocalizacaoState>(
      builder: (context, state) {
        String label = 'Definir endereço de entrega';
        IconData icon = Icons.location_off_outlined;
        Color color = Colors.grey;

        if (state is LocalizacaoCarregada) {
          label = state.enderecoFormatado;
          icon = Icons.location_on_rounded;
          color = context.primaryColor;
        }

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, Routes.onboarding);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.backgroundColor,
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: context.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: context.textHint),
              ],
            ),
          ),
        );
      },
    );
  }
}

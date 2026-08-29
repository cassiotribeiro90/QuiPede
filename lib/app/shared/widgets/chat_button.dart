import 'package:flutter/material.dart';
import 'package:quipede/app/core/theme/app_colors.dart';
import 'package:quipede/app/modules/chat/views/chat_screen.dart';

class ChatButton extends StatelessWidget {
  final int? lojaId;
  final int? pedidoId;
  final String? mensagemInicial;
  final bool showLabel;
  final Color? color;
  final double size;

  const ChatButton({
    super.key,
    this.lojaId,
    this.pedidoId,
    this.mensagemInicial,
    this.showLabel = true,
    this.color,
    this.size = 32, // 🔥 AUMENTADO
  }) : assert(lojaId != null || pedidoId != null,
  'lojaId ou pedidoId deve ser informado');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _abrirChat(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.transparent, // 🔥 FUNDO TRANSPARENTE
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.chatPastel, // 🔥 BORDA LARANJA
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.chat_outlined,
          color: AppColors.chatPrimary, // 🔥 ÍCONE LARANJA
          size: size * 0.55, // 🔥 ÍCONE PROPORCIONAL
        ),
      ),
    );
  }

  void _abrirChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          lojaId: lojaId,
          pedidoId: pedidoId,
          mensagemInicial: mensagemInicial,
        ),
      ),
    );
  }
}
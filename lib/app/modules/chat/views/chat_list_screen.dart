import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/core/theme/app_colors.dart';
import 'package:quipede/app/models/chat_model.dart';
import 'package:quipede/app/modules/chat/bloc/chat_bloc.dart';
import 'package:quipede/app/modules/chat/views/chat_screen.dart';
import 'package:quipede/app/shared/widgets/loading_widget.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc()..add(CarregarChats()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversas'),
          centerTitle: true,
          backgroundColor: AppColors.chatPrimary,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ChatLoading) {
              return const LoadingWidget();
            }

            if (state is ChatLoaded) {
              if (state.chats.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma conversa ainda',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Quando você iniciar uma conversa, ela aparecerá aqui',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: state.chats.length,
                itemBuilder: (context, index) {
                  final chat = state.chats[index];
                  return _buildChatItem(context, chat);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel chat) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.chatPastel.withValues(alpha: 0.3),
        child: Text(
          chat.nomeParticipante[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.chatPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        chat.nomeParticipante,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chat.ultimaMensagem ?? 'Inicie uma conversa',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: chat.temMensagemNaoLida ? Colors.black : Colors.grey,
              fontWeight: chat.temMensagemNaoLida ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (chat.pedidoId != null)
            Text(
              'Pedido #${chat.pedidoId}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            )
          else
            const Text(
              'Conversa geral',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.dataUltimaMensagemFormatada,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (chat.temMensagemNaoLida) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  '${chat.naoLidas}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              lojaId: chat.lojaId,
              pedidoId: chat.pedidoId,
            ),
          ),
        );
      },
    );
  }
}

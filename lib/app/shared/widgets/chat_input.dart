import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quipede/app/core/theme/app_colors.dart';

class ChatInput extends StatefulWidget {
  final VoidCallback onSend;
  final void Function(String) onTextChanged;
  final bool isLoading;
  final String? hintText;
  final TextEditingController? controller;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.onTextChanged,
    this.isLoading = false,
    this.hintText = 'Digite sua mensagem...',
    this.controller,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Campo de texto
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1000),
              ],
              onChanged: widget.onTextChanged,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          // Botão de enviar
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: widget.isLoading
                  ? Colors.grey.shade400
                  : AppColors.chatPrimary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: widget.isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
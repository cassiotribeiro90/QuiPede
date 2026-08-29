import 'package:flutter/material.dart';
import 'package:quipede/app/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ChatMessageSkeleton extends StatelessWidget {
  final bool isMe;
  final double width;

  const ChatMessageSkeleton({
    super.key,
    this.isMe = false,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.chatPrimary.withValues(alpha: 0.15),
      highlightColor: AppColors.chatPrimary.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                width: width,
                height: 54,
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.chatPrimary.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : Radius.circular(4),
                    bottomRight: isMe ? Radius.circular(4) : const Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Linha principal (texto)
                    Container(
                      width: width * 0.75,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isMe
                            ? AppColors.chatPrimary.withValues(alpha: 0.3)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Linha secundária (texto menor)
                    Container(
                      width: width * 0.45,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isMe
                            ? AppColors.chatPrimary.withValues(alpha: 0.2)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
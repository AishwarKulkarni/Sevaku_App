import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workzy/core/theme/brand_colors.dart';
import 'package:workzy/core/theme/text_styles.dart';
import 'package:workzy/core/utils/image_helper.dart';
import 'package:workzy/providers/data_providers.dart';
import 'package:workzy/core/widgets/app_empty_state.dart';
import 'package:workzy/core/widgets/app_error_state.dart';
import 'package:workzy/features/auth/providers/auth_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final myUid = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      appBar: AppBar(
        backgroundColor: BrandColors.shadeBlack,
        title: const Text('Messages'),
      ),
      body: chatsAsync.when(
        data: (chats) {
          return chats.isEmpty
              ? const AppEmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No messages yet',
                  subtitle: 'Book a service to start chatting',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: BrandColors.divider,
                    height: 1,
                    indent: 80,
                  ),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: BrandColors.surfaceLight,
                            backgroundImage: resolveImageProvider(chat.otherPhoto(myUid)),
                            child: resolveImageProvider(chat.otherPhoto(myUid)) == null
                                ? const Icon(Icons.person, size: 26, color: BrandColors.textMuted)
                                : null,
                          ),
                          if (chat.unreadCount > 0)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: BrandColors.primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: BrandColors.shadeBlack,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${chat.unreadCount}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: BrandColors.shadeBlack,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        chat.otherName(myUid),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: chat.unreadCount > 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          chat.lastMessage ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: chat.unreadCount > 0
                                ? BrandColors.textSecondary
                                : BrandColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(chat.displayTime),
                            style: AppTextStyles.caption.copyWith(
                              color: chat.unreadCount > 0
                                  ? BrandColors.primaryGreen
                                  : BrandColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        context.push('/chat/${chat.id}');
                      },
                    )
                        .animate(delay: Duration(milliseconds: 80 * index))
                        .fadeIn()
                        .slideX(begin: 0.05);
                  },
                );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: BrandColors.primaryGreen)),
        error: (err, _) => AppErrorState(
          message: 'Error loading messages',
          onRetry: () => ref.invalidate(userChatsProvider),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

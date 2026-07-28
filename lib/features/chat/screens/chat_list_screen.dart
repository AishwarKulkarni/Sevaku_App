import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevaku/core/utils/image_helper.dart';
import 'package:sevaku/providers/data_providers.dart';
import 'package:sevaku/core/widgets/app_empty_state.dart';
import 'package:sevaku/core/widgets/app_error_state.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final myUid = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: context.colors.shadeBlack,
      appBar: AppBar(
        backgroundColor: context.colors.shadeBlack,
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
                  separatorBuilder: (_, __) => Divider(
                    color: context.colors.divider,
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
                                backgroundColor: context.colors.surfaceLight,
                                backgroundImage: resolveImageProvider(
                                  chat.otherPhoto(myUid),
                                ),
                                child:
                                    resolveImageProvider(
                                          chat.otherPhoto(myUid),
                                        ) ==
                                        null
                                    ? Icon(
                                        Icons.person,
                                        size: 26,
                                        color: context.colors.textMuted,
                                      )
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
                                      color: context.colors.primaryGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: context.colors.shadeBlack,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${chat.unreadCount}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: context.colors.shadeBlack,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            chat.otherName(myUid),
                            style: context.typography.labelLarge.copyWith(
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              chat.lastMessage ?? '',
                              style: context.typography.bodySmall.copyWith(
                                color: chat.unreadCount > 0
                                    ? context.colors.textSecondary
                                    : context.colors.textMuted,
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
                                style: context.typography.caption.copyWith(
                                  color: chat.unreadCount > 0
                                      ? context.colors.primaryGreen
                                      : context.colors.textMuted,
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
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.primaryGreen),
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workzy/core/theme/brand_colors.dart';
import 'package:workzy/core/theme/text_styles.dart';
import 'package:workzy/core/utils/image_helper.dart';
import 'package:workzy/providers/data_providers.dart';
import 'package:workzy/features/auth/providers/auth_provider.dart';
import 'package:workzy/models/chat_model.dart';
import 'package:uuid/uuid.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatRoomScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      final msg = MessageModel(
        id: const Uuid().v4(),
        senderId: currentUser.uid,
        text: _messageController.text.trim(),
        timestamp: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).sendMessage(widget.chatId, msg);

      ref.invalidate(chatMessagesProvider(widget.chatId));
      ref.invalidate(userChatsProvider);

      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } finally {
      // Done sending
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final chatsAsync = ref.watch(userChatsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final myUid = currentUser?.uid ?? '';

    ChatModel? chat;
    if (chatsAsync is AsyncData<List<ChatModel>>) {
      try {
        chat = chatsAsync.value.firstWhere((c) => c.id == widget.chatId);
      } catch (_) {
        chat = null;
      }
    }

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      appBar: AppBar(
        backgroundColor: BrandColors.shadeBlack,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Row(
          children: [
            if (chat != null)
              CircleAvatar(
                radius: 18,
                backgroundColor: BrandColors.surfaceLight,
                backgroundImage: resolveImageProvider(chat.otherPhoto(myUid)),
                child: resolveImageProvider(chat.otherPhoto(myUid)) == null
                    ? const Icon(
                        Icons.person,
                        size: 18,
                        color: BrandColors.textMuted,
                      )
                    : null,
              ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat?.otherName(myUid) ?? 'Chat',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                ),
                Text(
                  'Online',
                  style: AppTextStyles.caption.copyWith(
                    color: BrandColors.primaryGreen,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone_outlined, size: 22),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: BrandColors.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.uid;
                    final showTime =
                        index == messages.length - 1 ||
                        messages[index].timestamp
                                .difference(messages[index + 1].timestamp)
                                .inMinutes >
                            10;

                    return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showTime)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  _formatTime(msg.timestamp),
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            _MessageBubble(
                              message: msg.text,
                              isMe: isMe,
                              time:
                                  '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                            ),
                          ],
                        )
                        .animate(delay: Duration(milliseconds: 20 * index))
                        .fadeIn()
                        .slideY(begin: 0.1);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: BrandColors.primaryGreen,
                ),
              ),
              error: (err, _) => const Center(
                child: Text(
                  'Error loading messages',
                  style: TextStyle(color: BrandColors.error),
                ),
              ),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            decoration: const BoxDecoration(
              color: BrandColors.shadeBlack,
              border: Border(
                top: BorderSide(color: BrandColors.divider, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: BrandColors.textMuted,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      color: BrandColors.white,
                      fontSize: 14,
                    ),
                    cursorColor: BrandColors.primaryGreen,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Lexend',
                        color: BrandColors.textHint,
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: BrandColors.divider,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: BrandColors.primaryGreen,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: BrandColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: BrandColors.shadeBlack,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? BrandColors.primaryGreen : BrandColors.lightGray,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                color: isMe ? BrandColors.shadeBlack : BrandColors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 9,
                color: isMe
                    ? BrandColors.shadeBlack.withValues(alpha: 0.5)
                    : BrandColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

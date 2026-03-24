import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../services/presence_service.dart';
import '../../services/typing_service.dart';
import '../../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> otherUser;

  const ChatScreen({
    super.key,
    required this.user,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService service = ChatService();
  final TextEditingController ctrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  final presence = PresenceService();
  final typingService = TypingService();

  String get myId => widget.user['id'];
  String get otherId => widget.otherUser['id'];

  Message? replyingTo;
  bool _markedSeen = false;

  @override
  void initState() {
    super.initState();
    presence.setOnline();
  }

  @override
  void dispose() {
    presence.setOffline();
    ctrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  // ================= SEND =================
  Future<void> sendMessage() async {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    await typingService.setTyping(otherId, false);

    try {
      if (replyingTo != null) {
        await service.sendReply(
          text: text,
          receiverId: otherId,
          replyMsg: replyingTo!,
        );
        replyingTo = null;
      } else {
        await service.send(text, otherId);
      }

      ctrl.clear();
      setState(() {});
      _scrollToBottom();
    } catch (e) {
      debugPrint("SEND ERROR: $e");
    }
  }

  // ================= SCROLL =================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted || !scrollCtrl.hasClients) return;

      scrollCtrl.animateTo(
        scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ================= LAST SEEN =================
  String _formatLastSeen(String? value) {
    if (value == null) return "";

    try {
      final dt = DateTime.parse(value);
      final diff = DateTime.now().difference(dt);

      if (diff.inSeconds < 60) return "last seen just now";
      if (diff.inMinutes < 60) return "last seen ${diff.inMinutes} min ago";
      if (diff.inHours < 24) return "last seen ${diff.inHours} hr ago";

      return "last seen ${dt.day}/${dt.month} ${dt.hour}:${dt.minute}";
    } catch (_) {
      return "";
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUser['email'] ?? ''),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: presence.stream(),
              builder: (_, snap) {
                final data = snap.data ?? [];

                final user = data.firstWhere(
                  (u) => u['user_id'] == otherId,
                  orElse: () => {},
                );

                if (user.isEmpty) return const SizedBox();

                final online = user['is_online'] == true;

                return Text(
                  online ? "Online" : _formatLastSeen(user['last_seen']),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: service.getMessages(otherId),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snap.data!;

                if (!_markedSeen) {
                  _markedSeen = true;
                  service.markSeen(otherId);
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == myId;

                    return GestureDetector(
                      onHorizontalDragEnd: (_) {
                        setState(() => replyingTo = msg);
                      },
                      onLongPress: () => _showReaction(msg),
                      child: _bubble(msg, isMe),
                    );
                  },
                );
              },
            ),
          ),

          // ================= TYPING DOTS =================
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: typingService.stream(),
            builder: (_, snap) {
              final data = snap.data ?? [];

              final typing = data.any((t) =>
                  t['sender_id'] == otherId &&
                  t['receiver_id'] == myId &&
                  t['is_typing'] == true);

              if (!typing) return const SizedBox();

              return const Padding(
                padding: EdgeInsets.all(8),
                child: TypingDots(),
              );
            },
          ),

          // ================= REPLY PREVIEW =================
          if (replyingTo != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade300,
              child: Row(
                children: [
                  Expanded(child: Text("Reply: ${replyingTo!.content}")),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => replyingTo = null),
                  ),
                ],
              ),
            ),

          _inputBar(),
        ],
      ),
    );
  }

  // ================= REACTION =================
  void _showReaction(Message msg) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["❤️", "🔥", "😂"].map((e) {
            return IconButton(
              onPressed: () {
                service.setReaction(msg.id, e);
                Navigator.pop(context);
              },
              icon: Text(e, style: const TextStyle(fontSize: 24)),
            );
          }).toList(),
        );
      },
    );
  }

  // ================= BUBBLE =================
  Widget _bubble(Message msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 14)),

          if (!isMe) const SizedBox(width: 6),

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.green : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 REPLY PREVIEW
                  if (msg.replyText != null)
                    Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(bottom: 6),
                      color: Colors.black12,
                      child: Text(msg.replyText!),
                    ),

                  Text(
                    msg.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),

                  // 🔥 REACTION
                  if (msg.reaction != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(msg.reaction!,
                          style: const TextStyle(fontSize: 16)),
                    ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatTime(msg.createdAt),
                          style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 5),
                      if (isMe)
                        Text(msg.isSeen ? "✔✔" : "✔",
                            style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  // ================= INPUT =================
  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: (text) {
                typingService.setTyping(otherId, text.isNotEmpty);
              },
              onSubmitted: (_) => sendMessage(),
              decoration: const InputDecoration(
                hintText: "Type message...",
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}

// ================= TYPING DOTS =================
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> {
  int dots = 1;

  @override
  void initState() {
    super.initState();
    _animate();
  }

  void _animate() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => dots = dots % 3 + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text("Typing${"." * dots}");
  }
}
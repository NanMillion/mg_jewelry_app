import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/presence_service.dart';

class ChatListScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatListScreen({super.key, required this.user});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final supabase = Supabase.instance.client;
  final presence = PresenceService();

  List<Map<String, dynamic>> users = [];

  String get myId => widget.user['id'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // ================= LOAD USERS =================
  Future<void> _loadUsers() async {
    final res = await supabase
        .from('profiles')
        .select()
        .neq('id', myId);

    if (!mounted) return;

    setState(() {
      users = List<Map<String, dynamic>>.from(res);
    });
  }

  // ================= MESSAGE STREAM =================
  Stream<List<Map<String, dynamic>>> _messageStream() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),

      body: users.isEmpty
          ? const Center(child: Text("No users found"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messageStream(),
              builder: (_, msgSnap) {
                final messages = msgSnap.data ?? [];

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: presence.stream(),
                  builder: (_, presSnap) {
                    final onlineData = presSnap.data ?? [];

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, i) {
                        final u = users[i];
                        final otherId = u['id'];

                        // ================= LAST MESSAGE =================
                        final lastMsg = messages.firstWhere(
                          (m) =>
                              (m['sender_id'] == myId &&
                                  m['receiver_id'] == otherId) ||
                              (m['sender_id'] == otherId &&
                                  m['receiver_id'] == myId),
                          orElse: () => {},
                        );

                        final lastText =
                            lastMsg.isEmpty ? "No messages" : lastMsg['content'];

                        // ================= UNREAD COUNT =================
                        final unread = messages.where((m) =>
                                m['receiver_id'] == myId &&
                                m['sender_id'] == otherId &&
                                m['is_seen'] == false)
                            .length;

                        // ================= ONLINE =================
                        final online = onlineData.any((p) =>
                            p['user_id'] == otherId &&
                            p['is_online'] == true);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),

                          // ================= AVATAR =================
                          leading: Stack(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                child: Icon(Icons.person),
                              ),

                              if (online)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // ================= NAME =================
                          title: Text(
                            u['email'] ?? "User",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),

                          // ================= LAST MESSAGE =================
                          subtitle: Text(
                            lastText ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // ================= TRAILING =================
                          trailing: unread > 0
                              ? CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    unread.toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_ios, size: 16),

                          // ================= NAV =================
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/chat',
                              arguments: {
                                'user': widget.user,
                                'otherUser': u,
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  final SupabaseClient client = Supabase.instance.client;

  // ================= CURRENT USER =================
  String? get currentUserId => client.auth.currentUser?.id;

  // ================= STREAM PRIVATE CHAT =================
  Stream<List<Message>> getMessages(String otherUserId) {
    final myId = currentUserId;

    if (myId == null) {
      debugPrint("❌ User not logged in");
      return const Stream.empty();
    }

    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
      try {
        final list = List<Map<String, dynamic>>.from(data);

        final filtered = list.where((msg) {
          final sender = msg['sender_id'];
          final receiver = msg['receiver_id'];

          return (sender == myId && receiver == otherUserId) ||
              (sender == otherUserId && receiver == myId);
        });

        return filtered.map(Message.fromJson).toList();
      } catch (e) {
        debugPrint("Parse Error: $e");
        return <Message>[];
      }
    });
  }

  // ================= SEND MESSAGE =================
  Future<void> send(String text, String receiverId) async {
    final user = client.auth.currentUser;

    if (user == null) {
      debugPrint("❌ User not logged in");
      return;
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    try {
      await client.from('messages').insert({
        'content': trimmed,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'is_seen': false,
      });
    } catch (e) {
      debugPrint("Send Error: $e");
    }
  }

  // ================= SEND REPLY =================
  Future<void> sendReply({
    required String text,
    required String receiverId,
    required Message replyMsg,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    try {
      await client.from('messages').insert({
        'content': trimmed,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'is_seen': false,
        'reply_to': replyMsg.id,
        'reply_text': replyMsg.content,
      });
    } catch (e) {
      debugPrint("Reply Error: $e");
    }
  }

  // ================= SET REACTION =================
  Future<void> setReaction(String id, String reaction) async {
    try {
      await client
          .from('messages')
          .update({'reaction': reaction})
          .eq('id', id);
    } catch (e) {
      debugPrint("Reaction Error: $e");
    }
  }

  // ================= MARK AS SEEN =================
  Future<void> markSeen(String otherUserId) async {
    final myId = currentUserId;
    if (myId == null) return;

    try {
      await client
          .from('messages')
          .update({'is_seen': true})
          .eq('receiver_id', myId)
          .eq('sender_id', otherUserId)
          .eq('is_seen', false);
    } catch (e) {
      debugPrint("Seen Error: $e");
    }
  }

  // ================= DELETE MESSAGE =================
  Future<void> deleteMessage(String id) async {
    try {
      await client.from('messages').delete().eq('id', id);
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  // ================= REALTIME =================
  RealtimeChannel? _channel;

  void startRealtime(Function(Message) onNewMessage) {
    _channel = client.channel('public:messages');

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final msg = Message.fromJson(payload.newRecord);
              onNewMessage(msg);
            } catch (e) {
              debugPrint("Realtime Parse Error: $e");
            }
          },
        )
        .subscribe();
  }

  void stopRealtime() {
    if (_channel != null) {
      client.removeChannel(_channel!);
      _channel = null;
    }
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';

class TypingService {
  final supabase = Supabase.instance.client;

  String? get myId => supabase.auth.currentUser?.id;

  Future<void> setTyping(String receiverId, bool typing) async {
    if (myId == null) return;

    await supabase.from('typing_status').upsert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'is_typing': typing,
    });
  }

  Stream<List<Map<String, dynamic>>> stream() {
    return supabase
        .from('typing_status')
        .stream(primaryKey: ['sender_id', 'receiver_id']);
  }
}
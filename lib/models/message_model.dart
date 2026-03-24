class Message {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final bool isSeen;
  final DateTime createdAt;

  // 🔥 NEW FEATURES
  final String? reaction;     // ❤️🔥😂
  final String? replyTo;      // message id
  final String? replyText;    // preview text

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.isSeen,
    required this.createdAt,
    this.reaction,
    this.replyTo,
    this.replyText,
  });

  // ================= FROM JSON =================
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: (json['id'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      senderId: (json['sender_id'] ?? '').toString(),
      receiverId: (json['receiver_id'] ?? '').toString(),
      isSeen: json['is_seen'] ?? false,
      createdAt: _parseDate(json['created_at']),

      // 🔥 NEW
      reaction: json['reaction']?.toString(),
      replyTo: json['reply_to']?.toString(),
      replyText: json['reply_text']?.toString(),
    );
  }

  // ================= TO JSON (INSERT) =================
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'is_seen': isSeen,

      // 🔥 OPTIONAL FIELDS
      'reaction': reaction,
      'reply_to': replyTo,
      'reply_text': replyText,
    };
  }

  // ================= COPY =================
  Message copyWith({
    String? id,
    String? content,
    String? senderId,
    String? receiverId,
    bool? isSeen,
    DateTime? createdAt,
    String? reaction,
    String? replyTo,
    String? replyText,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      isSeen: isSeen ?? this.isSeen,
      createdAt: createdAt ?? this.createdAt,
      reaction: reaction ?? this.reaction,
      replyTo: replyTo ?? this.replyTo,
      replyText: replyText ?? this.replyText,
    );
  }

  // ================= HELPERS =================
  bool get isMine => senderId.isNotEmpty;

  bool get hasReaction => reaction != null && reaction!.isNotEmpty;

  bool get hasReply => replyTo != null && replyTo!.isNotEmpty;

  // ================= SAFE DATE =================
  static DateTime _parseDate(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
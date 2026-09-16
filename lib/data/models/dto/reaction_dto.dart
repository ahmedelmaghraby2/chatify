class ReactionDto {
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  const ReactionDto({
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory ReactionDto.fromMap(Map<String, dynamic> map) {
    return ReactionDto(
      messageId: map['message_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'user_id': userId,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

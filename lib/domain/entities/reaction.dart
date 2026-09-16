import 'package:equatable/equatable.dart';

class Reaction extends Equatable {
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  const Reaction({
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [messageId, userId, emoji];
}

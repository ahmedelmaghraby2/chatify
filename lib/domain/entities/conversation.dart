import 'package:equatable/equatable.dart';
import 'message.dart';
import 'user.dart';

enum ConversationKind { direct, group }

enum MemberRole { member, admin, owner }

class ConversationMember extends Equatable {
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final DateTime? mutedUntil;
  final DateTime? archivedAt;
  final String? lastReadMessageId;
  final User? user;

  const ConversationMember({
    required this.userId,
    this.role = MemberRole.member,
    required this.joinedAt,
    this.leftAt,
    this.mutedUntil,
    this.archivedAt,
    this.lastReadMessageId,
    this.user,
  });

  bool get isLeft => leftAt != null;
  bool get isMuted =>
      mutedUntil != null && mutedUntil!.isAfter(DateTime.now());
  bool get isArchived => archivedAt != null;
  bool get isAdmin => role == MemberRole.admin || role == MemberRole.owner;
  bool get isOwner => role == MemberRole.owner;

  @override
  List<Object?> get props => [
        userId,
        role,
        joinedAt,
        leftAt,
        mutedUntil,
        archivedAt,
        lastReadMessageId,
      ];
}

class Conversation extends Equatable {
  final String id;
  final ConversationKind kind;
  final String? title;
  final String description;
  final String? avatarUrl;
  final String createdBy;
  final DateTime? lastMessageAt;
  final DateTime? pinnedAt;
  final DateTime? mutedUntil;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final Message? lastMessage;
  final int unreadCount;
  final List<ConversationMember> members;
  final User? otherUser;

  const Conversation({
    required this.id,
    required this.kind,
    this.title,
    this.description = '',
    this.avatarUrl,
    required this.createdBy,
    this.lastMessageAt,
    this.pinnedAt,
    this.mutedUntil,
    this.archivedAt,
    required this.createdAt,
    this.deletedAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.members = const [],
    this.otherUser,
  });

  bool get isGroup => kind == ConversationKind.group;
  bool get isDirect => kind == ConversationKind.direct;
  bool get isPinned => pinnedAt != null;
  bool get isMuted =>
      mutedUntil != null && mutedUntil!.isAfter(DateTime.now());
  bool get isArchived => archivedAt != null;
  bool get isDeleted => deletedAt != null;

  String get displayName {
    if (title != null && title!.isNotEmpty) return title!;
    if (otherUser != null) return otherUser!.displayName;
    return 'Unknown';
  }

  Conversation copyWith({
    String? id,
    ConversationKind? kind,
    String? Function()? title,
    String? description,
    String? Function()? avatarUrl,
    String? createdBy,
    DateTime? Function()? lastMessageAt,
    DateTime? Function()? pinnedAt,
    DateTime? Function()? mutedUntil,
    DateTime? Function()? archivedAt,
    DateTime? createdAt,
    DateTime? Function()? deletedAt,
    Message? Function()? lastMessage,
    int? unreadCount,
    List<ConversationMember>? members,
    User? Function()? otherUser,
  }) => Conversation(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title != null ? title() : this.title,
    description: description ?? this.description,
    avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
    createdBy: createdBy ?? this.createdBy,
    lastMessageAt:
        lastMessageAt != null ? lastMessageAt() : this.lastMessageAt,
    pinnedAt: pinnedAt != null ? pinnedAt() : this.pinnedAt,
    mutedUntil: mutedUntil != null ? mutedUntil() : this.mutedUntil,
    archivedAt: archivedAt != null ? archivedAt() : this.archivedAt,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    lastMessage: lastMessage != null ? lastMessage() : this.lastMessage,
    unreadCount: unreadCount ?? this.unreadCount,
    members: members ?? this.members,
    otherUser: otherUser != null ? otherUser() : this.otherUser,
  );

  @override
  List<Object?> get props => [
        id,
        kind,
        title,
        lastMessageAt,
        pinnedAt,
        unreadCount,
        deletedAt,
      ];
}

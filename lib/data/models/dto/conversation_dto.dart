import '../dto/user_dto.dart';

class ConversationMemberDto {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final DateTime? mutedUntil;
  final DateTime? archivedAt;
  final String? lastReadMessageId;

  const ConversationMemberDto({
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
    this.leftAt,
    this.mutedUntil,
    this.archivedAt,
    this.lastReadMessageId,
  });

  factory ConversationMemberDto.fromMap(Map<String, dynamic> map) {
    return ConversationMemberDto(
      userId: map['user_id'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      joinedAt: map['joined_at'] != null
          ? DateTime.parse(map['joined_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
      leftAt: map['left_at'] != null
          ? DateTime.parse(map['left_at'] as String)
          : null,
      mutedUntil: map['muted_until'] != null
          ? DateTime.parse(map['muted_until'] as String)
          : null,
      archivedAt: map['archived_at'] != null
          ? DateTime.parse(map['archived_at'] as String)
          : null,
      lastReadMessageId: map['last_read_message_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
      'muted_until': mutedUntil?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
      'last_read_message_id': lastReadMessageId,
    };
  }
}

class ConversationDto {
  final String id;
  final String kind;
  final String? title;
  final String? description;
  final String? avatarPath;
  final String createdBy;
  final DateTime? lastMessageAt;
  final DateTime? pinnedAt;
  final DateTime? mutedUntil;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final List<ConversationMemberDto> members;
  final String? lastMessageBody;
  final DateTime? lastMessageCreatedAt;
  final int unreadCount;
  final UserDto? otherUser;

  const ConversationDto({
    required this.id,
    required this.kind,
    this.title,
    this.description,
    this.avatarPath,
    required this.createdBy,
    this.lastMessageAt,
    this.pinnedAt,
    this.mutedUntil,
    this.archivedAt,
    required this.createdAt,
    this.deletedAt,
    this.members = const [],
    this.lastMessageBody,
    this.lastMessageCreatedAt,
    this.unreadCount = 0,
    this.otherUser,
  });

  factory ConversationDto.fromMap(Map<String, dynamic> map) {
    return ConversationDto(
      id: map['id'] as String? ?? '',
      kind: map['kind'] as String? ?? 'direct',
      title: map['title'] as String?,
      description: map['description'] as String?,
      avatarPath: map['avatar_path'] as String?,
      createdBy: map['created_by'] as String? ?? '',
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'] as String)
          : null,
      pinnedAt: map['pinned_at'] != null
          ? DateTime.parse(map['pinned_at'] as String)
          : null,
      mutedUntil: map['muted_until'] != null
          ? DateTime.parse(map['muted_until'] as String)
          : null,
      archivedAt: map['archived_at'] != null
          ? DateTime.parse(map['archived_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      members: (map['members'] as List<dynamic>?)
              ?.map((e) => ConversationMemberDto.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastMessageBody: map['last_message_body'] as String?,
      lastMessageCreatedAt: map['last_message_created_at'] != null
          ? DateTime.parse(map['last_message_created_at'] as String)
          : null,
      unreadCount: (map['unread_count'] as num?)?.toInt() ?? 0,
      otherUser: map['other_user'] != null
          ? UserDto.fromMap(map['other_user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kind': kind,
      'title': title,
      'description': description,
      'avatar_path': avatarPath,
      'created_by': createdBy,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'pinned_at': pinnedAt?.toIso8601String(),
      'muted_until': mutedUntil?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'members': members.map((e) => e.toMap()).toList(),
      'last_message_body': lastMessageBody,
      'last_message_created_at': lastMessageCreatedAt?.toIso8601String(),
      'unread_count': unreadCount,
      'other_user': otherUser?.toMap(),
    };
  }
}

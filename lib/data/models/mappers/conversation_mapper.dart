import 'package:chatify/domain/entities/conversation.dart';

import '../dto/conversation_dto.dart';
import 'user_mapper.dart';

extension ConversationMemberDtoMapper on ConversationMemberDto {
  ConversationMember toEntity() {
    return ConversationMember(
      userId: userId,
      role: _parseRole(role),
      joinedAt: joinedAt,
      leftAt: leftAt,
      mutedUntil: mutedUntil,
      archivedAt: archivedAt,
      lastReadMessageId: lastReadMessageId,
    );
  }

  MemberRole _parseRole(String role) {
    switch (role) {
      case 'owner':
        return MemberRole.owner;
      case 'admin':
        return MemberRole.admin;
      default:
        return MemberRole.member;
    }
  }
}

extension ConversationDtoMapper on ConversationDto {
  Conversation toEntity() {
    return Conversation(
      id: id,
      kind: _parseKind(kind),
      title: title,
      description: description ?? '',
      avatarUrl: avatarPath,
      createdBy: createdBy,
      lastMessageAt: lastMessageAt,
      pinnedAt: pinnedAt,
      mutedUntil: mutedUntil,
      archivedAt: archivedAt,
      createdAt: createdAt,
      deletedAt: deletedAt,
      unreadCount: unreadCount,
      members: members.map((e) => e.toEntity()).toList(),
      otherUser: otherUser?.toEntity(),
      lastMessage: null,
    );
  }

  ConversationKind _parseKind(String kind) {
    switch (kind) {
      case 'group':
        return ConversationKind.group;
      default:
        return ConversationKind.direct;
    }
  }
}

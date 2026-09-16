import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../l10n/app_localizations.dart';
import '../shared/app_avatar.dart';
import '../shared/time_formatter.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final preview = _preview(conversation, loc);
    final isGroup = conversation.isGroup;

    String avatarName;
    String? avatarUrl;
    if (isGroup) {
      avatarName = conversation.displayName;
      avatarUrl = conversation.avatarUrl;
    } else {
      final other = conversation.otherUser;
      avatarName = other?.displayName ?? conversation.displayName;
      avatarUrl = other?.avatarUrl ?? conversation.avatarUrl;
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: AppSpacing.listTilePadding,
        child: Row(
          children: [
            if (isGroup)
              AppAvatar(
                avatarUrl: avatarUrl,
                displayName: avatarName,
                radius: 24,
              )
            else
              AppAvatar(
                avatarUrl: avatarUrl,
                displayName: avatarName,
                radius: 24,
                showOnline: conversation.otherUser?.isOnline ?? false,
                isOnline: conversation.otherUser?.isOnline ?? false,
              ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium,
                        ),
                      ),
                      if (conversation.isPinned) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                      if (conversation.isMuted) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.volume_off,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.chatSubtitle.copyWith(
                            color: conversation.unreadCount > 0
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _timeLabel(context, conversation),
                        style: AppTypography.messageTimestamp.copyWith(
                          color: conversation.unreadCount > 0
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (conversation.unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: AppRadius.fullAll,
                ),
                child: Text(
                  conversation.unreadCount > 99
                      ? '99+'
                      : '${conversation.unreadCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _preview(Conversation conversation, AppLocalizations loc) {
    final last = conversation.lastMessage;
    if (last == null) {
      return conversation.isGroup
          ? loc.membersCount(conversation.members.length)
          : loc.noMessagesYet;
    }
    if (last.isDeleted) return loc.messageDeleted;
    final prefix =
        conversation.isGroup ? '${last.senderName ?? ''}: ' : '';
    switch (last.kind) {
      case MessageKind.image:
        return '$prefix${loc.imageAttachmentLabel}';
      case MessageKind.video:
        return '$prefix${loc.videoAttachmentLabel}';
      case MessageKind.voice:
        return '$prefix${loc.voiceMessageLabel}';
      case MessageKind.document:
        return '$prefix${loc.documentAttachmentLabel}';
      default:
        return '$prefix${last.body ?? ''}';
    }
  }

  String _timeLabel(BuildContext context, Conversation conversation) {
    final time = conversation.lastMessageAt ?? conversation.createdAt;
    return TimeFormatter.relative(
      time,
      DateTime.now(),
      AppLocalizations.of(context)!,
    );
  }
}
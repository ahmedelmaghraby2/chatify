import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/reaction.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../l10n/app_localizations.dart';
import '../shared/time_formatter.dart';

const _kReactionChoices = [
  '👍',
  '❤️',
  '😂',
  '😮',
  '😢',
  '🙏',
  '🔥',
  '🎉',
];

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isFirst,
    required this.isLast,
    this.highlight = false,
    this.onToggleReaction,
    this.onReply,
    this.onEdit,
    this.onDeleteForMe,
    this.onDeleteForEveryone,
  });

  final Message message;
  final bool isMe;
  final bool isFirst;
  final bool isLast;
  final bool highlight;
  final void Function(String emoji)? onToggleReaction;
  final VoidCallback? onReply;
  final void Function(String newText)? onEdit;
  final VoidCallback? onDeleteForMe;
  final VoidCallback? onDeleteForEveryone;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _highlightController;
  bool _showReactions = false;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.highlight) {
      _highlightController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlight && !oldWidget.highlight) {
      _highlightController.forward(from: 0);
    } else if (!widget.highlight && oldWidget.highlight) {
      _highlightController.reset();
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    if (message.isSystem) return _systemMessage(context);
    if (message.isDeleted) return _deletedMessage(context);

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = widget.isMe
        ? (isDark ? AppColors.sentBubbleDark : AppColors.sentBubbleLight)
        : (isDark ? AppColors.receivedBubbleDark : AppColors.receivedBubbleLight);
    final textColor = widget.isMe
        ? (isDark ? AppColors.sentTextDark : AppColors.sentTextLight)
        : (isDark ? AppColors.receivedTextDark : AppColors.receivedTextLight);

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _highlightController,
            builder: (context, child) {
              final t = _highlightController.value;
              final glow = t > 0 && t < 1
                  ? scheme.primary.withValues(
                      alpha: (1 - t.abs()) * 0.3,
                    )
                  : Colors.transparent;
              return Container(
                margin: EdgeInsets.only(
                  top: widget.isLast ? AppSpacing.xs : 2,
                  bottom: widget.isFirst ? AppSpacing.xs : 2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  boxShadow: [
                    if (glow != Colors.transparent)
                      BoxShadow(color: glow, blurRadius: 12),
                  ],
                  borderRadius: widget.isMe
                      ? AppRadius.sentBubble(widget.isFirst, widget.isLast)
                      : AppRadius.receivedBubble(
                          widget.isFirst,
                          widget.isLast,
                        ),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                child: child,
              );
            },
            child: _bubbleContent(context, textColor, scheme),
          ),
          if (message.reactions.isNotEmpty && !_showReactions)
            _reactionsRow(context),
        ],
      ),
    );
  }

  Widget _bubbleContent(
    BuildContext context,
    Color textColor,
    ColorScheme scheme,
  ) {
    final message = widget.message;
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.isReply) _replyPreview(context),
          if (!widget.isMe &&
              (message.senderName != null && message.senderName!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                message.senderName!,
                style: AppTypography.labelMedium.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (message.hasAttachments) ...[
            for (final attachment in message.attachments)
              _attachmentView(context, attachment),
          ],
          if (message.isText &&
              message.body != null &&
              message.body!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                message.body!,
                style: AppTypography.messageBody.copyWith(color: textColor),
              ),
            ),
          if (_showReactions) _reactionPickerRow(context),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isEdited)
                Text(
                  AppLocalizations.of(context)!.messageEdited,
                  style: AppTypography.messageTimestamp.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                TimeFormatter.clock(message.createdAt),
                style: AppTypography.messageTimestamp.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
              if (widget.isMe) ...[
                const SizedBox(width: AppSpacing.xs),
                _statusIcon(context, textColor),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _replyPreview(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.1),
        borderRadius: AppRadius.smallAll,
        border: Border(
          left: BorderSide(color: scheme.primary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.reply,
            style: AppTypography.labelSmall.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            widget.message.replyTo?.body ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _attachmentView(BuildContext context, Attachment attachment) {
    final storage = sl.get<StorageRepository>();
    final scheme = Theme.of(context).colorScheme;

    if (attachment.isImage) {
      return GestureDetector(
        onTap: () => _openMedia(context),
        child: ClipRRect(
          borderRadius: AppRadius.mediumAll,
          child: CachedNetworkImage(
            imageUrl: storage.getPublicUrl(attachment.bucket, attachment.path),
            width: 220,
            fit: BoxFit.cover,
            placeholder: (_, _) => const SizedBox(
              width: 220,
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, _, _) => const SizedBox(
              width: 220,
              height: 150,
              child: Center(child: Icon(Icons.broken_image)),
            ),
          ),
        ),
      );
    }

    if (attachment.isVideo) {
      return GestureDetector(
        onTap: () => _openMedia(context),
        child: Container(
          width: 220,
          height: 150,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: AppRadius.mediumAll,
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surface.withValues(alpha: 0.8),
              ),
              child: const Icon(Icons.play_arrow, size: 32),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppRadius.smallAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              _fileName(attachment.path),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _openMedia(BuildContext context) {
    final storage = sl.get<StorageRepository>();
    final attachments = widget.message.attachments;
    if (attachments.isEmpty) return;
    final attachment = attachments.first;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MediaViewer(url: storage.getPublicUrl(attachment.bucket, attachment.path)),
      ),
    );
  }

  String _fileName(String path) {
    final segments = path.split('/');
    return segments.isNotEmpty ? segments.last : 'file';
  }

  Widget _statusIcon(BuildContext context, Color textColor) {
    final message = widget.message;
    final statusColor = switch (message.status) {
      MessageStatus.pending || MessageStatus.sending => AppColors.unreadReceipt,
      MessageStatus.sent => AppColors.unreadReceipt,
      MessageStatus.delivered => AppColors.deliveredReceipt,
      MessageStatus.seen => AppColors.readReceipt,
      MessageStatus.failed || MessageStatus.retrying => AppColors.errorColor,
    };
    return switch (message.status) {
      MessageStatus.pending => const Icon(
          Icons.schedule,
          size: 14,
          color: AppColors.unreadReceipt,
        ),
      MessageStatus.sending => const Icon(
          Icons.schedule,
          size: 14,
          color: AppColors.unreadReceipt,
        ),
      MessageStatus.failed || MessageStatus.retrying => const Icon(
          Icons.error_outline,
          size: 14,
          color: AppColors.errorColor,
        ),
      _ => Icon(
          Icons.done_all,
          size: 14,
          color: statusColor,
        ),
    };
  }

  Widget _reactionsRow(BuildContext context) {
    final grouped = <String, List<Reaction>>{};
    for (final r in widget.message.reactions) {
      grouped.putIfAbsent(r.emoji, () => []).add(r);
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in grouped.entries)
            GestureDetector(
              onTap: () => widget.onToggleReaction?.call(entry.key),
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: AppRadius.fullAll,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.key),
                    if (entry.value.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text('${entry.value.length}'),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _reactionPickerRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppRadius.fullAll,
      ),
      child: Wrap(
        spacing: 2,
        children: [
          for (final emoji in _kReactionChoices)
            InkWell(
              onTap: () => widget.onToggleReaction?.call(emoji),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final message = widget.message;
    final isOwn = widget.isMe;
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_reaction_outlined),
              title: Text(loc.addReaction),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final emoji in _kReactionChoices.take(5))
                    InkWell(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        widget.onToggleReaction?.call(emoji);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Text(emoji),
                      ),
                    ),
                ],
              ),
              onTap: () => setState(() => _showReactions = true),
            ),
            if (message.isText && message.body != null)
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text(loc.copy),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Clipboard.setData(ClipboardData(text: message.body!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.copied)),
                  );
                },
              ),
            if (widget.onReply != null)
              ListTile(
                leading: const Icon(Icons.reply),
                title: Text(loc.reply),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  widget.onReply!();
                },
              ),
            if (isOwn &&
                message.isText &&
                widget.onEdit != null &&
                !message.isDeleted)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(loc.edit),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _editDialog(context);
                },
              ),
            if (widget.onDeleteForMe != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(loc.deleteForMe),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  widget.onDeleteForMe!();
                },
              ),
            if (isOwn && widget.onDeleteForEveryone != null)
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  loc.deleteForEveryone,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  widget.onDeleteForEveryone!();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editDialog(BuildContext context) async {
    final controller = TextEditingController(text: widget.message.body ?? '');
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.editMessage),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(loc.save),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      widget.onEdit?.call(result.trim());
    }
  }

  Widget _systemMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          widget.message.body ?? '',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _deletedMessage(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Text(
          AppLocalizations.of(context)!.messageDeleted,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _MediaViewer extends StatelessWidget {
  const _MediaViewer({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
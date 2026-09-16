import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/message.dart';
import '../../l10n/app_localizations.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onTypingChanged,
    this.onPickImage,
    this.onPickCameraImage,
    this.onPickDocument,
    this.onRecordVoice,
    this.sendingMedia = false,
  });

  final ValueChanged<String> onSend;
  final ValueChanged<bool> onTypingChanged;
  final VoidCallback? onPickImage;
  final VoidCallback? onPickCameraImage;
  final VoidCallback? onPickDocument;
  final VoidCallback? onRecordVoice;
  final bool sendingMedia;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
        widget.onTypingChanged(hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PopupMenuButton<String>(
              icon: Icon(Icons.add_circle_outline, color: scheme.primary),
              onSelected: (value) {
                switch (value) {
                  case 'image':
                    widget.onPickImage?.call();
                  case 'camera':
                    widget.onPickCameraImage?.call();
                  case 'document':
                    widget.onPickDocument?.call();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'image',
                  child: Text(AppLocalizations.of(context)!.galleryLabel),
                ),
                PopupMenuItem(
                  value: 'camera',
                  child: Text(AppLocalizations.of(context)!.cameraLabel),
                ),
                PopupMenuItem(
                  value: 'document',
                  child: Text(AppLocalizations.of(context)!.documentAttachmentLabel),
                ),
              ],
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: AppRadius.largeAll,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.typeMessage,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  style: AppTypography.bodyMedium,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            if (widget.sendingMedia)
              const SizedBox(
                width: 36,
                height: 36,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_hasText)
              IconButton(
                onPressed: _handleSend,
                icon: Icon(Icons.send, color: scheme.primary),
                tooltip: AppLocalizations.of(context)!.send,
              )
            else
              IconButton(
                onPressed: widget.onRecordVoice,
                icon: Icon(Icons.mic_none, color: scheme.onSurfaceVariant),
                tooltip: AppLocalizations.of(context)!.voiceMessageLabel,
              ),
          ],
        ),
      ),
    );
  }
}

class ReplyBar extends StatelessWidget {
  const ReplyBar({
    super.key,
    required this.message,
    required this.onCancel,
  });

  final Message message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: scheme.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.reply,
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.body ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 18),
            tooltip: AppLocalizations.of(context)!.cancel,
          ),
        ],
      ),
    );
  }
}

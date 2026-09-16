import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/message.dart';
import '../../l10n/app_localizations.dart';
import '../shared/time_formatter.dart';
import 'chat_bloc.dart';
import 'message_bubble.dart';

class MessageList extends StatefulWidget {
  const MessageList({
    super.key,
    required this.messages,
    this.currentUserId,
    this.highlightMessageId,
    this.onLoadOlder,
    this.onReply,
    this.onEdit,
    this.onDeleteForMe,
    this.onDeleteForEveryone,
  });

  final List<Message> messages;
  final String? currentUserId;
  final String? highlightMessageId;
  final VoidCallback? onLoadOlder;
  final ValueChanged<Message>? onReply;
  final void Function(Message message, String newText)? onEdit;
  final ValueChanged<Message>? onDeleteForMe;
  final ValueChanged<Message>? onDeleteForEveryone;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _controller = ScrollController();
  final GlobalKey _highlightKey = GlobalObjectKey('chatify-highlight-scroll');
  bool _atBottom = true;
  int _lastCount = 0;
  String? _lastScrolledHighlightId;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.messages.length;
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      final grew = widget.messages.length > _lastCount;
      _lastCount = widget.messages.length;
      if (grew && (_atBottom || (oldWidget.messages.isEmpty && widget.messages.isNotEmpty))) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.hasClients) {
            _controller.jumpTo(_controller.position.maxScrollExtent);
          }
        });
      }
    }
    final highlightId = widget.highlightMessageId;
    if (highlightId != null &&
        (highlightId != oldWidget.highlightMessageId ||
            !identical(widget.messages, oldWidget.messages))) {
      _scrollToHighlight(highlightId);
    }
  }

  void _scrollToHighlight(String id) {
    if (_lastScrolledHighlightId == id) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final target = _highlightKey.currentContext;
      if (target == null) return;
      _lastScrolledHighlightId = id;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final atBottom = _controller.position.maxScrollExtent -
            _controller.position.pixels <
        40;
    if (atBottom != _atBottom) {
      setState(() => _atBottom = atBottom);
    }
    if (_controller.position.pixels < 200) {
      widget.onLoadOlder?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previous = index > 0 ? messages[index - 1] : null;
        final next = index < messages.length - 1 ? messages[index + 1] : null;

        final showDayDivider =
            previous == null ||
            !_isSameDay(previous.createdAt, message.createdAt);

        final isFirst = next == null || next.senderId != message.senderId;
        final isLast = previous == null || previous.senderId != message.senderId;

        final body = Column(
          children: [
            if (showDayDivider) _DayDivider(time: message.createdAt),
            MessageBubble(
              message: message,
              isMe: message.senderId == widget.currentUserId,
              isFirst: isFirst,
              isLast: isLast,
              highlight: message.id == widget.highlightMessageId,
              onToggleReaction: (emoji) => context.read<ChatBloc>().add(
                    ToggleReaction(messageId: message.id, emoji: emoji),
                  ),
              onReply: widget.onReply == null
                  ? null
                  : () => widget.onReply!(message),
              onEdit: widget.onEdit == null
                  ? null
                  : (text) => widget.onEdit!(message, text),
              onDeleteForMe: widget.onDeleteForMe == null
                  ? null
                  : () => widget.onDeleteForMe!(message),
              onDeleteForEveryone: widget.onDeleteForEveryone == null
                  ? null
                  : () => widget.onDeleteForEveryone!(message),
            ),
          ],
        );
        return message.id == widget.highlightMessageId
            ? KeyedSubtree(key: _highlightKey, child: body)
            : body;
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: AppRadius.fullAll,
          ),
          child: Text(
            TimeFormatter.dayLabel(
              time,
              DateTime.now(),
              AppLocalizations.of(context)!,
            ),
            style: AppTypography.labelSmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../../l10n/app_localizations.dart';
import '../shared/app_avatar.dart';
import '../shared/status_views.dart';
import '../shared/time_formatter.dart';

/// Full-text search inside a single conversation. Pops with the selected
/// [Message] so the caller can jump to it.
class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<Message> _results = [];
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _results = [];
        _loading = false;
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(trimmed));
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final repo = sl.get<MessageRepository>();
      final results = await repo.searchMessages(widget.conversationId, query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _hasSearched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _hasSearched = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _preview(Message message) {
    final loc = AppLocalizations.of(context)!;
    return switch (message.kind) {
      MessageKind.text || MessageKind.system => message.body ?? '',
      MessageKind.image => loc.imageAttachmentLabel,
      MessageKind.video => loc.videoAttachmentLabel,
      MessageKind.document => loc.documentAttachmentLabel,
      MessageKind.voice => loc.voiceMessageLabel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: loc.searchInChat,
            border: InputBorder.none,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          style: AppTypography.bodyLarge,
          onChanged: _onChanged,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: loc.closeDialogLabel,
            onPressed: () {
              _controller.clear();
              _focusNode.unfocus();
              setState(() {
                _results = [];
                _hasSearched = false;
              });
            },
          ),
        ],
      ),
      body: _loading
          ? const AppLoadingView()
          : _results.isEmpty
              ? AppEmptyView(
                  icon: Icons.search,
                  title: loc.searchInChat,
                  subtitle: _hasSearched ? loc.noSearchResults : null,
                )
              : ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final message = _results[index];
                    return ListTile(
                      leading: AppAvatar(
                        avatarUrl: message.senderAvatarUrl,
                        displayName: message.senderName ?? '',
                        radius: 20,
                      ),
                      title: Text(
                        message.senderName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _preview(message),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        TimeFormatter.relative(
                          message.createdAt,
                          DateTime.now(),
                          loc,
                        ),
                        style: AppTypography.labelSmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(message),
                    );
                  },
                ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/app_avatar.dart';
import '../shared/status_views.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  Conversation? _conversation;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = sl.get<ConversationRepository>();
      final conv = await repo.getConversation(widget.conversationId);
      if (mounted) setState(() { _conversation = conv; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final myId = sl.get<AuthRepository>().currentUser?.id;
    final loc = AppLocalizations.of(context)!;

    if (_loading) return const Scaffold(body: AppLoadingView());
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.groupInfo)),
        body: AppErrorView(message: _error!, onRetry: _load),
      );
    }

    final conv = _conversation;
    if (conv == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.groupInfo)),
        body: AppEmptyView(
          icon: Icons.group_off,
          title: loc.groupNotFound,
        ),
      );
    }

    final isAdmin = conv.members
        .where((m) => m.userId == myId && m.isAdmin)
        .isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.groupInfo),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editGroup(context),
              tooltip: loc.editGroup,
            ),
          if (!conv.members.any((m) => m.userId == myId))
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => _leaveGroup(context),
              tooltip: loc.leaveGroup,
            ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: AppAvatar(
              avatarUrl: conv.avatarUrl,
              displayName: conv.displayName,
              radius: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Center(
            child: Text(
              conv.displayName,
              style: AppTypography.headlineSmall,
            ),
          ),
          if (conv.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                conv.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: AppSpacing.horizontalPadding,
            child: Text(
              loc.membersCountPlural(conv.members.length),
              style: AppTypography.titleSmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final member in conv.members)
            ListTile(
              leading: AppAvatar(
                avatarUrl: member.user?.avatarUrl,
                displayName: member.user?.displayName ?? _shortId(member.userId),
                radius: 18,
              ),
              title: Text(member.user?.displayName ?? _shortId(member.userId)),
              subtitle: Text(
                member.isOwner
                    ? loc.owner
                    : member.isAdmin
                        ? loc.admin
                        : loc.member,
              ),
              trailing: member.userId == myId
                  ? null
                  : PopupMenuButton<String>(
                      onSelected: (value) => _memberAction(context, value, conv, member),
                      itemBuilder: (_) => [
                        if (isAdmin && !member.isOwner)
                          PopupMenuItem(
                            value: member.isAdmin ? 'demote' : 'promote',
                            child: Text(
                              member.isAdmin ? loc.removeAdmin : loc.makeAdmin,
                            ),
                          ),
                        if (isAdmin && !member.isOwner)
                          PopupMenuItem(
                            value: 'remove',
                            child: Text(loc.removeMember),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  String _shortId(String id) {
    return id.length <= 8 ? id : id.substring(0, 8);
  }

  void _editGroup(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: AppSpacing.base,
          right: AppSpacing.base,
          top: AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.editGroup, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: loc.groupName),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () async {
                final repo = sl.get<ConversationRepository>();
                await repo.updateGroup(
                  conversationId: widget.conversationId,
                  title: 'Updated',
                );
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
                _load();
              },
              child: Text(loc.save),
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }

  Future<void> _leaveGroup(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.leaveGroup),
        content: Text(loc.leaveGroupConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(loc.cancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(loc.leaveGroup)),
        ],
      ),
    );
    if (confirm == true) {
      await sl.get<ConversationRepository>().leaveGroup(widget.conversationId);
      if (!mounted) return;
      Navigator.of(this.context).popUntil((_) => false);
      this.context.go(AppRoutes.home);
    }
  }

  void _memberAction(
    BuildContext context,
    String action,
    Conversation conv,
    ConversationMember member,
  ) async {
    final repo = sl.get<ConversationRepository>();
    switch (action) {
      case 'promote':
        await repo.promoteToAdmin(conv.id, member.userId);
      case 'demote':
        await repo.demoteFromAdmin(conv.id, member.userId);
      case 'remove':
        await repo.removeMember(conv.id, member.userId);
    }
    _load();
  }
}

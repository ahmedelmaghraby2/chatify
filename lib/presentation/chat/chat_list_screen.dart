import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/status_views.dart';
import '../home/conversations_cubit.dart';
import 'conversation_tile.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConversationsCubit(sl.get<ConversationRepository>()),
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chats),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppRoutes.search),
            tooltip: loc.search,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatSheet(context),
        child: const Icon(Icons.edit),
      ),
      body: BlocBuilder<ConversationsCubit, ConversationListState>(
        builder: (context, state) {
          if (state.loading && state.conversations.isEmpty) {
            return const AppLoadingView();
          }
          if (!state.hasLoaded && state.error != null) {
            return AppErrorView(
              message: state.error!.message,
              onRetry: () => context.read<ConversationsCubit>().refresh(),
            );
          }
          if (state.conversations.isEmpty) {
            return AppEmptyView(
              icon: Icons.chat_bubble_outline,
              title: loc.noChatsYet,
              subtitle: loc.startAConversation,
              actionLabel: loc.newChat,
              onAction: () => context.go(AppRoutes.search),
            );
          }
          final sorted = [...state.conversations]..sort((a, b) {
              if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
              final at = a.lastMessageAt ?? a.createdAt;
              final bt = b.lastMessageAt ?? b.createdAt;
              return bt.compareTo(at);
            });
          return ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = sorted[index];
              return ConversationTile(
                conversation: conversation,
                onTap: () =>
                    context.go(AppRoutes.chatWith(conversation.id)),
                onLongPress: () => _showConversationActions(
                  context,
                  conversation,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showNewChatSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Text(loc.newChat, style: AppTypography.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: Text(loc.newMessage),
              subtitle: Text(loc.startDirectConversation),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.go(AppRoutes.search);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: Text(loc.newGroup),
              subtitle: Text(loc.createGroupChat),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.go(AppRoutes.newGroup);
              },
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }

  void _showConversationActions(
    BuildContext context,
    Conversation conversation,
  ) {
    final loc = AppLocalizations.of(context)!;
    final cubit = context.read<ConversationsCubit>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Text(
                conversation.displayName,
                style: AppTypography.titleMedium,
              ),
            ),
            if (conversation.isPinned)
              ListTile(
                leading: const Icon(Icons.push_pin_outlined),
                title: Text(loc.unpin),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.unpin(conversation.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: Text(loc.pin),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.pin(conversation.id);
                },
              ),
            if (conversation.isMuted)
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(loc.unmute),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.unmute(conversation.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: Text(loc.mute),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.mute(conversation.id, const Duration(hours: 24));
                },
              ),
            if (conversation.isArchived)
              ListTile(
                leading: const Icon(Icons.unarchive_outlined),
                title: Text(loc.unarchive),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.unarchive(conversation.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: Text(loc.archive),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.archive(conversation.id);
                },
              ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                loc.deleteChat,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                cubit.delete(conversation.id);
              },
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
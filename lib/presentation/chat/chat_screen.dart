import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/call_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/app_avatar.dart';
import '../shared/status_views.dart';
import 'chat_bloc.dart';
import 'chat_input_bar.dart';
import 'chat_search_screen.dart';
import 'message_list.dart';
import 'voice_recorder_sheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatBloc _bloc;
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bloc = ChatBloc(
      messageRepository: sl.get<MessageRepository>(),
      conversationRepository: sl.get<ConversationRepository>(),
      storageRepository: sl.get<StorageRepository>(),
      callRepository: sl.get<CallRepository>(),
      authRepository: sl.get<AuthRepository>(),
    )..add(ChatOpened(widget.conversationId));
    _bloc.onOutgoingCall = (call) {
      if (mounted) {
        context.push('${AppRoutes.activeCall}/${call.id}');
      }
    };
  }

  @override
  void dispose() {
    _bloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final error = state.errorMessage;
          if (error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          }
        },
        child: _ChatScreenView(
          scrollController: _scrollController,
          imagePicker: _imagePicker,
        ),
      ),
    );
  }
}

class _ChatScreenView extends StatelessWidget {
  const _ChatScreenView({
    required this.scrollController,
    required this.imagePicker,
  });

  final ScrollController scrollController;
  final ImagePicker imagePicker;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatBloc>().state;
    final conversation = state.conversation;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        titleSpacing: 0,
        title: conversation == null
            ? Text(loc.chats)
            : _Header(conversation: conversation, typingUsers: state.typingUsers),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () =>
                context.read<ChatBloc>().add(StartVoiceCall()),
            tooltip: loc.voiceCallLabel,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () =>
                context.read<ChatBloc>().add(StartVideoCall()),
            tooltip: loc.videoCallLabel,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreActions(context),
            tooltip: loc.moreOptionsLabel,
          ),
        ],
      ),
      body: switch (state.status) {
        ChatStatus.loading => const AppLoadingView(),
        ChatStatus.error => AppErrorView(
            message: state.errorMessage ?? loc.somethingWentWrong,
            onRetry: () {
              final conversationId =
                  context.read<ChatBloc>().state.conversation?.id ?? '';
              if (conversationId.isNotEmpty) {
                context.read<ChatBloc>().add(ChatOpened(conversationId));
              }
            },
          ),
        _ => Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? AppEmptyView(
                        icon: Icons.forum_outlined,
                        title: loc.noMessagesYet,
                        subtitle: loc.sendAMessage,
                      )
                    : MessageList(
                        messages: state.messages,
                        currentUserId: state.currentUser?.id,
                        highlightMessageId: state.highlightMessageId,
                        onLoadOlder: () =>
                            context.read<ChatBloc>().add(LoadOlderMessages()),
                        onReply: (message) => context
                            .read<ChatBloc>()
                            .add(SetReply(message)),
                        onEdit: (message, newText) =>
                            context.read<ChatBloc>().add(
                                  EditMessage(
                                    messageId: message.id,
                                    newBody: newText,
                                  ),
                                ),
                        onDeleteForMe: (message) =>
                            context.read<ChatBloc>().add(
                                  DeleteMessageForMe(message.id),
                                ),
                        onDeleteForEveryone: (message) =>
                            context.read<ChatBloc>().add(
                                  DeleteMessageForEveryone(message.id),
                                ),
                      ),
              ),
              if (state.replyTo != null)
                ReplyBar(
                  message: state.replyTo!,
                  onCancel: () => context.read<ChatBloc>().add(ClearReply()),
                ),
              ChatInputBar(
                sendingMedia: state.sendingMedia,
                onSend: (text) =>
                    context.read<ChatBloc>().add(SendTextMessage(text)),
                onTypingChanged: (typing) =>
                    context.read<ChatBloc>().add(TypingChanged(typing)),
                onPickImage: () => _pickAndSend(context, ImageSource.gallery),
                onPickCameraImage: () => _pickAndSend(context, ImageSource.camera),
                onPickDocument: () => _pickDocument(context),
                onRecordVoice: () => _recordVoice(context),
              ),
            ],
          ),
      },
    );
  }

  Future<void> _pickAndSend(BuildContext context, ImageSource source) async {
    final file = await imagePicker.pickImage(source: source);
    if (file == null) return;
    if (!context.mounted) return;
    context.read<ChatBloc>().add(SendMediaMessage(
          localPath: file.path,
          mimeType: 'image/jpeg',
        ));
  }

  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final path = file.path;
    if (path == null) return;
    if (!context.mounted) return;
    context.read<ChatBloc>().add(SendMediaMessage(
          localPath: path,
          mimeType: file.extension == null
              ? 'application/octet-stream'
              : 'application/${file.extension}',
          fileName: file.name,
        ));
  }

  Future<void> _recordVoice(BuildContext context) async {
    final result = await showVoiceRecorderSheet(context);
    if (result == null || !context.mounted) return;
    context.read<ChatBloc>().add(SendVoiceMessage(
          localPath: result.path,
          duration: result.duration,
        ));
  }

  void _showMoreActions(BuildContext context) {
    final conversation = context.read<ChatBloc>().state.conversation;
    if (conversation == null) return;
    final loc = AppLocalizations.of(context)!;
    final repo = sl.get<ConversationRepository>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (conversation.isGroup)
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(loc.groupInfo),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRoutes.groupInfoWith(conversation.id));
                },
              ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(loc.search),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pushChatSearch(context);
              },
            ),
            if (conversation.isMuted)
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(loc.notifications),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  repo.unmuteConversation(conversation.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: Text(loc.notifications),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  repo.muteConversation(
                      conversation.id, const Duration(days: 1));
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(loc.delete),
              onTap: () {
                Navigator.of(sheetContext).pop();
                repo.clearConversation(conversation.id);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                loc.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                repo.deleteConversation(conversation.id);
                context.go(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pushChatSearch(BuildContext context) async {
    final conversation = context.read<ChatBloc>().state.conversation;
    if (conversation == null) return;
    final result = await Navigator.of(context).push<Message>(
      MaterialPageRoute(
        builder: (_) => ChatSearchScreen(conversationId: conversation.id),
      ),
    );
    if (result == null || !context.mounted) return;
    context.read<ChatBloc>().add(JumpToMessage(result.id));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.conversation, required this.typingUsers});

  final Conversation conversation;
  final List<String> typingUsers;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final subtitle = typingUsers.isNotEmpty
        ? 'typing…'
        : conversation.isGroup
            ? loc.membersCount(conversation.members.length)
            : (conversation.otherUser?.isOnline ?? false)
                ? loc.online
                : '';

    return Row(
      children: [
        AppAvatar(
          avatarUrl: conversation.avatarUrl,
          displayName: conversation.displayName,
          radius: 18,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                conversation.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.chatTitle,
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.chatSubtitle.copyWith(
                  color: typingUsers.isNotEmpty
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                  fontStyle: typingUsers.isNotEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

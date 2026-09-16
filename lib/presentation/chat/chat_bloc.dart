import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/call.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/call_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/storage_repository.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatOpened extends ChatEvent {
  final String conversationId;
  const ChatOpened(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendTextMessage extends ChatEvent {
  final String text;
  const SendTextMessage(this.text);

  @override
  List<Object?> get props => [text];
}

class SendMediaMessage extends ChatEvent {
  final String localPath;
  final String mimeType;
  final String? fileName;
  const SendMediaMessage({
    required this.localPath,
    required this.mimeType,
    this.fileName,
  });

  @override
  List<Object?> get props => [localPath, mimeType, fileName];
}

class SendVoiceMessage extends ChatEvent {
  final String localPath;
  final Duration duration;
  const SendVoiceMessage({required this.localPath, required this.duration});

  @override
  List<Object?> get props => [localPath, duration];
}

class LoadOlderMessages extends ChatEvent {}

class JumpToMessage extends ChatEvent {
  final String messageId;
  const JumpToMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class EditMessage extends ChatEvent {
  final String messageId;
  final String newBody;
  const EditMessage({required this.messageId, required this.newBody});

  @override
  List<Object?> get props => [messageId, newBody];
}

class DeleteMessageForMe extends ChatEvent {
  final String messageId;
  const DeleteMessageForMe(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class DeleteMessageForEveryone extends ChatEvent {
  final String messageId;
  const DeleteMessageForEveryone(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class ToggleReaction extends ChatEvent {
  final String messageId;
  final String emoji;
  const ToggleReaction({required this.messageId, required this.emoji});

  @override
  List<Object?> get props => [messageId, emoji];
}

class MarkSeen extends ChatEvent {
  final String messageId;
  const MarkSeen(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class StartVoiceCall extends ChatEvent {}

class StartVideoCall extends ChatEvent {}

class ClearReply extends ChatEvent {}

class SetReply extends ChatEvent {
  final Message message;
  const SetReply(this.message);

  @override
  List<Object?> get props => [message];
}

class TypingChanged extends ChatEvent {
  final bool isTyping;
  const TypingChanged(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

class MessagesUpdated extends ChatEvent {
  final List<Message> messages;
  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class TypingUsersUpdated extends ChatEvent {
  final List<String> typingUsers;
  const TypingUsersUpdated(this.typingUsers);

  @override
  List<Object?> get props => [typingUsers];
}

class ChatState extends Equatable {
  final ChatStatus status;
  final Conversation? conversation;
  final List<Message> messages;
  final bool loadingOlder;
  final List<String> typingUsers;
  final String? highlightMessageId;
  final String? errorMessage;
  final bool sendingMedia;
  final Message? replyTo;
  final User? currentUser;

  const ChatState({
    this.status = ChatStatus.initial,
    this.conversation,
    this.messages = const [],
    this.loadingOlder = false,
    this.typingUsers = const [],
    this.highlightMessageId,
    this.errorMessage,
    this.sendingMedia = false,
    this.replyTo,
    this.currentUser,
  });

  static const Object _unset = Object();

  ChatState copyWith({
    ChatStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    bool? loadingOlder,
    List<String>? typingUsers,
    Object? highlightMessageId = _unset,
    Object? errorMessage = _unset,
    bool? sendingMedia,
    Object? replyTo = _unset,
    Object? currentUser = _unset,
  }) =>
      ChatState(
        status: status ?? this.status,
        conversation: conversation ?? this.conversation,
        messages: messages ?? this.messages,
        loadingOlder: loadingOlder ?? this.loadingOlder,
        typingUsers: typingUsers ?? this.typingUsers,
        highlightMessageId: identical(highlightMessageId, _unset)
            ? this.highlightMessageId
            : highlightMessageId as String?,
        errorMessage: identical(errorMessage, _unset)
            ? this.errorMessage
            : errorMessage as String?,
        sendingMedia: sendingMedia ?? this.sendingMedia,
        replyTo:
            identical(replyTo, _unset) ? this.replyTo : replyTo as Message?,
        currentUser: identical(currentUser, _unset)
            ? this.currentUser
            : currentUser as User?,
      );

  @override
  List<Object?> get props => [
        status,
        conversation,
        messages,
        loadingOlder,
        typingUsers,
        highlightMessageId,
        errorMessage,
        sendingMedia,
        replyTo,
        currentUser,
      ];
}

enum ChatStatus { initial, loading, loaded, error }

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required MessageRepository messageRepository,
    required ConversationRepository conversationRepository,
    required StorageRepository storageRepository,
    required CallRepository callRepository,
    required AuthRepository authRepository,
  })  : _messageRepository = messageRepository,
        _conversationRepository = conversationRepository,
        _storageRepository = storageRepository,
        _callRepository = callRepository,
        _authRepository = authRepository,
        super(const ChatState()) {
    on<ChatOpened>(_onOpened);
    on<SendTextMessage>(_onSendText);
    on<SendMediaMessage>(_onSendMedia);
    on<SendVoiceMessage>(_onSendVoice);
    on<LoadOlderMessages>(_onLoadOlder);
    on<JumpToMessage>(_onJumpToMessage);
    on<EditMessage>(_onEdit);
    on<DeleteMessageForMe>(_onDeleteMe);
    on<DeleteMessageForEveryone>(_onDeleteEveryone);
    on<ToggleReaction>(_onToggleReaction);
    on<MarkSeen>(_onMarkSeen);
    on<StartVoiceCall>(_onStartVoiceCall);
    on<StartVideoCall>(_onStartVideoCall);
    on<TypingChanged>(_onTypingChanged);
    on<ClearReply>(_onClearReply);
    on<SetReply>(_onSetReply);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<TypingUsersUpdated>(_onTypingUsersUpdated);
  }

  final MessageRepository _messageRepository;
  final ConversationRepository _conversationRepository;
  final StorageRepository _storageRepository;
  final CallRepository _callRepository;
  final AuthRepository _authRepository;

  StreamSubscription<List<Message>>? _messagesSub;
  StreamSubscription<List<String>>? _typingSub;
  Timer? _typingDebounce;
  String _conversationId = '';
  bool _markSentSeenQueued = false;

  void Function(Call call)? onOutgoingCall;

  Future<void> _onOpened(ChatOpened event, Emitter<ChatState> emit) async {
    _conversationId = event.conversationId;
    emit(state.copyWith(status: ChatStatus.loading));
    _messagesSub?.cancel();
    _typingSub?.cancel();

    try {
      final conversation =
          await _conversationRepository.getConversation(event.conversationId);
      final user = _authRepository.currentUser;
      emit(state.copyWith(
        conversation: conversation,
        currentUser: user,
        status: ChatStatus.loaded,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }

    _messagesSub = _messageRepository
        .watchMessages(event.conversationId)
        .listen((messages) {
      if (!isClosed) add(MessagesUpdated(messages));
      _queueMarkSeen();
    });

    _typingSub = _conversationRepository
        .watchTypingUsers(event.conversationId)
        .listen((users) {
      if (!isClosed) add(TypingUsersUpdated(users));
    });
  }

  void _onMessagesUpdated(
    MessagesUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(messages: event.messages));
  }

  void _onTypingUsersUpdated(
    TypingUsersUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(typingUsers: event.typingUsers));
  }

  void _queueMarkSeen() {
    if (_markSentSeenQueued) return;
    _markSentSeenQueued = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      _markSentSeenQueued = false;
      final seen = state.messages
          .where((m) =>
              m.senderId != state.currentUser?.id && m.isPending == false)
          .toList();
      if (seen.isEmpty) return;
      final last = seen.last;
      add(MarkSeen(last.id));
    });
  }

  Future<void> _onSendText(
    SendTextMessage event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;
    try {
      await _messageRepository.sendMessage(
        conversationId: _conversationId,
        body: text,
        kind: MessageKind.text,
        replyToId: state.replyTo?.id,
      );
      emit(state.copyWith(replyTo: null));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onSendMedia(
    SendMediaMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(sendingMedia: true));
    try {
      final bytes = await File(event.localPath).readAsBytes();
      final kind = _kindForMime(event.mimeType);
      final fileName = event.fileName ?? _fileNameFromPath(event.localPath);
      final bucket = kind == MessageKind.document ? 'documents' : 'chat-media';
      final path = await _storageRepository.uploadChatMedia(
        conversationId: _conversationId,
        path: fileName,
        bytes: bytes,
        mimeType: event.mimeType,
      );
      final attachment = Attachment(
        id: IdGenerator.generateClientId(),
        messageId: '',
        bucket: bucket,
        path: path,
        mimeType: event.mimeType,
        sizeBytes: bytes.length,
      );
      await _messageRepository.sendMessage(
        conversationId: _conversationId,
        body: '',
        kind: kind,
        replyToId: state.replyTo?.id,
        attachments: [attachment],
      );
      emit(state.copyWith(sendingMedia: false, replyTo: null));
    } catch (e) {
      emit(state.copyWith(
        sendingMedia: false,
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onSendVoice(
    SendVoiceMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(sendingMedia: true));
    try {
      final bytes = await File(event.localPath).readAsBytes();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      final path = await _storageRepository.uploadVoiceMessage(
        conversationId: _conversationId,
        path: fileName,
        bytes: bytes,
      );
      final attachment = Attachment(
        id: IdGenerator.generateClientId(),
        messageId: '',
        bucket: 'voice-messages',
        path: path,
        mimeType: 'audio/aac',
        sizeBytes: bytes.length,
        durationMs: event.duration.inMilliseconds,
      );
      await _messageRepository.sendMessage(
        conversationId: _conversationId,
        body: '',
        kind: MessageKind.voice,
        replyToId: state.replyTo?.id,
        attachments: [attachment],
      );
      emit(state.copyWith(sendingMedia: false, replyTo: null));
    } catch (e) {
      emit(state.copyWith(
        sendingMedia: false,
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onLoadOlder(
    LoadOlderMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (state.loadingOlder || state.messages.isEmpty) return;
    emit(state.copyWith(loadingOlder: true));
    try {
      final oldest = state.messages.first;
      final older = await _messageRepository.loadOlder(
        _conversationId,
        before: oldest.createdAt,
      );
      final ids = state.messages.map((m) => m.id).toSet();
      final merged = [...older.where((m) => !ids.contains(m.id)), ...state.messages]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(state.copyWith(messages: merged, loadingOlder: false));
    } catch (_) {
      emit(state.copyWith(loadingOlder: false));
    }
  }

  Future<void> _onJumpToMessage(
    JumpToMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(highlightMessageId: event.messageId));
    try {
      final messages = await _messageRepository.loadAround(
        _conversationId,
        event.messageId,
      );
      emit(state.copyWith(messages: messages));
    } catch (_) {}
  }

  Future<void> _onEdit(EditMessage event, Emitter<ChatState> emit) async {
    try {
      await _messageRepository.editMessage(event.messageId, event.newBody);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onDeleteMe(
    DeleteMessageForMe event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _messageRepository.deleteForMe(event.messageId);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onDeleteEveryone(
    DeleteMessageForEveryone event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _messageRepository.deleteForEveryone(event.messageId);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onToggleReaction(
    ToggleReaction event,
    Emitter<ChatState> emit,
  ) async {
    final matches = state.messages
        .where((m) => m.id == event.messageId)
        .toList();
    if (matches.isEmpty) return;
    final message = matches.first;
    final myReaction = message.reactions
        .where((r) =>
            r.userId == state.currentUser?.id && r.emoji == event.emoji)
        .toList()
        .isEmpty
        ? null
        : message.reactions.firstWhere(
            (r) =>
                r.userId == state.currentUser?.id && r.emoji == event.emoji,
          );
    try {
      if (myReaction != null) {
        await _messageRepository.removeReaction(event.messageId, event.emoji);
      } else {
        await _messageRepository.addReaction(event.messageId, event.emoji);
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onMarkSeen(MarkSeen event, Emitter<ChatState> emit) async {
    try {
      await _messageRepository.markAsSeen(_conversationId, event.messageId);
    } catch (_) {}
  }

  Future<void> _onStartVoiceCall(
    StartVoiceCall event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final call = await _callRepository.initiateCall(
        conversationId: _conversationId,
        kind: CallKind.voice,
      );
      onOutgoingCall?.call(call);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onStartVideoCall(
    StartVideoCall event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final call = await _callRepository.initiateCall(
        conversationId: _conversationId,
        kind: CallKind.video,
      );
      onOutgoingCall?.call(call);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e is Failure ? e.message : e.toString(),
      ));
    }
  }

  Future<void> _onTypingChanged(
    TypingChanged event,
    Emitter<ChatState> emit,
  ) async {
    _typingDebounce?.cancel();
    if (event.isTyping) {
      _conversationRepository.startTyping(_conversationId);
      _typingDebounce = Timer(const Duration(seconds: 2), () {
        _conversationRepository.stopTyping(_conversationId);
        if (!isClosed) emit(state.copyWith(typingUsers: const []));
      });
    } else {
      _conversationRepository.stopTyping(_conversationId);
    }
  }

  void _onClearReply(ClearReply event, Emitter<ChatState> emit) {
    emit(state.copyWith(replyTo: null));
  }

  void _onSetReply(SetReply event, Emitter<ChatState> emit) {
    emit(state.copyWith(replyTo: event.message));
  }

  MessageKind _kindForMime(String mime) {
    if (mime.startsWith('image/')) return MessageKind.image;
    if (mime.startsWith('video/')) return MessageKind.video;
    return MessageKind.document;
  }

  String _fileNameFromPath(String path) {
    final segments = path.split(RegExp(r'[/\\]'));
    return segments.isNotEmpty ? segments.last : 'file';
  }

  @override
  Future<void> close() async {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _typingDebounce?.cancel();
    await super.close();
  }
}
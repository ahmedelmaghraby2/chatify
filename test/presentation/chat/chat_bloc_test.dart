import 'dart:async';

import 'package:chatify/core/errors/failures.dart';
import 'package:chatify/domain/entities/attachment.dart';
import 'package:chatify/domain/entities/conversation.dart';
import 'package:chatify/domain/entities/message.dart';
import 'package:chatify/domain/entities/reaction.dart';
import 'package:chatify/domain/entities/user.dart';
import 'package:chatify/domain/repositories/auth_repository.dart';
import 'package:chatify/domain/repositories/call_repository.dart';
import 'package:chatify/domain/repositories/conversation_repository.dart';
import 'package:chatify/domain/repositories/message_repository.dart';
import 'package:chatify/domain/repositories/storage_repository.dart';
import 'package:chatify/presentation/chat/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _conversationId = 'c1';
final _now = DateTime(2026, 9, 15, 12);
final _me = User(
  id: 'me',
  username: 'me',
  displayName: 'Me',
  createdAt: _now,
);

Message _msg({
  String id = 'm1',
  String? body = 'hello',
  String sender = 'me',
  MessageStatus status = MessageStatus.sent,
  List<Reaction> reactions = const [],
}) {
  return Message(
    id: id,
    clientId: id,
    conversationId: _conversationId,
    senderId: sender,
    body: body,
    createdAt: _now,
    status: status,
    reactions: reactions,
  );
}

Conversation _conv() => Conversation(
      id: _conversationId,
      kind: ConversationKind.direct,
      createdBy: 'me',
      createdAt: _now,
    );

class _MessageRepo implements MessageRepository {
  final messagesController = StreamController<List<Message>>.broadcast();
  final sentCalls = <Map<String, Object?>>[];
  final editCalls = <String>[];
  final deletedForMe = <String>[];
  final deletedForEveryone = <String>[];
  final addedReactions = <List<String>>[];
  final removedReactions = <List<String>>[];
  final seenCalls = <List<String>>[];
  List<Message> older = [];
  bool failSend = false;
  bool failEdit = false;

  @override
  Stream<List<Message>> watchMessages(String conversationId) =>
      messagesController.stream;

  @override
  Future<List<Message>> loadInitial(String conversationId) async => [];

  @override
  Future<List<Message>> loadOlder(String conversationId,
          {DateTime? before}) async =>
      older;

  @override
  Future<List<Message>> loadAround(String conversationId, String messageId) async =>
      [];

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String body,
    required MessageKind kind,
    String? replyToId,
    List<Attachment>? attachments,
  }) async {
    if (failSend) throw const NetworkFailure(message: 'offline');
    sentCalls.add({
      'conversationId': conversationId,
      'body': body,
      'kind': kind,
      'replyToId': replyToId,
      'attachments': attachments ?? const [],
    });
    return _msg(body: body, status: MessageStatus.sent);
  }

  @override
  Future<Message> editMessage(String messageId, String body) async {
    if (failEdit) throw const NetworkFailure(message: 'failed');
    editCalls.add(messageId);
    return _msg();
  }

  @override
  Future<void> deleteForMe(String messageId) async {
    deletedForMe.add(messageId);
  }

  @override
  Future<void> deleteForEveryone(String messageId) async {
    deletedForEveryone.add(messageId);
  }

  @override
  Future<void> addReaction(String messageId, String emoji) async {
    addedReactions.add([messageId, emoji]);
  }

  @override
  Future<void> removeReaction(String messageId, String emoji) async {
    removedReactions.add([messageId, emoji]);
  }

  @override
  Future<void> markAsDelivered(String conversationId, String messageId) async {}

  @override
  Future<void> markAsSeen(String conversationId, String messageId) async {
    seenCalls.add([conversationId, messageId]);
  }

  @override
  Future<List<Message>> searchMessages(String conversationId, String query) async =>
      [];

  @override
  Future<Message?> getMessage(String messageId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _ConversationRepo implements ConversationRepository {
  bool failGet = false;
  final typing = <String>[];

  @override
  Future<Conversation> getConversation(String id) async {
    if (failGet) throw const DatabaseFailure(message: 'not found');
    return _conv();
  }

  @override
  Stream<List<String>> watchTypingUsers(String conversationId) =>
      Stream<List<String>>.fromFuture(Future.value(typing));

  @override
  void startTyping(String conversationId) {}

  @override
  void stopTyping(String conversationId) {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _StorageRepo implements StorageRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _CallRepo implements CallRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _AuthRepo implements AuthRepository {
  @override
  User? get currentUser => _me;

  @override
  Stream<AuthState> get onAuthStateChange => const Stream<AuthState>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _MessageRepo messageRepo;
  late _ConversationRepo conversationRepo;

  ChatBloc buildBloc() => ChatBloc(
        messageRepository: messageRepo,
        conversationRepository: conversationRepo,
        storageRepository: _StorageRepo(),
        callRepository: _CallRepo(),
        authRepository: _AuthRepo(),
      );

  Future<void> pumpUntilState(
    ChatBloc bloc,
    bool Function(ChatState) condition, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition(bloc.state)) {
      if (DateTime.now().isAfter(deadline)) {
        fail('condition not met within $timeout');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  setUp(() {
    messageRepo = _MessageRepo();
    conversationRepo = _ConversationRepo();
  });

  group('ChatBloc', () {
    test('ChatOpened loads conversation and current user', () async {
      final bloc = buildBloc();
      bloc.add(ChatOpened(_conversationId));
      await pumpUntilState(bloc, (s) => s.status == ChatStatus.loaded);
      expect(bloc.state.conversation?.id, 'c1');
      expect(bloc.state.currentUser?.id, 'me');
      expect(bloc.state.errorMessage, isNull);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('ChatOpened surfaces errors', () async {
      conversationRepo.failGet = true;
      final bloc = buildBloc();
      bloc.add(ChatOpened(_conversationId));
      await pumpUntilState(bloc, (s) => s.status == ChatStatus.error);
      expect(bloc.state.errorMessage, isNotNull);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('SetReply and ClearReply manage replyTo', () async {
      final bloc = buildBloc();
      bloc.add(SetReply(_msg(sender: 'them')));
      await pumpUntilState(bloc, (s) => s.replyTo?.id == 'm1');
      expect(bloc.state.replyTo?.id, 'm1');

      bloc.add(ClearReply());
      await pumpUntilState(bloc, (s) => s.replyTo == null);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('SendTextMessage passes replyToId and clears it on success', () async {
      final bloc = buildBloc();
      bloc.add(ChatOpened(_conversationId));
      await pumpUntilState(bloc, (s) => s.status == ChatStatus.loaded);
      bloc.add(SetReply(_msg(sender: 'them')));

      bloc.add(SendTextMessage('Hi there'));
      await pumpUntilState(
        bloc,
        (s) => messageRepo.sentCalls.isNotEmpty && s.replyTo == null,
      );

      expect(messageRepo.sentCalls, hasLength(1));
      expect(messageRepo.sentCalls.first['replyToId'], 'm1');
      expect(messageRepo.sentCalls.first['body'], 'Hi there');
      expect(messageRepo.sentCalls.first['kind'], MessageKind.text);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('SendTextMessage trims and ignores empty input', () async {
      final bloc = buildBloc();
      bloc.add(SendTextMessage('   '));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(messageRepo.sentCalls, isEmpty);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('SendTextMessage failure sets errorMessage', () async {
      messageRepo.failSend = true;
      final bloc = buildBloc();
      bloc.add(SendTextMessage('hi'));
      await pumpUntilState(bloc, (s) => s.errorMessage != null);
      expect(bloc.state.errorMessage, contains('offline'));
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('EditMessage calls the repository', () async {
      final bloc = buildBloc();
      bloc.add(EditMessage(messageId: 'm1', newBody: 'updated'));
      await pumpUntilState(bloc, (_) => messageRepo.editCalls.isNotEmpty);
      expect(messageRepo.editCalls, ['m1']);
      expect(bloc.state.errorMessage, isNull);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('EditMessage failure sets errorMessage', () async {
      messageRepo.failEdit = true;
      final bloc = buildBloc();
      bloc.add(EditMessage(messageId: 'm1', newBody: 'updated'));
      await pumpUntilState(bloc, (s) => s.errorMessage != null);
      expect(bloc.state.errorMessage, contains('failed'));
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('DeleteMessageForMe and DeleteMessageForEveryone call repository',
        () async {
      final bloc = buildBloc();
      bloc.add(DeleteMessageForMe('m1'));
      bloc.add(DeleteMessageForEveryone('m1'));
      await pumpUntilState(
        bloc,
        (_) =>
            messageRepo.deletedForMe.length == 1 &&
            messageRepo.deletedForEveryone.length == 1,
      );
      expect(messageRepo.deletedForMe, ['m1']);
      expect(messageRepo.deletedForEveryone, ['m1']);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('ToggleReaction adds a new reaction', () async {
      final bloc = buildBloc();
      bloc.add(ChatOpened(_conversationId));
      await pumpUntilState(bloc, (s) => s.status == ChatStatus.loaded);

      messageRepo.messagesController.add([_msg(sender: 'me')]);
      await pumpUntilState(bloc, (s) => s.messages.any((m) => m.id == 'm1'));

      bloc.add(ToggleReaction(messageId: 'm1', emoji: '❤️'));
      await pumpUntilState(bloc, (_) => messageRepo.addedReactions.isNotEmpty);
      expect(messageRepo.addedReactions, [
        ['m1', '❤️'],
      ]);
      expect(messageRepo.removedReactions, isEmpty);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('ToggleReaction removes an existing reaction by current user',
        () async {
      final bloc = buildBloc();
      bloc.add(ChatOpened(_conversationId));
      await pumpUntilState(bloc, (s) => s.status == ChatStatus.loaded);

      final existing = _msg(
        sender: 'me',
        reactions: [
          Reaction(
            messageId: 'm1',
            userId: 'me',
            emoji: '❤️',
            createdAt: _now,
          ),
        ],
      );
      messageRepo.messagesController.add([existing]);
      await pumpUntilState(bloc, (s) => s.messages.any((m) => m.id == 'm1'));

      bloc.add(ToggleReaction(messageId: 'm1', emoji: '❤️'));
      await pumpUntilState(bloc, (_) => messageRepo.removedReactions.isNotEmpty);
      expect(messageRepo.removedReactions, [
        ['m1', '❤️'],
      ]);
      expect(messageRepo.addedReactions, isEmpty);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('LoadOlderMessages merges and sorts with existing messages', () async {
      messageRepo.older = [
        _msg(id: 'older1', body: 'older 1', status: MessageStatus.seen)
            .copyWith(createdAt: _now.subtract(const Duration(minutes: 5))),
        _msg(id: 'older2', body: 'older 2', status: MessageStatus.seen)
            .copyWith(createdAt: _now.subtract(const Duration(minutes: 1))),
      ];

      final bloc = buildBloc();
      bloc.add(ChatOpened(_conversationId));
      await pumpUntilState(bloc, (s) => s.status == ChatStatus.loaded);

      messageRepo.messagesController.add([_msg(id: 'newer', body: 'newer')]);
      await pumpUntilState(
          bloc, (s) => s.messages.any((m) => m.id == 'newer'));

      bloc.add(LoadOlderMessages());
      await pumpUntilState(bloc, (s) => s.messages.length == 3);
      expect(bloc.state.messages.map((m) => m.id), ['older1', 'older2', 'newer']);
      expect(bloc.state.loadingOlder, isFalse);
      await bloc.close();
      await messageRepo.messagesController.close();
    });

    test('MarkSeen records seen for external messages', () async {
      final bloc = buildBloc();
      bloc.add(ChatOpened(_conversationId));
      await pumpUntilState(bloc, (s) => s.status == ChatStatus.loaded);

      bloc.add(MarkSeen('m9'));
      await pumpUntilState(bloc, (_) => messageRepo.seenCalls.isNotEmpty);
      expect(messageRepo.seenCalls, [
        [_conversationId, 'm9'],
      ]);
      await bloc.close();
      await messageRepo.messagesController.close();
    });
  });
}
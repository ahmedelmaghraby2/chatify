import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';

class ConversationListState extends Equatable {
  final List<Conversation> conversations;
  final bool loading;
  final Failure? error;
  final bool hasLoaded;

  const ConversationListState({
    this.conversations = const [],
    this.loading = false,
    this.error,
    this.hasLoaded = false,
  });

  ConversationListState copyWith({
    List<Conversation>? conversations,
    bool? loading,
    Failure? error,
    bool? hasLoaded,
  }) =>
      ConversationListState(
        conversations: conversations ?? this.conversations,
        loading: loading ?? this.loading,
        error: error ?? this.error,
        hasLoaded: hasLoaded ?? this.hasLoaded,
      );

  @override
  List<Object?> get props => [conversations, loading, error, hasLoaded];
}

class ConversationsCubit extends Cubit<ConversationListState> {
  ConversationsCubit(this._repository) : super(const ConversationListState()) {
    _subscribe();
  }

  final ConversationRepository _repository;
  StreamSubscription<List<Conversation>>? _subscription;

  void _subscribe() {
    _subscription = _repository.watchConversations().listen(
          (conversations) {
            emit(state.copyWith(
              conversations: conversations,
              loading: false,
              hasLoaded: true,
              error: null,
            ));
          },
          onError: (Object e) {
            emit(state.copyWith(
              loading: false,
              error: e is Failure ? e : UnknownFailure(message: e.toString()),
            ));
          },
        );
  }

  void refresh() {
    emit(state.copyWith(loading: true));
    _subscription?.cancel();
    _subscribe();
  }

  void updateConversation(Conversation conversation) {
    final updated = [
      for (final c in state.conversations)
        c.id == conversation.id ? conversation : c,
    ];
    emit(state.copyWith(conversations: updated));
  }

  Future<void> pin(String conversationId) async {
    await _repository.pinConversation(conversationId);
  }

  Future<void> unpin(String conversationId) async {
    await _repository.unpinConversation(conversationId);
  }

  Future<void> mute(String conversationId, Duration duration) async {
    await _repository.muteConversation(conversationId, duration);
  }

  Future<void> unmute(String conversationId) async {
    await _repository.unmuteConversation(conversationId);
  }

  Future<void> archive(String conversationId) async {
    await _repository.archiveConversation(conversationId);
  }

  Future<void> unarchive(String conversationId) async {
    await _repository.unarchiveConversation(conversationId);
  }

  Future<void> clear(String conversationId) async {
    await _repository.clearConversation(conversationId);
  }

  Future<void> delete(String conversationId) async {
    await _repository.deleteConversation(conversationId);
  }

  Future<void> leave(String conversationId) async {
    await _repository.leaveGroup(conversationId);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
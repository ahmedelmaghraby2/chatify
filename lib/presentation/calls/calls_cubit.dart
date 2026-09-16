import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/call.dart';
import '../../domain/repositories/call_repository.dart';

class CallsState extends Equatable {
  final List<Call> calls;
  final bool loading;
  final Failure? error;
  final bool hasLoaded;

  const CallsState({
    this.calls = const [],
    this.loading = false,
    this.error,
    this.hasLoaded = false,
  });

  CallsState copyWith({
    List<Call>? calls,
    bool? loading,
    Failure? error,
    bool? hasLoaded,
  }) =>
      CallsState(
        calls: calls ?? this.calls,
        loading: loading ?? this.loading,
        error: error,
        hasLoaded: hasLoaded ?? this.hasLoaded,
      );

  @override
  List<Object?> get props => [calls, loading, error, hasLoaded];
}

class CallsCubit extends Cubit<CallsState> {
  CallsCubit({required CallRepository callRepository})
      : _callRepository = callRepository,
        super(const CallsState()) {
    _init();
  }

  final CallRepository _callRepository;

  StreamSubscription<Call?>? _incomingSub;

  Future<void> _init() async {
    emit(state.copyWith(loading: true));
    _incomingSub = _callRepository.watchIncomingCalls().listen(
      (call) {
        if (call == null) return;
        final current = state.calls;
        final idx = current.indexWhere((c) => c.id == call.id);
        final updated = [...current];
        if (idx >= 0) {
          updated[idx] = call;
        } else {
          updated.insert(0, call);
        }
        emit(state.copyWith(calls: updated, loading: false, hasLoaded: true));
      },
      onError: (Object e) {
        emit(state.copyWith(
          loading: false,
          error: e is Failure ? e : UnknownFailure(message: e.toString()),
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _incomingSub?.cancel();
    await super.close();
  }
}
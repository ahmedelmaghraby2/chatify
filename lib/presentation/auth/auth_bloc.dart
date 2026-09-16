import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String username;
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
    required this.username,
  });

  @override
  List<Object?> get props => [email, password, displayName, username];
}

class SignOutRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final Failure? error;
  final String? message;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.message,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Failure? error,
    String? message,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error ?? this.error,
        message: message ?? this.message,
      );

  @override
  List<Object?> get props => [status, user, error, message];
}

enum AuthStatus { unknown, loading, unauthenticated, authenticated }

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);
    on<PasswordResetRequested>(_onPasswordReset);
  }

  final AuthRepository _repository;

  Stream<AuthState> get onAuthStateChange =>
      _repository.onAuthStateChange.map((event) {
        return AuthState(
          status: event.event == AuthEventType.signedOut
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: event.user,
        );
      });

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      await _repository.restoreSession();
      final user = _repository.currentUser;
      if (user != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.signIn(email: event.email, password: event.password);
      emit(AuthState(
        status: AuthStatus.authenticated,
        user: _repository.currentUser,
      ));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, error: _toFailure(e)));
    }
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        username: event.username,
      );
      emit(AuthState(
        status: AuthStatus.authenticated,
        user: _repository.currentUser,
      ));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, error: _toFailure(e)));
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await _repository.signOut();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.authenticated, error: _toFailure(e)));
    }
  }

  Future<void> _onPasswordReset(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.resetPassword(event.email);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        message: 'Password reset email sent',
      ));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, error: _toFailure(e)));
    }
  }

  Failure _toFailure(Object e) {
    if (e is Failure) return e;
    return UnknownFailure(message: e.toString());
  }
}
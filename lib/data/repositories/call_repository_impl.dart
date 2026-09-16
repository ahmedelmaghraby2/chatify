import 'dart:async';

import '../../core/errors/failures.dart';
import '../../domain/entities/call.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/remote/supabase_auth_datasource.dart';
import '../datasources/remote/supabase_call_datasource.dart';
import '../models/dto/call_dto.dart';
import '../models/mappers/call_mapper.dart';

class CallRepositoryImpl implements CallRepository {
  CallRepositoryImpl({
    required SupabaseCallDatasource datasource,
    required SupabaseAuthDatasource authDatasource,
  })  : _datasource = datasource,
        _authDatasource = authDatasource;

  final SupabaseCallDatasource _datasource;
  final SupabaseAuthDatasource _authDatasource;

  @override
  Future<Call> initiateCall({
    required String conversationId,
    required CallKind kind,
  }) async {
    final initiatorId = _requireUserId();
    try {
      final row = await _datasource.initiateCall(
        conversationId,
        initiatorId,
        _kindToString(kind),
      );
      return _mapToCall(row);
    } catch (e) {
      throw CallFailure(message: e.toString());
    }
  }

  @override
  Future<void> acceptCall(String callId) async {
    try {
      await _datasource.acceptCall(callId);
    } catch (e) {
      throw CallFailure(message: e.toString());
    }
  }

  @override
  Future<void> rejectCall(String callId) async {
    try {
      await _datasource.rejectCall(callId);
    } catch (e) {
      throw CallFailure(message: e.toString());
    }
  }

  @override
  Future<void> endCall(String callId) async {
    try {
      await _datasource.endCall(callId);
    } catch (e) {
      throw CallFailure(message: e.toString());
    }
  }

  @override
  Stream<Call?> watchActiveCall(String callId) {
    return _datasource.watchActiveCall(callId).map(
          (row) => _mapToCall(row),
        );
  }

  @override
  Stream<Call?> watchIncomingCalls() {
    final userId = _requireUserId();
    return _datasource.watchIncomingCalls(userId).map(
          (rows) => rows.isEmpty ? null : _mapToCall(rows.first),
        );
  }

  @override
  Future<void> updateSignaling(String callId, Map<String, dynamic> data) async {
    try {
      await _datasource.updateSignaling(callId, data);
    } catch (e) {
      throw CallFailure(message: e.toString());
    }
  }

  @override
  Future<void> addIceCandidate(
    String callId,
    Map<String, dynamic> candidate,
  ) async {
    try {
      await _datasource.addIceCandidate(callId, candidate);
    } catch (e) {
      throw CallFailure(message: e.toString());
    }
  }

  String _requireUserId() {
    final userId = _authDatasource.currentAuthUser?.id;
    if (userId == null) {
      throw const CallFailure(message: 'User is not authenticated');
    }
    return userId;
  }

  Call _mapToCall(Map<String, dynamic> row) => CallDto.fromMap(row).toEntity();

  String _kindToString(CallKind kind) {
    switch (kind) {
      case CallKind.video:
        return 'video';
      case CallKind.voice:
        return 'voice';
    }
  }
}
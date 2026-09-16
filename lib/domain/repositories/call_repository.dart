import 'dart:async';

import '../entities/call.dart';

abstract class CallRepository {
  Future<Call> initiateCall({
    required String conversationId,
    required CallKind kind,
  });

  Future<void> acceptCall(String callId);

  Future<void> rejectCall(String callId);

  Future<void> endCall(String callId);

  Stream<Call?> watchActiveCall(String callId);

  Stream<Call?> watchIncomingCalls();

  Future<void> updateSignaling(String callId, Map<String, dynamic> data);

  Future<void> addIceCandidate(String callId, Map<String, dynamic> candidate);
}

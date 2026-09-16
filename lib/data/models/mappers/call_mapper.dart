import 'package:chatify/domain/entities/call.dart';

import '../dto/call_dto.dart';

extension CallParticipantDtoMapper on CallParticipantDto {
  CallParticipant toEntity() {
    return CallParticipant(
      userId: userId,
      joinedAt: joinedAt,
      leftAt: leftAt,
    );
  }
}

extension CallDtoMapper on CallDto {
  Call toEntity() {
    return Call(
      id: id,
      conversationId: conversationId,
      initiatorId: initiatorId,
      kind: _parseKind(kind),
      status: _parseStatus(status),
      startedAt: startedAt,
      endedAt: endedAt,
      signaling: signaling ?? {},
      participants: participants.map((e) => e.toEntity()).toList(),
    );
  }

  CallKind _parseKind(String kind) {
    switch (kind) {
      case 'video':
        return CallKind.video;
      default:
        return CallKind.voice;
    }
  }

  CallStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return CallStatus.active;
      case 'ended':
        return CallStatus.ended;
      case 'rejected':
        return CallStatus.rejected;
      case 'missed':
        return CallStatus.missed;
      case 'busy':
        return CallStatus.busy;
      case 'cancelled':
        return CallStatus.cancelled;
      default:
        return CallStatus.ringing;
    }
  }
}

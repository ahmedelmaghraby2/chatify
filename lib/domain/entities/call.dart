import 'package:equatable/equatable.dart';

enum CallKind { voice, video }

enum CallStatus { ringing, active, ended, rejected, missed, busy, cancelled }

class CallParticipant extends Equatable {
  final String userId;
  final DateTime? joinedAt;
  final DateTime? leftAt;

  const CallParticipant({
    required this.userId,
    this.joinedAt,
    this.leftAt,
  });

  @override
  List<Object?> get props => [userId, joinedAt, leftAt];
}

class Call extends Equatable {
  final String id;
  final String conversationId;
  final String initiatorId;
  final CallKind kind;
  final CallStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic> signaling;
  final List<CallParticipant> participants;

  const Call({
    required this.id,
    required this.conversationId,
    required this.initiatorId,
    required this.kind,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.signaling = const {},
    this.participants = const [],
  });

  bool get isActive => status == CallStatus.active;
  bool get isRinging => status == CallStatus.ringing;
  bool get isVideo => kind == CallKind.video;
  bool get isVoice => kind == CallKind.voice;
  bool get isEnded =>
      status == CallStatus.ended ||
      status == CallStatus.rejected ||
      status == CallStatus.missed ||
      status == CallStatus.cancelled;

  Duration get duration {
    if (endedAt == null) return DateTime.now().difference(startedAt);
    return endedAt!.difference(startedAt);
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        initiatorId,
        kind,
        status,
        startedAt,
        endedAt,
        participants,
      ];
}

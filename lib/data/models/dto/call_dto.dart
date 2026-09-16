class CallParticipantDto {
  final String userId;
  final DateTime? joinedAt;
  final DateTime? leftAt;

  const CallParticipantDto({
    required this.userId,
    this.joinedAt,
    this.leftAt,
  });

  factory CallParticipantDto.fromMap(Map<String, dynamic> map) {
    return CallParticipantDto(
      userId: map['user_id'] as String? ?? '',
      joinedAt: map['joined_at'] != null
          ? DateTime.parse(map['joined_at'] as String)
          : null,
      leftAt: map['left_at'] != null
          ? DateTime.parse(map['left_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'joined_at': joinedAt?.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
    };
  }
}

class CallDto {
  final String id;
  final String conversationId;
  final String initiatorId;
  final String kind;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic>? signaling;
  final List<CallParticipantDto> participants;

  const CallDto({
    required this.id,
    required this.conversationId,
    required this.initiatorId,
    required this.kind,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.signaling,
    this.participants = const [],
  });

  factory CallDto.fromMap(Map<String, dynamic> map) {
    return CallDto(
      id: map['id'] as String? ?? '',
      conversationId: map['conversation_id'] as String? ?? '',
      initiatorId: map['initiator_id'] as String? ?? '',
      kind: map['kind'] as String? ?? 'voice',
      status: map['status'] as String? ?? 'ringing',
      startedAt: map['started_at'] != null
          ? DateTime.parse(map['started_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      signaling: map['signaling'] as Map<String, dynamic>?,
      participants: (map['participants'] as List<dynamic>?)
              ?.map((e) => CallParticipantDto.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'initiator_id': initiatorId,
      'kind': kind,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'signaling': signaling,
      'participants': participants.map((e) => e.toMap()).toList(),
    };
  }
}

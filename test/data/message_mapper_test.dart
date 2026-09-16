import 'package:chatify/data/models/dto/message_dto.dart';
import 'package:chatify/data/models/mappers/message_mapper.dart';
import 'package:chatify/domain/entities/message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageDtoMapper', () {
    test('defaults map to text/sending entity', () {
      final dto = MessageDto(
        id: 'm1',
        clientId: 'c1',
        conversationId: 'chat1',
        senderId: 'u1',
        body: 'hello',
        createdAt: DateTime(2026, 9, 15, 8, 0),
      );
      final entity = dto.toEntity();
      expect(entity.id, 'm1');
      expect(entity.kind, MessageKind.text);
      expect(entity.status, MessageStatus.sending);
      expect(entity.body, 'hello');
      expect(entity.reactions, isEmpty);
      expect(entity.attachments, isEmpty);
    });

    test('fromMap parses supabase snake_case keys', () {
      final entity = MessageDto.fromMap({
        'id': 'm2',
        'client_id': 'c2',
        'conversation_id': 'chat1',
        'sender_id': 'u1',
        'kind': 'voice',
        'body': null,
        'reply_to_id': 'm1',
        'created_at': '2026-09-15T10:00:00.000',
        'status': 'seen',
        'sender_display_name': 'Alice',
        'reactions': [
          {'message_id': 'm2', 'user_id': 'u2', 'emoji': '❤️', 'created_at': '2026-09-15T10:05:00.000'},
        ],
        'attachments': <dynamic>[],
      }).toEntity();

      expect(entity.kind, MessageKind.voice);
      expect(entity.status, MessageStatus.seen);
      expect(entity.replyToId, 'm1');
      expect(entity.senderName, 'Alice');
      expect(entity.isEdited, isFalse);
      expect(entity.isVoice, isTrue);
      expect(entity.createdAt, DateTime(2026, 9, 15, 10));
      expect(entity.reactions.single.emoji, '❤️');
    });

    test('fromMap parses timestamps and unusual kinds', () {
      final entity = MessageDto.fromMap({
        'id': 'm3',
        'client_id': 'c3',
        'conversation_id': 'chat1',
        'sender_id': 'u1',
        'kind': 'document',
        'edited_at': '2026-09-15T11:00:00.000',
        'deleted_at': '2026-09-15T12:00:00.000',
        'created_at': '2026-09-15T09:00:00.000',
        'status': 'failed',
      }).toEntity();

      expect(entity.kind, MessageKind.document);
      expect(entity.status, MessageStatus.failed);
      expect(entity.isEdited, isTrue);
      expect(entity.isDeleted, isTrue);
      expect(entity.isFailed, isTrue);
    });

    test('toMap round-trips fields', () {
      final dto = MessageDto(
        id: 'm4',
        clientId: 'c4',
        conversationId: 'chat1',
        senderId: 'u1',
        kind: 'image',
        body: 'caption',
        createdAt: DateTime(2026, 9, 15, 9, 30),
        status: 'delivered',
        senderDisplayName: 'Bob',
      );
      final mapped = MessageDto.fromMap(dto.toMap());
      expect(mapped.id, dto.id);
      expect(mapped.kind, 'image');
      expect(mapped.status, 'delivered');
      expect(mapped.body, 'caption');
      expect(mapped.senderDisplayName, 'Bob');
      expect(mapped.createdAt, dto.createdAt);
    });

    test('unknown status falls back to sending', () {
      final entity = MessageDto.fromMap({
        'id': 'm5',
        'client_id': 'c5',
        'conversation_id': 'chat1',
        'sender_id': 'u1',
        'created_at': '2026-09-15T09:00:00.000',
        'status': 'bogus',
      }).toEntity();
      expect(entity.status, MessageStatus.sending);
    });
  });
}
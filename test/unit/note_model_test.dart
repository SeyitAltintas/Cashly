import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';

void main() {
  group('NoteModel Tests', () {
    test('empty() should generate a valid unique ID and timestamps', () {
      final note1 = NoteModel.empty();
      final note2 = NoteModel.empty();

      expect(note1.id, isNotEmpty);
      expect(note2.id, isNotEmpty);
      expect(note1.id, isNot(equals(note2.id)));
      
      expect(note1.deltaJson, '[]');
      expect(note1.title, '');
      expect(note1.createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1))), true);
      expect(note1.updatedAt.isBefore(DateTime.now().add(const Duration(seconds: 1))), true);
    });

    test('toMap() should serialize fields correctly including ISO-8601 dates', () {
      final now = DateTime.utc(2025, 1, 1, 12, 0, 0);
      final note = NoteModel(
        id: '12345',
        title: 'Test Note',
        deltaJson: '[{"insert":"Hello\\n"}]',
        createdAt: now,
        updatedAt: now,
      );

      final map = note.toMap();
      expect(map['id'], '12345');
      expect(map['title'], 'Test Note');
      expect(map['deltaJson'], '[{"insert":"Hello\\n"}]');
      expect(map['createdAt'], '2025-01-01T12:00:00.000Z');
      expect(map['updatedAt'], '2025-01-01T12:00:00.000Z');
    });

    test('fromMap() should parse fields and handle corrupted data gracefully (EC-16)', () {
      final map = {
        'id': '9876',
        'title': 'Parsed Note',
        'deltaJson': null, // corrupted data
        'createdAt': '2025-01-01T12:00:00.000Z',
        'updatedAt': '2025-01-01T12:00:00.000Z',
      };

      final note = NoteModel.fromMap(map);
      expect(note.id, '9876');
      expect(note.title, 'Parsed Note');
      expect(note.deltaJson, '[]'); // null-safe fallback
      expect(note.createdAt, DateTime.utc(2025, 1, 1, 12, 0, 0));
    });

    test('fromMap() should fall back to empty string when ID is missing/corrupt', () {
      final map = {
        'id': null,
        'title': 'No ID Note',
        'deltaJson': '[]',
        'createdAt': '2025-01-01T12:00:00.000Z',
        'updatedAt': '2025-01-01T12:00:00.000Z',
      };

      final note = NoteModel.fromMap(map);
      expect(note.id, ''); // ID becomes empty string, repository will skip it (EC-16)
    });

    test('copyWith() should update fields correctly while preserving others', () {
      final original = NoteModel(
        id: '123',
        title: 'Title',
        deltaJson: '[]',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      final updatedDate = DateTime(2026);
      final copied = original.copyWith(
        title: 'New Title',
        deltaJson: '[{"insert":"Text"}]',
        updatedAt: updatedDate,
      );

      expect(copied.id, '123'); // Unchanged
      expect(copied.createdAt, DateTime(2025)); // Unchanged
      expect(copied.title, 'New Title'); // Changed
      expect(copied.deltaJson, '[{"insert":"Text"}]'); // Changed
      expect(copied.updatedAt, updatedDate); // Changed
    });
  });
}

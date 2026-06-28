import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';

void main() {
  late NoteRepository repository;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    repository = NoteRepository();
    await repository.init();
    await repository.clearAll();
  });

  tearDown(() async {
    await repository.clearAll();
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('NoteRepository Tests', () {
    test('Singleton pattern ensures the same instance is returned (EC-8)', () {
      final repo1 = NoteRepository();
      final repo2 = NoteRepository();
      expect(identical(repo1, repo2), true);
    });

    test('saveNote() and getNoteById() work correctly', () async {
      final note = NoteModel.empty().copyWith(title: 'Test Note');
      
      await repository.saveNote(note);
      
      final fetched = repository.getNoteById(note.id);
      expect(fetched, isNotNull);
      expect(fetched?.title, 'Test Note');
      expect(repository.noteCount, 1);
    });

    test('getAllNotes() returns notes sorted by updatedAt descending', () async {
      final note1 = NoteModel.empty().copyWith(
        title: 'Older', 
        updatedAt: DateTime(2025, 1, 1),
      );
      final note2 = NoteModel.empty().copyWith(
        title: 'Newer', 
        updatedAt: DateTime(2025, 1, 2),
      );

      await repository.saveNote(note1);
      await repository.saveNote(note2);

      final notes = repository.getAllNotes();
      expect(notes.length, 2);
      expect(notes.first.title, 'Newer'); // The more recently updated note should be first
      expect(notes.last.title, 'Older');
    });

    test('getAllNotes() skips corrupted entries gracefully', () async {
      final validNote = NoteModel.empty().copyWith(title: 'Valid');
      await repository.saveNote(validNote);

      // Insert corrupted data manually into the box
      final box = await Hive.openBox('notes');
      await box.put('corrupted_id', 'This is not a map');
      await box.put('missing_id_map', {'title': 'No ID'}); 
      
      final notes = repository.getAllNotes();
      
      // Should only return the valid note, gracefully skipping the other two
      expect(notes.length, 1);
      expect(notes.first.title, 'Valid');
    });

    test('updateNote() updates delta and title but preserves originalCreatedAt (EC-16)', () async {
      final originalDate = DateTime(2024, 1, 1);
      final initialNote = NoteModel(
        id: '123',
        title: 'Old Title',
        deltaJson: '[]',
        createdAt: originalDate,
        updatedAt: originalDate,
      );
      
      await repository.saveNote(initialNote);

      final updatedNote = await repository.updateNote(
        id: '123',
        deltaJson: '[{"insert":"Updated\\n"}]',
        title: 'New Title',
        originalCreatedAt: originalDate,
      );

      expect(updatedNote.title, 'New Title');
      expect(updatedNote.deltaJson, '[{"insert":"Updated\\n"}]');
      expect(updatedNote.createdAt, originalDate); // Preserved
      expect(updatedNote.updatedAt.isAfter(originalDate), true); // Updated
    });

    test('updateNote() creates a fallback note if it was deleted (EC-16)', () async {
      final originalDate = DateTime(2024, 1, 1);
      
      // Note doesn't exist in repo yet
      final updatedNote = await repository.updateNote(
        id: 'deleted_id',
        deltaJson: '[{"insert":"Recovered\\n"}]',
        title: 'Recovered Title',
        originalCreatedAt: originalDate,
      );

      expect(updatedNote.id, 'deleted_id');
      expect(updatedNote.title, 'Recovered Title');
      expect(updatedNote.deltaJson, '[{"insert":"Recovered\\n"}]');
      expect(updatedNote.createdAt, originalDate); 
      
      final fetched = repository.getNoteById('deleted_id');
      expect(fetched, isNotNull);
    });

    test('deleteNote() removes note from box', () async {
      final note = NoteModel.empty();
      await repository.saveNote(note);
      
      expect(repository.noteCount, 1);
      
      await repository.deleteNote(note.id);
      
      expect(repository.noteCount, 0);
      expect(repository.getNoteById(note.id), isNull);
    });
    
    test('listenable() works', () async {
      expect(repository.listenable(), isNotNull);
    });
  });
}

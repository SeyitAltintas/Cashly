import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/presentation/pages/note_editor_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';

void main() {
  late NoteRepository repository;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox('notes', bytes: Uint8List(0));
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    repository = NoteRepository();
    await repository.init();
    await repository.clearAll();
  });

  tearDown(() async {
    await repository.clearAll();
  });

  Widget createWidgetUnderTest({String? noteId}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: NoteEditorPage(noteId: noteId, heroTag: 'test_tag'),
    );
  }

  group('NoteEditorPage Widget Tests', () {
    testWidgets('Initializes with empty state when no noteId is provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(QuillEditor).evaluate().isNotEmpty) break;
      }

      expect(find.byType(QuillEditor), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Loads existing note when noteId is provided', (tester) async {
      final note = NoteModel.empty().copyWith(
        title: 'Existing Note',
        deltaJson: '[{"insert":"Hello Quill\\n"}]',
      );
      await tester.runAsync(() async => await repository.saveNote(note));

      await tester.pumpWidget(createWidgetUnderTest(noteId: note.id));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(QuillEditor).evaluate().isNotEmpty) break;
      }

      final titleFinder = find.byType(TextField);
      expect(tester.widget<TextField>(titleFinder).controller?.text, 'Existing Note');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Prevents saving an empty note (EC-19)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(QuillEditor).evaluate().isNotEmpty) break;
      }

      // Tap back button, which tries to save
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(repository.noteCount, 0);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Navigating back automatically saves the note', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(QuillEditor).evaluate().isNotEmpty) break;
      }

      // Type title
      await tester.enterText(find.byType(TextField), 'Auto Save Title');
      
      // Type body
      final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
      editor.controller.replaceText(0, 0, 'Some body content', null);
      await tester.pump();

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // wait for pop

      expect(repository.noteCount, 1);
      final savedNotes = repository.getAllNotes();
      expect(savedNotes.first.title, 'Auto Save Title');
    });

    testWidgets('Autosaves when app goes to background (EC-22)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.byType(QuillEditor).evaluate().isNotEmpty) break;
      }

      // Type title
      await tester.enterText(find.byType(TextField), 'Background Save Title');
      
      // Type body
      final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
      editor.controller.replaceText(0, 0, 'Autosave test', null);
      await tester.pump();

      expect(repository.noteCount, 0); // Not saved yet

      // Trigger app lifecycle change
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

      // Give the save operation a tick to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(repository.noteCount, 1);
      final savedNotes = repository.getAllNotes();
      expect(savedNotes.first.title, 'Background Save Title');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}

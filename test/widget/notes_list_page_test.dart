import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/features/notes/presentation/pages/notes_list_page.dart';
import 'package:cashly/features/notes/presentation/pages/note_editor_page.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  late NoteRepository repository;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    // Open an in-memory box so NoteRepository uses it without disk I/O
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

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: NotesListPage(),
    );
  }

  group('NotesListPage Widget Tests', () {
    testWidgets('Shows empty state when no notes exist', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.note_alt_outlined), findsOneWidget);
      // We don't assert hardcoded string for empty text because of l10n,
      // but we know the icon is there and FAB is there
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Renders list of notes correctly ordered by date', (tester) async {
      final note1 = NoteModel.empty().copyWith(
        title: 'Older Note',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      final note2 = NoteModel.empty().copyWith(
        title: 'Newer Note',
        updatedAt: DateTime.now(),
      );

      await tester.runAsync(() async => await repository.saveNote(note1));
      await tester.runAsync(() async => await repository.saveNote(note2));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Older Note'), findsOneWidget);
      expect(find.text('Newer Note'), findsOneWidget);
      
      // Verify order - newer should be first
      final textWidgets = tester.widgetList<Text>(find.byType(Text)).toList();
      final newerIndex = textWidgets.indexWhere((w) => w.data == 'Newer Note');
      final olderIndex = textWidgets.indexWhere((w) => w.data == 'Older Note');
      expect(newerIndex < olderIndex, true, reason: 'Newer note should be above older note');
    });

    testWidgets('Tapping FAB navigates to NoteEditorPage', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(NoteEditorPage), findsOneWidget);
    });

    testWidgets('Tapping a note navigates to NoteEditorPage with note id', (tester) async {
      final note = NoteModel.empty().copyWith(title: 'My Custom Note');
      await tester.runAsync(() async => await repository.saveNote(note));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('My Custom Note'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(NoteEditorPage), findsOneWidget);
      // the note title should appear in the app bar
      expect(find.text('My Custom Note'), findsWidgets); 
    });

    testWidgets('Swiping a note deletes it and shows a Snackbar (EC-9)', (tester) async {
      final note = NoteModel.empty().copyWith(title: 'To Be Deleted');
      await tester.runAsync(() async => await repository.saveNote(note));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('To Be Deleted'), findsOneWidget);
      expect(repository.noteCount, 1);

      // Swipe to delete
      await tester.fling(find.byType(Dismissible).first, const Offset(-500.0, 0.0), 1000.0, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Check it was deleted
      expect(find.text('To Be Deleted'), findsNothing);
      expect(repository.noteCount, 0);

      // Check snackbar (it shows a success message)
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}

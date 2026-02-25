import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/state/month_year_picker_state.dart';

/// MonthYearPickerState testleri
/// Ay/yıl seçimi, initialize, getSelectedDateTime, notifyListeners
void main() {
  late MonthYearPickerState state;

  setUp(() {
    state = MonthYearPickerState();
  });

  group('MonthYearPickerState — Başlangıç Durumu', () {
    test('varsayılan değerler bugünün tarihinde', () {
      final now = DateTime.now();
      expect(state.currentDate.year, equals(now.year));
      expect(state.currentDate.month, equals(now.month));
      expect(state.selectedYear, equals(now.year));
      expect(state.selectedMonthIndex, equals(now.month - 1));
    });
  });

  group('MonthYearPickerState — initialize', () {
    test('belirtilen tarihle başlatılır', () {
      final date = DateTime(2023, 3, 15);
      state.initialize(date);

      expect(state.currentDate, equals(date));
      expect(state.selectedYear, equals(2023));
      expect(state.selectedMonthIndex, equals(2)); // Mart = index 2
    });

    test('Ocak ayı doğru index', () {
      state.initialize(DateTime(2024, 1, 1));
      expect(state.selectedMonthIndex, equals(0));
    });

    test('Aralık ayı doğru index', () {
      state.initialize(DateTime(2024, 12, 31));
      expect(state.selectedMonthIndex, equals(11));
    });
  });

  group('MonthYearPickerState — setMonth', () {
    test('ay indexi set edilir', () {
      state.setMonth(5);
      expect(state.selectedMonthIndex, equals(5)); // Haziran
    });

    test('modüler: 12 → 0 (Ocak)', () {
      state.setMonth(12);
      expect(state.selectedMonthIndex, equals(0));
    });

    test('modüler: 13 → 1 (Şubat)', () {
      state.setMonth(13);
      expect(state.selectedMonthIndex, equals(1));
    });

    test('notifyListeners tetiklenir', () {
      int count = 0;
      state.addListener(() => count++);

      state.setMonth(3);
      expect(count, equals(1));
    });
  });

  group('MonthYearPickerState — setYear', () {
    test('yıl set edilir', () {
      state.setYear(2025);
      expect(state.selectedYear, equals(2025));
    });

    test('notifyListeners tetiklenir', () {
      int count = 0;
      state.addListener(() => count++);

      state.setYear(2020);
      expect(count, equals(1));
    });
  });

  group('MonthYearPickerState — setDate', () {
    test('tarih set edilir', () {
      final newDate = DateTime(2024, 8, 20);
      state.setDate(newDate);
      expect(state.currentDate, equals(newDate));
    });

    test('notifyListeners tetiklenir', () {
      int count = 0;
      state.addListener(() => count++);

      state.setDate(DateTime(2024, 1, 1));
      expect(count, equals(1));
    });
  });

  group('MonthYearPickerState — getSelectedDateTime', () {
    test('seçilen ay/yıl doğru DateTime döner', () {
      state.setYear(2024);
      state.setMonth(5); // Haziran (index 5)

      final result = state.getSelectedDateTime();
      expect(result.year, equals(2024));
      expect(result.month, equals(6)); // Index 5 + 1 = Haziran
    });

    test('Ocak ay/yıl', () {
      state.setYear(2023);
      state.setMonth(0); // Ocak index

      final result = state.getSelectedDateTime();
      expect(result.year, equals(2023));
      expect(result.month, equals(1));
    });

    test('Aralık ay/yıl', () {
      state.setYear(2025);
      state.setMonth(11); // Aralık index

      final result = state.getSelectedDateTime();
      expect(result.year, equals(2025));
      expect(result.month, equals(12));
    });
  });
}

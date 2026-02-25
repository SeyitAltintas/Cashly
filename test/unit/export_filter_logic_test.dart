import 'package:flutter_test/flutter_test.dart';

/// ExportService tarih filtreleme mantığı testleri
/// _filterByDateRange ve _filterIncomesByDateRange private oldukları için
/// burada aynı mantığı birebir test ediyoruz (pure logic testing)
///
/// Harcamalar: 'tarih' key
/// Gelirler: 'date' key
void main() {
  /// Harcama tarih filtreleme mantığı (ExportService._filterByDateRange ile birebir)
  List<Map<String, dynamic>> filterByDateRange(
    List<Map<String, dynamic>> items,
    DateTime startDate,
    DateTime endDate,
  ) {
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

    return items.where((item) {
        final tarihStr = item['tarih'] as String?;
        if (tarihStr == null) return false;
        final tarih = DateTime.parse(tarihStr);
        final normalizedTarih = DateTime(tarih.year, tarih.month, tarih.day);
        return !normalizedTarih.isBefore(normalizedStart) &&
            !normalizedTarih.isAfter(normalizedEnd);
      }).toList()
      ..sort((a, b) => (b['tarih'] as String).compareTo(a['tarih'] as String));
  }

  /// Gelir tarih filtreleme mantığı (ExportService._filterIncomesByDateRange)
  List<Map<String, dynamic>> filterIncomesByDateRange(
    List<Map<String, dynamic>> items,
    DateTime startDate,
    DateTime endDate,
  ) {
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

    return items.where((item) {
        final dateStr = item['date'] as String?;
        if (dateStr == null) return false;
        final date = DateTime.parse(dateStr);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        return !normalizedDate.isBefore(normalizedStart) &&
            !normalizedDate.isAfter(normalizedEnd);
      }).toList()
      ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
  }

  group('Harcama Tarih Filtreleme', () {
    final testData = [
      {
        'isim': 'Ocak 10',
        'tutar': 100.0,
        'tarih': DateTime(2024, 1, 10).toString(),
      },
      {
        'isim': 'Ocak 20',
        'tutar': 200.0,
        'tarih': DateTime(2024, 1, 20).toString(),
      },
      {
        'isim': 'Şubat 5',
        'tutar': 300.0,
        'tarih': DateTime(2024, 2, 5).toString(),
      },
      {
        'isim': 'Mart 15',
        'tutar': 400.0,
        'tarih': DateTime(2024, 3, 15).toString(),
      },
      {
        'isim': 'Nisan 1',
        'tutar': 500.0,
        'tarih': DateTime(2024, 4, 1).toString(),
      },
    ];

    test('tarih aralığı doğru filtrelenir (Ocak)', () {
      final result = filterByDateRange(
        testData,
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 31),
      );

      expect(result.length, equals(2));
      expect(result.any((r) => r['isim'] == 'Ocak 10'), isTrue);
      expect(result.any((r) => r['isim'] == 'Ocak 20'), isTrue);
    });

    test('başlangıç tarihi dahil (inclusive)', () {
      final result = filterByDateRange(
        testData,
        DateTime(2024, 1, 10), // Tam Ocak 10 tarihinde başla
        DateTime(2024, 1, 15),
      );

      expect(result.length, equals(1));
      expect(result.first['isim'], equals('Ocak 10'));
    });

    test('bitiş tarihi dahil (inclusive)', () {
      final result = filterByDateRange(
        testData,
        DateTime(2024, 1, 15),
        DateTime(2024, 1, 20), // Tam Ocak 20 tarihinde bitir
      );

      expect(result.length, equals(1));
      expect(result.first['isim'], equals('Ocak 20'));
    });

    test('aynı gün başlangıç ve bitiş', () {
      final result = filterByDateRange(
        testData,
        DateTime(2024, 2, 5),
        DateTime(2024, 2, 5),
      );

      expect(result.length, equals(1));
      expect(result.first['isim'], equals('Şubat 5'));
    });

    test('sonuçlar azalan tarihe göre sıralı', () {
      final result = filterByDateRange(
        testData,
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );

      expect(result.length, equals(5));
      expect(result.first['isim'], equals('Nisan 1'));
      expect(result.last['isim'], equals('Ocak 10'));
    });

    test('aralık dışında sonuç yok', () {
      final result = filterByDateRange(
        testData,
        DateTime(2025, 1, 1),
        DateTime(2025, 12, 31),
      );

      expect(result, isEmpty);
    });

    test('boş liste hata vermez', () {
      final result = filterByDateRange(
        [],
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );

      expect(result, isEmpty);
    });

    test('tarih alanı null olan kayıtlar atlanır', () {
      final dataWithNull = [
        {
          'isim': 'Normal',
          'tutar': 100.0,
          'tarih': DateTime(2024, 1, 10).toString(),
        },
        {'isim': 'Tarihsiz', 'tutar': 200.0, 'tarih': null},
      ];

      final result = filterByDateRange(
        dataWithNull,
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );

      expect(result.length, equals(1));
      expect(result.first['isim'], equals('Normal'));
    });

    test('saat/dakika/saniye normalize edilir', () {
      final dataWithTime = [
        {
          'isim': 'Sabah',
          'tutar': 100.0,
          'tarih': DateTime(2024, 1, 15, 8, 30, 0).toString(),
        },
        {
          'isim': 'Akşam',
          'tutar': 200.0,
          'tarih': DateTime(2024, 1, 15, 23, 59, 59).toString(),
        },
      ];

      final result = filterByDateRange(
        dataWithTime,
        DateTime(2024, 1, 15, 12, 0, 0), // Öğlen başlangıç
        DateTime(2024, 1, 15, 12, 0, 0), // Öğlen bitiş
      );

      // Saat/dakika normalize ediliyor, her iki kayıt da o güne ait
      expect(result.length, equals(2));
    });
  });

  group('Gelir Tarih Filtreleme', () {
    final testIncomes = [
      {
        'name': 'Maaş',
        'amount': 30000.0,
        'date': DateTime(2024, 1, 1).toIso8601String(),
      },
      {
        'name': 'Freelance',
        'amount': 5000.0,
        'date': DateTime(2024, 2, 15).toIso8601String(),
      },
      {
        'name': 'Kira Geliri',
        'amount': 8000.0,
        'date': DateTime(2024, 3, 1).toIso8601String(),
      },
    ];

    test('gelirler doğru aralıkta filtrelenir', () {
      final result = filterIncomesByDateRange(
        testIncomes,
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 31),
      );

      expect(result.length, equals(1));
      expect(result.first['name'], equals('Maaş'));
    });

    test('tüm yıl filtresi tüm gelirleri döndürür', () {
      final result = filterIncomesByDateRange(
        testIncomes,
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );

      expect(result.length, equals(3));
    });

    test('gelir sonuçları azalan tarihe göre sıralı', () {
      final result = filterIncomesByDateRange(
        testIncomes,
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );

      // Mart > Şubat > Ocak
      expect(result.first['name'], equals('Kira Geliri'));
      expect(result.last['name'], equals('Maaş'));
    });

    test('date null olan gelirler atlanır', () {
      final dataWithNull = [
        {
          'name': 'Normal',
          'amount': 1000.0,
          'date': DateTime(2024, 6, 1).toIso8601String(),
        },
        {'name': 'Tarihsiz', 'amount': 2000.0, 'date': null},
      ];

      final result = filterIncomesByDateRange(
        dataWithNull,
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );

      expect(result.length, equals(1));
    });
  });

  group('Cross-Module: Harcama-Gelir Rapor Tutarlılığı', () {
    test('aynı dönemdeki harcama ve gelir filtrelemesi tutarlı', () {
      final expenses = [
        {
          'isim': 'Market',
          'tutar': 500.0,
          'tarih': DateTime(2024, 6, 10).toString(),
        },
        {
          'isim': 'Taksi',
          'tutar': 100.0,
          'tarih': DateTime(2024, 6, 20).toString(),
        },
      ];
      final incomes = [
        {
          'name': 'Maaş',
          'amount': 30000.0,
          'date': DateTime(2024, 6, 1).toIso8601String(),
        },
      ];

      final start = DateTime(2024, 6, 1);
      final end = DateTime(2024, 6, 30);

      final filteredExpenses = filterByDateRange(expenses, start, end);
      final filteredIncomes = filterIncomesByDateRange(incomes, start, end);

      final toplamHarcama = filteredExpenses.fold<double>(
        0,
        (sum, e) => sum + (e['tutar'] as double),
      );
      final toplamGelir = filteredIncomes.fold<double>(
        0,
        (sum, i) => sum + (i['amount'] as double),
      );

      expect(filteredExpenses.length, equals(2));
      expect(filteredIncomes.length, equals(1));
      expect(toplamHarcama, equals(600.0));
      expect(toplamGelir, equals(30000.0));
      expect(toplamGelir - toplamHarcama, equals(29400.0));
    });
  });
}

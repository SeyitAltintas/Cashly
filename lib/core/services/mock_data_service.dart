import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cashly/features/streak/data/services/streak_service.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';

/// Geliştirici ve test amaçlı gerçekçi sahte veri üreticisi.
///
/// Veri tutarlılığı garantileri:
/// - Ödeme yöntemleri önce oluşturulur, diğer veriler bu ID'lere bağlanır.
/// - Harcamalar ödeme yöntemi bakiyelerini düşürür, gelirler artırır.
/// - Son bakiye her zaman başlangıç bakiyesi + gelirler - harcamalar ile tutarlıdır.
/// - Veriler 6 aya yayılmış, her ay mantıklı tutarlarla dağıtılmıştır.
class MockDataService {
  final _firestore = FirebaseFirestore.instance;
  final _random = Random(); // Sabit seed kaldırıldı, her seferinde farklı veri

  // ===== SABIT VERİ HAVUZLARI =====

  static const _expenseCategories = [
    'Yemek ve Kafe',
    'Market ve Atıştırmalık',
    'Araç ve Ulaşım',
    'Sabit Giderler',
    'Diğer',
    'Hediye ve Özel',
  ];

  static const _expenseNames = {
    'Yemek ve Kafe': [
      'Öğle yemeği',
      'Akşam yemeği',
      'Kahvaltı',
      'Kafe',
      'Tatlı',
      'Restoran',
      'Döner',
      'Pizza',
      'Burger',
    ],
    'Market ve Atıştırmalık': [
      'Migros',
      'A101',
      'BİM',
      'CarrefourSA',
      'Şok market',
      'Manav',
      'Ekmek ve süt',
      'Haftalık alışveriş',
    ],
    'Araç ve Ulaşım': [
      'Benzin',
      'Metrobüs',
      'Metro kartı',
      'Taksi',
      'Otopark',
      'Araç bakım',
      'Sigorta',
      'Servis',
    ],
    'Sabit Giderler': [
      'Elektrik faturası',
      'Su faturası',
      'Doğalgaz',
      'İnternet',
      'Telefon faturası',
      'Kira',
    ],
    'Diğer': [
      'Eczane',
      'Kitap',
      'Kırtasiye',
      'Spor salonu',
      'Sinema',
      'Abonelik',
      'Berbere gittim',
    ],
    'Hediye ve Özel': [
      'Doğum günü hediyesi',
      'Düğün hediyesi',
      'Özel alışveriş',
      'Çiçek',
    ],
  };

  static const _incomeNames = {
    'Maaş': ['Aylık maaş', 'Maaş', 'Bordro ödemesi'],
    'Serbest Çalışma': [
      'Freelance proje',
      'Danışmanlık ücreti',
      'Yazılım projesi',
      'Tasarım işi',
    ],
    'Kira Geliri': ['Daire kira geliri', 'Dükkan kira geliri'],
    'Diğer': ['Prim ödemesi', 'İkramiye', 'Satış geliri', 'Çeşitli gelir'],
  };

  // ===== ANA METOT =====

  /// Kullanıcı için 6 aylık gerçekçi sahte veri üretir ve Firebase'e yazar.
  /// Tüm veriler batch write ile atomik olarak eklenir.
  Future<void> generateMockData(String userId) async {
    debugPrint('[MockDataService] Sahte veri üretimi başlıyor...');

    // Önceki mock verileri temizle (Idempotency için)
    await clearMockData(userId);

    // 1. Ödeme yöntemlerini oluştur (önce bunlar — diğerleri bunlara bağlı)
    final paymentMethods = _generatePaymentMethods();
    final bankId = paymentMethods[0]['id'] as String;
    final creditId = paymentMethods[1]['id'] as String;
    final cashId = paymentMethods[2]['id'] as String;

    // 2. 6 ay boyunca harcama/gelir üret ve bakiye hesapla
    final now = DateTime.now();
    final expenses = <Map<String, dynamic>>[];
    final incomes = <Map<String, dynamic>>[];
    final transfers = <Map<String, dynamic>>[];

    // Her ödeme yöntemi için gerçek bakiye takibi
    final balances = {
      bankId: 15000.0, // Başlangıç bakiyesi
      creditId: 0.0, // Kredi kartı borcu (negatif = borç)
      cashId: 2500.0, // Nakit başlangıcı
    };

    for (int monthOffset = 5; monthOffset >= 0; monthOffset--) {
      final month = DateTime(now.year, now.month - monthOffset, 1);
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

      // Her ay için gelirler
      final monthlyIncomes = _generateMonthlyIncomes(
        month,
        daysInMonth,
        bankId,
        cashId,
      );

      // Filtre: Gelecek tarihte olan gerçekleşmiş verileri sil
      if (monthOffset == 0) {
        monthlyIncomes.removeWhere((inc) {
          final date = (inc['date'] as Timestamp).toDate();
          return date.isAfter(now);
        });
      }

      incomes.addAll(monthlyIncomes);

      // Gelirler bakiyeye eklenir
      for (final income in monthlyIncomes) {
        if (income['isDeleted'] == true) continue;

        final pmId = income['paymentMethodId'] as String?;
        final amount = (income['amount'] as num).toDouble();
        if (pmId != null && balances.containsKey(pmId)) {
          if (pmId == creditId) {
            balances[pmId] =
                balances[pmId]! -
                amount; // Gelir gelirse kredi kartı borcu azalır
          } else {
            balances[pmId] = balances[pmId]! + amount;
          }
        }
      }

      // Her ay için harcamalar
      final monthlyExpenses = _generateMonthlyExpenses(
        month,
        daysInMonth,
        bankId,
        creditId,
        cashId,
      );

      // Filtre: Gelecek tarihte olan harcamaları sil
      if (monthOffset == 0) {
        monthlyExpenses.removeWhere((exp) {
          final date = (exp['tarih'] as Timestamp).toDate();
          return date.isAfter(now);
        });
      }

      expenses.addAll(monthlyExpenses);

      // Harcamalar bakiyeden düşülür
      for (final expense in monthlyExpenses) {
        if (expense['silindi'] == true) continue;

        final pmId = expense['odemeYontemiId'] as String?;
        final amount = (expense['tutar'] as num).toDouble();
        if (pmId != null && balances.containsKey(pmId)) {
          if (pmId == creditId) {
            balances[pmId] =
                balances[pmId]! + amount; // Harcama kredi kartı borcunu artırır
          } else {
            balances[pmId] = balances[pmId]! - amount; // Nakit/Banka azalır
          }
        }
      }

      // Her ay için transferler (Bankadan nakite, Bankadan kredi kartı ödemesi vs.)
      final monthlyTransfers = _generateMonthlyTransfers(
        month,
        daysInMonth,
        bankId,
        creditId,
        cashId,
      );

      // Filtre: Gelecek tarihte olan geçmiş transferleri sil (Zamanlanmış hariç)
      if (monthOffset == 0) {
        monthlyTransfers.removeWhere((tr) {
          if (tr['isScheduled'] == true) return false;
          final date = DateTime.parse(tr['date'].toString());
          return date.isAfter(now);
        });
      }

      transfers.addAll(monthlyTransfers);

      // Transferleri bakiyeye yansıt
      for (final transfer in monthlyTransfers) {
        // İptal edilen veya henüz gerçekleşmeyen transferler bakiyeyi etkilemez
        if (transfer['isFailed'] == true ||
            (transfer['isScheduled'] == true &&
                transfer['isExecuted'] == false)) {
          continue;
        }

        final fromId = transfer['fromAccountId'] as String?;
        final toId = transfer['toAccountId'] as String?;
        final amount = (transfer['amount'] as num).toDouble();

        if (fromId != null && balances.containsKey(fromId)) {
          if (fromId == creditId) {
            balances[fromId] =
                balances[fromId]! + amount; // Krediden çıkış borcu artırır
          } else {
            balances[fromId] = balances[fromId]! - amount;
          }
        }
        if (toId != null && balances.containsKey(toId)) {
          if (toId == creditId) {
            balances[toId] =
                balances[toId]! - amount; // Krediye giriş borcu azaltır
          } else {
            balances[toId] = balances[toId]! + amount;
          }
        }
      }
    }

    // 4. Varlıklar
    final assets = _generateAssets(now);

    // 5. Streak Sahte Verisi
    final streakData = _generateStreakData(now);

    // 6. Notlar Sahte Verisi
    final noteRepo = NoteRepository();
    await noteRepo.init();
    final mockNotes = _generateMockNotes(now);
    for (final note in mockNotes) {
      await noteRepo.saveNote(note);
    }

    // Lokal veritabanını da (Hive) zorla güncelle ki UI anında tepki versin
    await StreakService.saveStreakData(userId, RankData.fromMap(streakData));

    // Bakiyelerdeki son manuel düşüşleri ödeme yöntemlerine yansıt
    for (int i = 0; i < paymentMethods.length; i++) {
      final pmId = paymentMethods[i]['id'] as String;
      if (balances.containsKey(pmId)) {
        paymentMethods[i] = Map<String, dynamic>.from(paymentMethods[i])
          ..['balance'] = double.parse(balances[pmId]!.toStringAsFixed(2));
      }
    }

    // 6. Firebase'e yaz (batch)
    await _writeTofirestore(
      userId,
      paymentMethods,
      expenses,
      incomes,
      assets,
      transfers,
      streakData,
    );

    debugPrint(
      '[MockDataService] Tamamlandı! '
      '${expenses.length} harcama, ${incomes.length} gelir, ${transfers.length} transfer, '
      '${assets.length} varlık, ${paymentMethods.length} ödeme yöntemi, 1 streak verisi.',
    );
  }

  // ===== VERİ ÜRETİCİLER =====

  List<Map<String, dynamic>> _generatePaymentMethods() {
    final now = DateTime.now().toIso8601String();
    return [
      {
        'id': 'mock_banka_001',
        'name': 'Ziraat Bankası',
        'type': 'banka',
        'lastFourDigits': '4521',
        'balance': 15000.0, // Sonradan güncellenir
        'limit': null,
        'colorIndex': 1,
        'createdAt': now,
        'paraBirimi': 'TRY',
        'isDeleted': false,
      },
      {
        'id': 'mock_kredi_001',
        'name': 'Garanti Kredi Kartı',
        'type': 'kredi',
        'lastFourDigits': '8823',
        'balance': 0.0, // Sonradan güncellenir
        'limit': 20000.0,
        'colorIndex': 2,
        'createdAt': now,
        'paraBirimi': 'TRY',
        'isDeleted': false,
      },
      {
        'id': 'mock_nakit_001',
        'name': 'Nakit',
        'type': 'nakit',
        'lastFourDigits': null,
        'balance': 2500.0, // Sonradan güncellenir
        'limit': null,
        'colorIndex': 0,
        'createdAt': now,
        'paraBirimi': 'TRY',
        'isDeleted': false,
      },
      {
        'id': 'mock_banka_002',
        'name': 'Kapatılan Hesap',
        'type': 'banka',
        'lastFourDigits': '9999',
        'balance': 0.0,
        'limit': null,
        'colorIndex': 3,
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 300))
            .toIso8601String(),
        'paraBirimi': 'TRY',
        'isDeleted': true, // Mock çöp kutusu testi
      },
    ];
  }

  List<Map<String, dynamic>> _generateMonthlyIncomes(
    DateTime month,
    int daysInMonth,
    String bankId,
    String cashId,
  ) {
    final incomes = <Map<String, dynamic>>[];

    // Maaş — her ay 3-5 arası günde
    final salaryDay = 3 + _random.nextInt(3);
    final salaryAmount = 18000 + (_random.nextInt(8) * 500).toDouble();
    incomes.add(
      _buildIncome(
        name: 'Aylık maaş',
        category: 'Maaş',
        amount: salaryAmount,
        date: DateTime(
          month.year,
          month.month,
          salaryDay,
          _random.nextInt(4) + 8,
          _random.nextInt(60),
          _random.nextInt(60),
        ),
        paymentMethodId: bankId,
      ),
    );

    // Kira Geliri - her ay 1. gün (recurring templates ile tutarlı)
    incomes.add(
      _buildIncome(
        name: 'Daire kira geliri',
        category: 'Kira Geliri',
        amount: 3000.0,
        date: DateTime(month.year, month.month, 1, 9, 30, 0),
        paymentMethodId: cashId,
      ),
    );

    // Ek gelirler (% 40 ihtimal)
    if (_random.nextDouble() < 0.4) {
      final extraCategories = ['Serbest Çalışma', 'Diğer'];
      final cat = extraCategories[_random.nextInt(extraCategories.length)];
      final names = _incomeNames[cat]!;
      incomes.add(
        _buildIncome(
          name: names[_random.nextInt(names.length)],
          category: cat,
          amount: (2000 + _random.nextInt(15) * 500).toDouble(),
          date: DateTime(
            month.year,
            month.month,
            10 + _random.nextInt(15),
            _random.nextInt(10) + 10,
            _random.nextInt(60),
            _random.nextInt(60),
          ),
          paymentMethodId: _random.nextBool() ? bankId : cashId,
          isDeleted: _random.nextDouble() < 0.05, // %5 ihtimalle silinmiş veri
        ),
      );
    }

    return incomes;
  }

  List<Map<String, dynamic>> _generateMonthlyTransfers(
    DateTime month,
    int daysInMonth,
    String bankId,
    String creditId,
    String cashId,
  ) {
    final transfers = <Map<String, dynamic>>[];

    // 1. Bankadan nakit çekimi (ATM) - ayda 2-3 kez
    int atmCekimSayisi = _random.nextInt(2) + 2;
    for (int i = 0; i < atmCekimSayisi; i++) {
      int day = _random.nextInt(daysInMonth) + 1;
      transfers.add({
        'id': 'mock_tr_${month.year}_${month.month}_atm_$i',
        'fromAccountId': bankId,
        'toAccountId': cashId,
        'amount': (500 + _random.nextInt(15) * 100)
            .toDouble(), // 500 - 1900 arası
        'date': DateTime(
          month.year,
          month.month,
          day,
          _random.nextInt(10) + 9,
          _random.nextInt(60),
        ).toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
        'description': 'ATM Para Çekme',
        'paraBirimi': 'TRY',
        'isScheduled': false,
        'isExecuted': true,
        'isFailed': false,
      });
    }

    // 2. Kredi kartı borç ödemesi (Bankadan Kredi Kartına) - ayda 1 kez (Eğer geçmişte bir ay ise, bu mantıklıdır)
    int day = _random.nextInt(5) + 10; // Ayın 10-15 arası
    transfers.add({
      'id': 'mock_tr_${month.year}_${month.month}_cc',
      'fromAccountId': bankId,
      'toAccountId': creditId,
      'amount': (500 + _random.nextInt(15) * 100)
          .toDouble(), // 500 - 1900 arası ödeme (Ortalama harcamalarla uyumlu)
      'date': DateTime(
        month.year,
        month.month,
        day,
        _random.nextInt(5) + 10,
        _random.nextInt(60),
      ).toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
      'description': 'Kredi Kartı Ödemesi',
      'paraBirimi': 'TRY',
      'isScheduled': false,
      'isExecuted': true,
      'isFailed': false,
    });

    // 3. Başarısız transfer örneği
    if (_random.nextDouble() < 0.2) {
      transfers.add({
        'id': 'mock_tr_${month.year}_${month.month}_failed',
        'fromAccountId': bankId,
        'toAccountId': creditId,
        'amount': (10000.0),
        'date': DateTime(month.year, month.month, 5).toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
        'description': 'Kredi Kartı Ödemesi (Başarısız)',
        'paraBirimi': 'TRY',
        'isScheduled': false,
        'isExecuted': false,
        'isFailed': true,
        'failureReason': 'Yetersiz bakiye',
      });
    }

    // 4. Zamanlanmış transfer (Sadece içinde bulunduğumuz aydaysak)
    final now = DateTime.now();
    if (month.year == now.year && month.month == now.month) {
      transfers.add({
        'id': 'mock_tr_future',
        'fromAccountId': bankId,
        'toAccountId': cashId,
        'amount': (1000.0),
        'date': DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 3)).toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
        'description': 'İleri Tarihli Nakit Çekim',
        'paraBirimi': 'TRY',
        'isScheduled': true,
        'isExecuted': false,
        'isFailed': false,
      });
    }

    return transfers;
  }

  List<Map<String, dynamic>> _generateMonthlyExpenses(
    DateTime month,
    int daysInMonth,
    String bankId,
    String creditId,
    String cashId,
  ) {
    final expenses = <Map<String, dynamic>>[];
    final paymentIds = [bankId, creditId, cashId];

    // Sabit aylık faturalar
    final fixedExpenses = [
      {'isim': 'Kira', 'tutar': 8500.0, 'gun': 1, 'pmId': bankId},
      {
        'isim': 'Elektrik faturası',
        'tutar': 350.0 + _random.nextInt(100),
        'gun': 5,
        'pmId': bankId,
      },
      {
        'isim': 'Su faturası',
        'tutar': 80.0 + _random.nextInt(30),
        'gun': 7,
        'pmId': bankId,
      },
      {'isim': 'İnternet', 'tutar': 299.0, 'gun': 10, 'pmId': bankId},
      {'isim': 'Telefon faturası', 'tutar': 450.0, 'gun': 12, 'pmId': creditId},
      {
        'isim': 'Doğalgaz',
        'tutar': 200.0 + _random.nextInt(150),
        'gun': 8,
        'pmId': bankId,
      },
    ];

    for (final fixed in fixedExpenses) {
      final day = (fixed['gun'] as int).clamp(1, daysInMonth);
      expenses.add(
        _buildExpense(
          isim: fixed['isim'] as String,
          kategori: 'Sabit Giderler',
          tutar: (fixed['tutar'] as num).toDouble(),
          date: DateTime(
            month.year,
            month.month,
            day,
            _random.nextInt(15) + 8,
            _random.nextInt(60),
            _random.nextInt(60),
          ),
          odemeYontemiId: fixed['pmId'] as String,
        ),
      );
    }

    // Değişken günlük harcamalar (25-35 adet/ay)
    final expenseCount = 25 + _random.nextInt(11);
    final availableCategories = _expenseCategories
        .where((c) => c != 'Sabit Giderler')
        .toList();

    for (int i = 0; i < expenseCount; i++) {
      final cat =
          availableCategories[_random.nextInt(availableCategories.length)];
      final names = _expenseNames[cat]!;
      final name = names[_random.nextInt(names.length)];
      final day = 1 + _random.nextInt(daysInMonth);
      final pmId = paymentIds[_random.nextInt(paymentIds.length)];

      // Kategori bazlı tutar aralığı
      final double amount;
      switch (cat) {
        case 'Yemek ve Kafe':
          amount = 50 + (_random.nextInt(30) * 10).toDouble();
          break;
        case 'Market ve Atıştırmalık':
          amount = 200 + (_random.nextInt(15) * 50).toDouble();
          break;
        case 'Araç ve Ulaşım':
          amount = 100 + (_random.nextInt(20) * 25).toDouble();
          break;
        case 'Hediye ve Özel':
          amount = 200 + (_random.nextInt(30) * 50).toDouble();
          break;
        default:
          amount = 50 + (_random.nextInt(20) * 25).toDouble();
      }

      expenses.add(
        _buildExpense(
          isim: name,
          kategori: cat,
          tutar: amount,
          date: DateTime(
            month.year,
            month.month,
            day.clamp(1, daysInMonth),
            _random.nextInt(15) + 8,
            _random.nextInt(60),
            _random.nextInt(60),
          ),
          odemeYontemiId: pmId,
          silindi: _random.nextDouble() < 0.05, // %5 ihtimalle silinmiş veri
        ),
      );
    }

    return expenses;
  }

  List<Map<String, dynamic>> _generateAssets(DateTime now) {
    return [
      _buildAsset(
        name: 'Dolar',
        category: 'Döviz',
        type: 'USD',
        quantity: 1000.0,
        purchasePrice: 31000.0,
        amount: 35200.0,
        paraBirimi: 'TRY',
      ),
      _buildAsset(
        name: 'Gram Altın',
        category: 'Altın',
        type: 'XAU',
        quantity: 10.0,
        purchasePrice: 38000.0,
        amount: 42000.0,
        paraBirimi: 'TRY',
      ),
      _buildAsset(
        name: 'Bitcoin',
        category: 'Kripto',
        type: 'BTC',
        quantity: 0.05,
        purchasePrice: 38000.0,
        amount: 45000.0,
        paraBirimi: 'TRY',
      ),
      _buildAsset(
        name: 'Gümüş',
        category: 'Emtia',
        type: 'XAG',
        quantity: 100.0,
        purchasePrice: 4000.0,
        amount: 4500.0,
        paraBirimi: 'TRY',
        isDeleted: true,
      ),
    ];
  }

  Map<String, dynamic> _buildAsset({
    required String name,
    required String category,
    String? type,
    required double quantity,
    required double purchasePrice,
    required double amount,
    required String paraBirimi,
    bool isDeleted = false,
  }) {
    final now = DateTime.now();
    final purchaseDate = now.subtract(
      Duration(days: _random.nextInt(180) + 30),
    );

    return {
      'id':
          'mock_asset_${(type ?? category).toLowerCase()}_${_random.nextInt(99999)}',
      'name': name,
      'category': category,
      'type': type,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'amount': amount,
      'paraBirimi': paraBirimi,
      'purchaseDate': purchaseDate.toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  Map<String, dynamic> _generateStreakData(DateTime now) {
    final currentStreak = 5 + _random.nextInt(20);
    final longestStreak = currentStreak + _random.nextInt(30);
    final totalLoginDays = longestStreak + 20 + _random.nextInt(100);

    // UI testleri için tamamen rastgele rank üret (Her seviyeyi test edebilmek için 0-7500 XP arası)
    int calculatedXp = _random.nextInt(7500);

    return {
      'totalXp': calculatedXp, // Rütbeyi belirleyen asıl değer
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLoginDate': now.toIso8601String().split('T')[0],
      'totalLoginDays': totalLoginDays,
      'earnedBadges': ['first_week', 'month_hero'],
      'freezeCount': _random.nextInt(5),
      'usedFreezeToday': false,
      'totalFreezesUsed': _random.nextInt(10),
      'mock_generated': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ===== YARDIMCI BUILDER'LAR =====

  Map<String, dynamic> _buildExpense({
    required String isim,
    required String kategori,
    required double tutar,
    required DateTime date,
    required String odemeYontemiId,
    bool silindi = false,
  }) {
    return {
      'id': 'mock_exp_${date.millisecondsSinceEpoch}_${_random.nextInt(99999)}',
      'isim': isim,
      'kategori': kategori,
      'tutar': tutar,
      'tarih': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
      'paraBirimi': 'TRY',
      'odemeYontemiId': odemeYontemiId,
      'silindi': silindi,
    };
  }

  Map<String, dynamic> _buildIncome({
    required String name,
    required String category,
    required double amount,
    required DateTime date,
    required String paymentMethodId,
    bool isDeleted = false,
  }) {
    return {
      'id': 'mock_inc_${date.millisecondsSinceEpoch}_${_random.nextInt(99999)}',
      'name': name,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
      'paraBirimi': 'TRY',
      'paymentMethodId': paymentMethodId,
      'isDeleted': isDeleted,
    };
  }

  // ===== FIRESTORE YAZICI =====

  Future<void> _writeTofirestore(
    String userId,
    List<Map<String, dynamic>> paymentMethods,
    List<Map<String, dynamic>> expenses,
    List<Map<String, dynamic>> incomes,
    List<Map<String, dynamic>> assets,
    List<Map<String, dynamic>> transfers,
    Map<String, dynamic> streakData,
  ) async {
    final userDoc = _firestore.collection('users').doc(userId);

    // Firestore batch limiti 500 — parçalara böl
    final allOps = <Future<void>>[];

    // Ödeme yöntemleri
    var batch = _firestore.batch();
    for (final pm in paymentMethods) {
      if (pm['isDeleted'] == true) {
        batch.set(
          userDoc.collection('deletedPaymentMethods').doc(pm['id']),
          pm,
        );
      } else {
        batch.set(userDoc.collection('paymentMethods').doc(pm['id']), pm);
      }
    }
    allOps.add(batch.commit());

    // Harcamalar — 400'lük gruplar
    for (int i = 0; i < expenses.length; i += 400) {
      final chunk = expenses.sublist(i, min(i + 400, expenses.length));
      final b = _firestore.batch();
      for (final e in chunk) {
        b.set(userDoc.collection('expenses').doc(e['id']), e);
      }
      allOps.add(b.commit());
    }

    // Gelirler — 400'lük gruplar
    for (int i = 0; i < incomes.length; i += 400) {
      final chunk = incomes.sublist(i, min(i + 400, incomes.length));
      final b = _firestore.batch();
      for (final inc in chunk) {
        b.set(userDoc.collection('incomes').doc(inc['id']), inc);
      }
      allOps.add(b.commit());
    }

    // Varlıklar
    final assetBatch = _firestore.batch();
    for (final asset in assets) {
      if (asset['isDeleted'] == true) {
        assetBatch.set(
          userDoc.collection('deletedAssets').doc(asset['id']),
          asset,
        );
      } else {
        assetBatch.set(userDoc.collection('assets').doc(asset['id']), asset);
      }
    }
    allOps.add(assetBatch.commit());

    // Transferler - 400'lük gruplar
    for (int i = 0; i < transfers.length; i += 400) {
      final chunk = transfers.sublist(i, min(i + 400, transfers.length));
      final b = _firestore.batch();
      for (final t in chunk) {
        b.set(userDoc.collection('transfers').doc(t['id']), t);
      }
      allOps.add(b.commit());
    }

    // ===== AYARLAR (Settings) =====
    // Harcama ayarları: bütçe, sabit gider şablonları, kategori bütçeleri
    allOps.add(
      userDoc.collection('settings').doc('general').set({
        'budget': 20000.0,
        'mock_generated': true,
        'defaultPaymentMethodId': 'mock_banka_001',
        'fixedExpenseTemplates': [
          {
            'id': 'mock_ft_1',
            'isim': 'Kira',
            'tutar': 8500.0,
            'gun': 1,
            'odemeYontemiId': 'mock_banka_001',
            'kategori': 'Sabit Giderler',
          },
          {
            'id': 'mock_ft_2',
            'isim': 'Elektrik faturası',
            'tutar': 380.0,
            'gun': 5,
            'odemeYontemiId': 'mock_banka_001',
            'kategori': 'Sabit Giderler',
          },
          {
            'id': 'mock_ft_3',
            'isim': 'Su faturası',
            'tutar': 95.0,
            'gun': 7,
            'odemeYontemiId': 'mock_banka_001',
            'kategori': 'Sabit Giderler',
          },
          {
            'id': 'mock_ft_4',
            'isim': 'Doğalgaz',
            'tutar': 250.0,
            'gun': 8,
            'odemeYontemiId': 'mock_banka_001',
            'kategori': 'Sabit Giderler',
          },
          {
            'id': 'mock_ft_5',
            'isim': 'İnternet',
            'tutar': 299.0,
            'gun': 10,
            'odemeYontemiId': 'mock_banka_001',
            'kategori': 'Sabit Giderler',
          },
          {
            'id': 'mock_ft_6',
            'isim': 'Telefon faturası',
            'tutar': 450.0,
            'gun': 12,
            'odemeYontemiId': 'mock_kredi_001',
            'kategori': 'Sabit Giderler',
          },
        ],
        'categoryBudgets': {
          'Yemek ve Kafe': 4000.0,
          'Market ve Atıştırmalık': 3500.0,
          'Araç ve Ulaşım': 2000.0,
          'Sabit Giderler': 10000.0,
          'Diğer': 1500.0,
          'Hediye ve Özel': 1000.0,
        },
      }, SetOptions(merge: true)),
    );

    // Gelir ayarları: aylık hedef ve tekrarlayan gelirler
    allOps.add(
      userDoc.collection('settings').doc('income').set({
        'monthlyIncomeTarget': 22000.0,
        'mock_generated': true,
        'recurringIncomes': [
          {
            'id': 'mock_ri_1',
            'isim': 'Aylık maaş',
            'tutar': 19000.0,
            'gun': 3,
            'kategori': 'Maaş',
            'odemeYontemiId': 'mock_banka_001',
          },
          {
            'id': 'mock_ri_2',
            'isim': 'Daire kira geliri',
            'tutar': 3000.0,
            'gun': 1,
            'kategori': 'Kira Geliri',
            'odemeYontemiId': 'mock_nakit_001',
          },
        ],
      }, SetOptions(merge: true)),
    );

    // ===== STREAK =====
    allOps.add(
      userDoc
          .collection('streak')
          .doc('data')
          .set(streakData, SetOptions(merge: true)),
    );

    await Future.wait(allOps);
  }

  /// Kullanıcıya ait tüm mock verileri temizler.
  Future<void> clearMockData(String userId) async {
    debugPrint('[MockDataService] Mock veriler temizleniyor...');
    final userDoc = _firestore.collection('users').doc(userId);

    // Local Notları temizle
    final noteRepo = NoteRepository();
    await noteRepo.init();
    final allNotes = noteRepo.getAllNotes();
    for (final note in allNotes) {
      if (note.id.startsWith('mock_note_')) {
        await noteRepo.deleteNote(note.id);
      }
    }

    // Koleksiyon dökümanları (mock_ prefix'li olanlar)
    final collections = [
      'expenses',
      'incomes',
      'paymentMethods',
      'assets',
      'transfers',
      'deletedAssets',
      'deletedPaymentMethods',
    ];
    for (final col in collections) {
      final snap = await userDoc.collection(col).get();
      final mockDocs = snap.docs.where((d) => d.id.startsWith('mock_'));

      final batch = _firestore.batch();
      for (final doc in mockDocs) {
        batch.delete(doc.reference);
      }
      if (mockDocs.isNotEmpty) await batch.commit();
    }

    // Settings dökümanlarındaki mock alanlarını temizle
    final generalDoc = await userDoc
        .collection('settings')
        .doc('general')
        .get();
    if (generalDoc.exists && generalDoc.data()?['mock_generated'] == true) {
      final currentTemplates = List<dynamic>.from(
        generalDoc.data()?['fixedExpenseTemplates'] ?? [],
      );
      currentTemplates.removeWhere(
        (item) => item['id'].toString().startsWith('mock_'),
      );
      await userDoc.collection('settings').doc('general').update({
        'fixedExpenseTemplates': currentTemplates,
        'mock_generated': FieldValue.delete(),
      });
    }

    final incomeDoc = await userDoc.collection('settings').doc('income').get();
    if (incomeDoc.exists && incomeDoc.data()?['mock_generated'] == true) {
      final currentIncomes = List<dynamic>.from(
        incomeDoc.data()?['recurringIncomes'] ?? [],
      );
      currentIncomes.removeWhere(
        (item) => item['id'].toString().startsWith('mock_'),
      );
      await userDoc.collection('settings').doc('income').update({
        'recurringIncomes': currentIncomes,
        'mock_generated': FieldValue.delete(),
      });
    }

    // Streak mock temizliği
    final streakDoc = await userDoc.collection('streak').doc('data').get();
    if (streakDoc.exists && streakDoc.data()?['mock_generated'] == true) {
      await userDoc.collection('streak').doc('data').delete();
    }

    debugPrint('[MockDataService] Mock veriler temizlendi.');
  }

  List<NoteModel> _generateMockNotes(DateTime now) {
    final titles = [
      'Alışveriş Listesi',
      'Projeler ve Fikirler',
      'Okunacak Kitaplar',
      'Toplantı Notları',
      'Yatırım Stratejisi',
      'Seyahat Planı',
      'Günün Sözü',
      'Antrenman Programı',
      'Yemek Tarifi',
      'Kişisel Gelişim',
    ];
    final mockNotesContents = [
      '[{"insert":"Günlük Plan - Pazartesi\\n","attributes":{"header":1}},{"insert":"Bugün halledilmesi gereken önemli işler var. Özellikle faturaların yatırılması gerekiyor. Elektrik faturası bu ay çok yüksek gelmiş, incelemem lazım.\\nMarket alışverişi listesi:\\n"},{"insert":"Domates","attributes":{"list":"bullet"}},{"insert":"\\n"},{"insert":"Salatalık","attributes":{"list":"bullet"}},{"insert":"\\n"},{"insert":"Yumurta (30\'lu)","attributes":{"list":"bullet"}},{"insert":"\\n"},{"insert":"Süt (Laktoksuz)","attributes":{"list":"bullet"}},{"insert":"\\n"},{"insert":"Ayrıca arabayı yıkamaya götürmem lazım. Sonra da spora geçeceğim. \\n"}]',
      '[{"insert":"Projeler ve Fikirler\\n","attributes":{"header":2}},{"insert":"Yeni bir mobil uygulama fikri geldi aklıma. İnsanların günlük su tüketimini takip edebilecekleri, oyunlaştırılmış bir yapı. Adını "},{"insert":"WaterQuest","attributes":{"bold":true}},{"insert":" koyabilirim.\\n\\nÖzellikler:\\n- Kullanıcılar kendi avatarlarını seçebilecek.\\n- İçtikleri her bardak su için XP kazanacaklar.\\n- Arkadaşlarıyla liderlik tablosunda yarışabilecekler.\\n\\nYapılacak ilk iş, bir tasarım prototipi hazırlamak. "},{"insert":"Figma","attributes":{"italic":true}},{"insert":" üzerinden tasarımlara başlayacağım yarın sabah.\\n"}]',
      '[{"insert":"Okunacak Kitaplar Listesi\\n","attributes":{"header":2}},{"insert":"Bu yıl bitirmeyi hedeflediğim kitapların listesi:\\n1. Atomik Alışkanlıklar - James Clear\\n2. 1984 - George Orwell\\n3. Sefiller - Victor Hugo\\n4. Sapiens - Yuval Noah Harari\\n\\nSapiens\'e geçen hafta başladım, gerçekten ufuk açıcı bir kitap. İnsanın tarihsel gelişimini sadece biyolojik değil sosyolojik ve psikolojik olarak da harika özetlemiş.\\n"}]',
      '[{"insert":"Toplantı Notları - 15 Ekim\\n","attributes":{"header":3}},{"insert":"Toplantı katılımcıları: Ali, Ayşe, Mehmet.\\n\\nKonu: Yıl sonu bütçe değerlendirmesi.\\n\\nNotlar:\\n- Pazarlama bütçesinde %15\'lik bir artış planlanıyor.\\n- Yeni yıl kampanyası için ajansla görüşülecek. "},{"insert":"Acil!","attributes":{"bold":true,"color":"#ff0000"}},{"insert":"\\n- Sunucu maliyetlerini düşürmek için bulut sağlayıcısı ile yeniden pazarlık yapılacak.\\n\\nMehmet Bey gelecek hafta için detaylı bir rapor hazırlayacak.\\n"}]',
      '[{"insert":"Yatırım Stratejisi 2026\\n","attributes":{"header":2}},{"insert":"Piyasalardaki dalgalanmalar nedeniyle portföyü biraz daha defansif hale getirmek mantıklı olabilir.\\n- "},{"insert":"Altın (XAU):","attributes":{"bold":true}},{"insert":" Portföyün %20\'si altına kaydırılabilir. Güvenli liman olmaya devam ediyor.\\n- "},{"insert":"Kripto (BTC):","attributes":{"bold":true}},{"insert":" Riskli varlıklar için %10\'luk bir dilim ayrıldı. Kısa vadeli al-sat yerine uzun vadeli tutmak daha mantıklı görünüyor.\\n- "},{"insert":"Hisse Senetleri:","attributes":{"bold":true}},{"insert":" Teknoloji hisselerindeki düşüşü alım fırsatı olarak değerlendireceğim.\\n\\nNot: Yatırım tavsiyesi değildir, tamamen kendi analizim!\\n"}]',
      '[{"insert":"Seyahat Planı: İtalya Rüyası\\n","attributes":{"header":1}},{"insert":"Gelecek yaz için harika bir İtalya rotası çıkardım:\\n\\n1. Gün: Roma\\nKolezyum, Pantheon, Trevi Çeşmesi. Akşam Trastevere\'de pizza.\\n2. Gün: Floransa\\nUffizi Galerisi, Duomo. Toskana şarap tadımı.\\n3. Gün: Venedik\\nSan Marco Meydanı, Gondol turu. Akşam Büyük Kanal\'da yürüyüş.\\n\\nBütçe:\\nUçak biletleri yaklaşık 15.000 TL tutuyor. Konaklama için Airbnb seçeneklerini değerlendirmem lazım.\\n"}]',
      '[{"insert":"Günün Sözü ve Motivasyon\\n","attributes":{"header":2}},{"insert":"\\"Hiçbir şeyden asla vazgeçme; çünkü vazgeçenler, yalnızca yenilgiyi kabul edenlerdir.\\"\\n\\nBugün kendimi biraz yorgun hissetsem de hedeflerimden vazgeçmeye niyetim yok. Küçük adımlarla da olsa ilerlemeye devam edeceğim. Dün dündür, bugün yeni bir gün. Başarabilirim!\\n"}]',
      '[{"insert":"Fitness Antrenman Programı\\n","attributes":{"header":2}},{"insert":"Pazartesi: Göğüs & Arka Kol\\n- Bench Press 4x10\\n- Incline Dumbbell Press 3x12\\n- Triceps Pushdown 4x12\\n\\nÇarşamba: Sırt & Pazu\\n- Lat Pulldown 4x10\\n- Barbell Row 3x12\\n- Bicep Curl 4x12\\n\\nCuma: Bacak & Omuz\\n- Squat 4x10\\n- Leg Press 3x12\\n- Overhead Press 4x10\\n\\n"}]',
      '[{"insert":"Yemek Tarifi: Fırında Somon\\n","attributes":{"header":2}},{"insert":"Malzemeler:\\n- 2 dilim somon fileto\\n- 1 adet limon\\n- 2 diş sarımsak\\n- Zeytinyağı, tuz, karabiber, kekik\\n\\nHazırlanışı:\\n1. Somonları yıkayıp kurulayın.\\n2. Zeytinyağı, ezilmiş sarımsak ve baharatlarla bir sos hazırlayıp somonların her yerine sürün.\\n3. Üzerine limon dilimleri yerleştirin.\\n4. Önceden ısıtılmış 200 derece fırında 20-25 dakika pişirin.\\n\\nAfiyet olsun! Yanına bol yeşillikli bir salata çok iyi gider.\\n"}]',
      '[{"insert":"Kişisel Gelişim Notları\\n","attributes":{"header":1}},{"insert":"Kendimi geliştirmek için bu ay odaklanacağım konular:\\n\\n1. "},{"insert":"Yabancı Dil:","attributes":{"bold":true}},{"insert":" Her gün en az 30 dakika İngilizce pratik yapılacak. Duolingo veya Cambly kullanılabilir.\\n2. "},{"insert":"Yazılım:","attributes":{"bold":true}},{"insert":" Flutter ile yeni baştan bir proje geliştirmeye başlanacak. Durum yönetimi olarak Riverpod veya Bloc derinlemesine öğrenilecek.\\n3. "},{"insert":"Meditasyon:","attributes":{"bold":true}},{"insert":" Sabahları uyandığımda 10 dakika nefes egzersizi ve meditasyon yapılacak. Stres yönetimi için çok önemli.\\n"}]',
    ];

    final colors = [
      null,
      0xFFFFCDD2,
      0xFFC8E6C9,
      0xFFBBDEFB,
      0xFFFFF9C4,
      0xFFE1BEE7,
      null,
      null,
      0xFFB2DFDB,
      0xFFFFE0B2,
    ];

    final notes = <NoteModel>[];
    for (int i = 0; i < 10; i++) {
      notes.add(
        NoteModel(
          id: 'mock_note_${i}_${_random.nextInt(99999)}',
          title: titles[i],
          deltaJson: mockNotesContents[i],
          color: colors[i],
          createdAt: now.subtract(
            Duration(days: _random.nextInt(60), hours: _random.nextInt(24)),
          ),
          updatedAt: now.subtract(
            Duration(days: _random.nextInt(10), hours: _random.nextInt(24)),
          ),
        ),
      );
    }
    return notes;
  }
}

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Geliştirici ve test amaçlı gerçekçi sahte veri üreticisi.
///
/// Veri tutarlılığı garantileri:
/// - Ödeme yöntemleri önce oluşturulur, diğer veriler bu ID'lere bağlanır.
/// - Harcamalar ödeme yöntemi bakiyelerini düşürür, gelirler artırır.
/// - Son bakiye her zaman başlangıç bakiyesi + gelirler - harcamalar ile tutarlıdır.
/// - Veriler 6 aya yayılmış, her ay mantıklı tutarlarla dağıtılmıştır.
class MockDataService {
  final _firestore = FirebaseFirestore.instance;
  final _random = Random(42); // Sabit seed = her seferinde aynı veri

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
    'Yemek ve Kafe': ['Öğle yemeği', 'Akşam yemeği', 'Kahvaltı', 'Kafe', 'Tatlı', 'Restoran', 'Döner', 'Pizza', 'Burger'],
    'Market ve Atıştırmalık': ['Migros', 'A101', 'BİM', 'CarrefourSA', 'Şok market', 'Manav', 'Ekmek ve süt', 'Haftalık alışveriş'],
    'Araç ve Ulaşım': ['Benzin', 'Metrobüs', 'Metro kartı', 'Taksi', 'Otopark', 'Araç bakım', 'Sigorta', 'Servis'],
    'Sabit Giderler': ['Elektrik faturası', 'Su faturası', 'Doğalgaz', 'İnternet', 'Telefon faturası', 'Kira'],
    'Diğer': ['Eczane', 'Kitap', 'Kırtasiye', 'Spor salonu', 'Sinema', 'Abonelik', 'Berbere gittim'],
    'Hediye ve Özel': ['Doğum günü hediyesi', 'Düğün hediyesi', 'Özel alışveriş', 'Çiçek'],
  };

  static const _incomeNames = {
    'Maaş': ['Aylık maaş', 'Maaş', 'Bordro ödemesi'],
    'Serbest Çalışma': ['Freelance proje', 'Danışmanlık ücreti', 'Yazılım projesi', 'Tasarım işi'],
    'Kira Geliri': ['Daire kira geliri', 'Dükkan kira geliri'],
    'Diğer': ['Prim ödemesi', 'İkramiye', 'Satış geliri', 'Çeşitli gelir'],
  };

  // ===== ANA METOT =====

  /// Kullanıcı için 6 aylık gerçekçi sahte veri üretir ve Firebase'e yazar.
  /// Tüm veriler batch write ile atomik olarak eklenir.
  Future<void> generateMockData(String userId) async {
    debugPrint('[MockDataService] Sahte veri üretimi başlıyor...');

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
      bankId: 15000.0,   // Başlangıç bakiyesi
      creditId: 0.0,     // Kredi kartı borcu (negatif = borç)
      cashId: 2500.0,    // Nakit başlangıcı
    };

    for (int monthOffset = 5; monthOffset >= 0; monthOffset--) {
      final month = DateTime(now.year, now.month - monthOffset, 1);
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

      // Her ay için gelirler
      final monthlyIncomes = _generateMonthlyIncomes(month, daysInMonth, bankId, cashId);
      incomes.addAll(monthlyIncomes);

      // Gelirler bakiyeye eklenir
      for (final income in monthlyIncomes) {
        final pmId = income['paymentMethodId'] as String?;
        final amount = (income['amount'] as num).toDouble();
        if (pmId != null && balances.containsKey(pmId)) {
          balances[pmId] = balances[pmId]! + amount;
        }
      }

      // Her ay için harcamalar
      final monthlyExpenses = _generateMonthlyExpenses(
        month, daysInMonth, bankId, creditId, cashId,
      );
      expenses.addAll(monthlyExpenses);

      // Harcamalar bakiyeden düşülür
      for (final expense in monthlyExpenses) {
        final pmId = expense['odemeYontemiId'] as String?;
        final amount = (expense['tutar'] as num).toDouble();
        if (pmId != null && balances.containsKey(pmId)) {
          balances[pmId] = balances[pmId]! - amount;
        }
      }

      // Her ay için transferler (Bankadan nakite, Bankadan kredi kartı ödemesi vs.)
      final monthlyTransfers = _generateMonthlyTransfers(month, daysInMonth, bankId, creditId, cashId);
      transfers.addAll(monthlyTransfers);

      // Transferleri bakiyeye yansıt
      for (final transfer in monthlyTransfers) {
        final fromId = transfer['fromAccountId'] as String?;
        final toId = transfer['toAccountId'] as String?;
        final amount = (transfer['amount'] as num).toDouble();
        
        if (fromId != null && balances.containsKey(fromId)) {
          balances[fromId] = balances[fromId]! - amount;
        }
        if (toId != null && balances.containsKey(toId)) {
          balances[toId] = balances[toId]! + amount;
        }
      }
    }

    // 3. Bakiyeleri güncelle (tutarlı son bakiye)
    for (int i = 0; i < paymentMethods.length; i++) {
      final pmId = paymentMethods[i]['id'] as String;
      if (balances.containsKey(pmId)) {
        paymentMethods[i] = Map<String, dynamic>.from(paymentMethods[i])
          ..['balance'] = double.parse(balances[pmId]!.toStringAsFixed(2));
      }
    }

    // 4. Varlıklar
    final assets = _generateAssets(now);

    // 5. Firebase'e yaz (batch)
    await _writeTofirestore(userId, paymentMethods, expenses, incomes, assets, transfers);

    debugPrint('[MockDataService] Tamamlandı! '
        '${expenses.length} harcama, ${incomes.length} gelir, ${transfers.length} transfer, '
        '${assets.length} varlık, ${paymentMethods.length} ödeme yöntemi.');
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
    ];
  }

  List<Map<String, dynamic>> _generateMonthlyIncomes(
    DateTime month, int daysInMonth, String bankId, String cashId,
  ) {
    final incomes = <Map<String, dynamic>>[];

    // Maaş — her ay 3-5 arası günde
    final salaryDay = 3 + _random.nextInt(3);
    final salaryAmount = 18000 + (_random.nextInt(8) * 500).toDouble();
    incomes.add(_buildIncome(
      name: 'Aylık maaş',
      category: 'Maaş',
      amount: salaryAmount,
      date: DateTime(month.year, month.month, salaryDay),
      paymentMethodId: bankId,
    ));

    // Ek gelirler (% 40 ihtimal)
    if (_random.nextDouble() < 0.4) {
      final extraCategories = ['Serbest Çalışma', 'Diğer', 'Kira Geliri'];
      final cat = extraCategories[_random.nextInt(extraCategories.length)];
      final names = _incomeNames[cat]!;
      incomes.add(_buildIncome(
        name: names[_random.nextInt(names.length)],
        category: cat,
        amount: (2000 + _random.nextInt(15) * 500).toDouble(),
        date: DateTime(month.year, month.month, 10 + _random.nextInt(15)),
        paymentMethodId: _random.nextBool() ? bankId : cashId,
      ));
    }

    return incomes;
  }

  List<Map<String, dynamic>> _generateMonthlyTransfers(
      DateTime month, int daysInMonth, String bankId, String creditId, String cashId) {
    final transfers = <Map<String, dynamic>>[];
    
    // 1. Bankadan nakit çekimi (ATM) - ayda 2-3 kez
    int atmCekimSayisi = _random.nextInt(2) + 2;
    for (int i = 0; i < atmCekimSayisi; i++) {
      int day = _random.nextInt(daysInMonth) + 1;
      transfers.add({
        'id': 'mock_tr_${month.year}_${month.month}_atm_$i',
        'fromAccountId': bankId,
        'toAccountId': cashId,
        'amount': (500 + _random.nextInt(15) * 100).toDouble(), // 500 - 1900 arası
        'date': DateTime(month.year, month.month, day, _random.nextInt(10) + 9, _random.nextInt(60)).toIso8601String(),
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
      'amount': (2000 + _random.nextInt(30) * 100).toDouble(), // 2000 - 4900 arası ödeme
      'date': DateTime(month.year, month.month, day, _random.nextInt(5) + 10, _random.nextInt(60)).toIso8601String(),
      'description': 'Kredi Kartı Ödemesi',
      'paraBirimi': 'TRY',
      'isScheduled': false,
      'isExecuted': true,
      'isFailed': false,
    });

    return transfers;
  }

  List<Map<String, dynamic>> _generateMonthlyExpenses(
    DateTime month, int daysInMonth,
    String bankId, String creditId, String cashId,
  ) {
    final expenses = <Map<String, dynamic>>[];
    final paymentIds = [bankId, creditId, cashId];

    // Sabit aylık faturalar
    final fixedExpenses = [
      {'isim': 'Kira', 'tutar': 8500.0, 'gun': 1},
      {'isim': 'Elektrik faturası', 'tutar': 350.0 + _random.nextInt(100), 'gun': 5},
      {'isim': 'Su faturası', 'tutar': 80.0 + _random.nextInt(30), 'gun': 7},
      {'isim': 'İnternet', 'tutar': 299.0, 'gun': 10},
      {'isim': 'Telefon faturası', 'tutar': 450.0, 'gun': 12},
      {'isim': 'Doğalgaz', 'tutar': 200.0 + _random.nextInt(150), 'gun': 8},
    ];

    for (final fixed in fixedExpenses) {
      final day = (fixed['gun'] as int).clamp(1, daysInMonth);
      expenses.add(_buildExpense(
        isim: fixed['isim'] as String,
        kategori: 'Sabit Giderler',
        tutar: (fixed['tutar'] as num).toDouble(),
        date: DateTime(month.year, month.month, day),
        odemeYontemiId: bankId,
      ));
    }

    // Değişken günlük harcamalar (25-35 adet/ay)
    final expenseCount = 25 + _random.nextInt(11);
    for (int i = 0; i < expenseCount; i++) {
      final cat = _expenseCategories[_random.nextInt(_expenseCategories.length - 1)]; // 'Sabit Giderler' hariç
      if (cat == 'Sabit Giderler') continue;

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

      expenses.add(_buildExpense(
        isim: name,
        kategori: cat,
        tutar: amount,
        date: DateTime(month.year, month.month, day.clamp(1, daysInMonth)),
        odemeYontemiId: pmId,
      ));
    }

    return expenses;
  }

  List<Map<String, dynamic>> _generateAssets(DateTime now) {
    return [
      {
        'id': 'mock_asset_usd_001',
        'name': 'Dolar',
        'amount': 35200.0,
        'quantity': 1000.0,
        'category': 'Döviz',
        'type': 'USD',
        'lastUpdated': now.toIso8601String(),
        'purchaseDate': now.subtract(const Duration(days: 120)).toIso8601String(),
        'purchasePrice': 31000.0,
        'paraBirimi': 'TRY',
        'isDeleted': false,
      },
      {
        'id': 'mock_asset_gold_001',
        'name': 'Gram Altın',
        'amount': 42000.0,
        'quantity': 10.0,
        'category': 'Altın',
        'type': 'XAU',
        'lastUpdated': now.toIso8601String(),
        'purchaseDate': now.subtract(const Duration(days: 180)).toIso8601String(),
        'purchasePrice': 38000.0,
        'paraBirimi': 'TRY',
        'isDeleted': false,
      },
      {
        'id': 'mock_asset_btc_001',
        'name': 'Bitcoin',
        'amount': 45000.0,
        'quantity': 0.05,
        'category': 'Kripto',
        'type': 'BTC',
        'lastUpdated': now.toIso8601String(),
        'purchaseDate': now.subtract(const Duration(days: 90)).toIso8601String(),
        'purchasePrice': 38000.0,
        'paraBirimi': 'TRY',
        'isDeleted': false,
      },
    ];
  }

  // ===== YARDIMCI BUILDER'LAR =====

  Map<String, dynamic> _buildExpense({
    required String isim,
    required String kategori,
    required double tutar,
    required DateTime date,
    required String odemeYontemiId,
  }) {
    return {
      'id': 'mock_exp_${date.millisecondsSinceEpoch}_${_random.nextInt(99999)}',
      'isim': isim,
      'kategori': kategori,
      'tutar': tutar,
      'tarih': date.toIso8601String(),
      'paraBirimi': 'TRY',
      'odemeYontemiId': odemeYontemiId,
      'notlar': null,
    };
  }

  Map<String, dynamic> _buildIncome({
    required String name,
    required String category,
    required double amount,
    required DateTime date,
    required String paymentMethodId,
  }) {
    return {
      'id': 'mock_inc_${date.millisecondsSinceEpoch}_${_random.nextInt(99999)}',
      'name': name,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'paraBirimi': 'TRY',
      'paymentMethodId': paymentMethodId,
      'isDeleted': false,
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
  ) async {
    final userDoc = _firestore.collection('users').doc(userId);

    // Firestore batch limiti 500 — parçalara böl
    final allOps = <Future<void>>[];

    // Ödeme yöntemleri
    var batch = _firestore.batch();
    for (final pm in paymentMethods) {
      batch.set(userDoc.collection('paymentMethods').doc(pm['id']), pm);
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
      assetBatch.set(userDoc.collection('assets').doc(asset['id']), asset);
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
        'fixedExpenseTemplates': [
          {'id': 'mock_ft_1', 'isim': 'Kira', 'tutar': 8500.0, 'gun': 1, 'odemeYontemiId': 'mock_banka_001', 'kategori': 'Sabit Giderler'},
          {'id': 'mock_ft_2', 'isim': 'Elektrik faturası', 'tutar': 380.0, 'gun': 5, 'odemeYontemiId': 'mock_banka_001', 'kategori': 'Sabit Giderler'},
          {'id': 'mock_ft_3', 'isim': 'Su faturası', 'tutar': 95.0, 'gun': 7, 'odemeYontemiId': 'mock_banka_001', 'kategori': 'Sabit Giderler'},
          {'id': 'mock_ft_4', 'isim': 'Doğalgaz', 'tutar': 250.0, 'gun': 8, 'odemeYontemiId': 'mock_banka_001', 'kategori': 'Sabit Giderler'},
          {'id': 'mock_ft_5', 'isim': 'İnternet', 'tutar': 299.0, 'gun': 10, 'odemeYontemiId': 'mock_banka_001', 'kategori': 'Sabit Giderler'},
          {'id': 'mock_ft_6', 'isim': 'Telefon faturası', 'tutar': 450.0, 'gun': 12, 'odemeYontemiId': 'mock_kredi_001', 'kategori': 'Sabit Giderler'},
        ],
        'categoryBudgets': {
          'Yemek ve Kafe': 3000.0,
          'Market ve Atıştırmalık': 2500.0,
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

    await Future.wait(allOps);
  }

  /// Kullanıcıya ait tüm mock verileri temizler.
  Future<void> clearMockData(String userId) async {
    debugPrint('[MockDataService] Mock veriler temizleniyor...');
    final userDoc = _firestore.collection('users').doc(userId);

    // Koleksiyon dökümanları (mock_ prefix'li olanlar)
    final collections = ['expenses', 'incomes', 'paymentMethods', 'assets', 'transfers'];
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
    final generalDoc = await userDoc.collection('settings').doc('general').get();
    if (generalDoc.exists && generalDoc.data()?['mock_generated'] == true) {
      await userDoc.collection('settings').doc('general').update({
        'budget': FieldValue.delete(),
        'fixedExpenseTemplates': FieldValue.delete(),
        'categoryBudgets': FieldValue.delete(),
        'mock_generated': FieldValue.delete(),
      });
    }

    final incomeDoc = await userDoc.collection('settings').doc('income').get();
    if (incomeDoc.exists && incomeDoc.data()?['mock_generated'] == true) {
      await userDoc.collection('settings').doc('income').delete();
    }

    debugPrint('[MockDataService] Mock veriler temizlendi.');
  }
}

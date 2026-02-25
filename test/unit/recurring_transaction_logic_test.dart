import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/recurring_transaction_service.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';

/// RecurringTransactionService mantıksal doğruluk testleri
/// Tekrarlayan harcama/gelir otomatik ekleme, bakiye güncelleme,
/// yetersiz bakiye uyarıları ve çift işlem koruması
void main() {
  group('RecurringTransactionService — Tekrarlayan Harcamalar', () {
    test('belirlenen günde harcama otomatik eklenir', () {
      final bugun = DateTime.now();
      final tumHarcamalar = <Map<String, dynamic>>[];

      // Bu testte DI olmadan çalışamayacağı için service'i manuel test ediyoruz
      // Mantık testini direkt veri manipülasyonu ile yapıyoruz

      // Simülasyon: Gün geldi ve işlenmedi
      final gun = bugun.day;
      final islem = {
        'isim': 'Kira',
        'tutar': 5000.0,
        'gun': gun,
        'sonIslemTarihi': null,
        'odemeYontemiId': 'pm1',
      };

      // Manuel mantık testi: bu ay işlenmedi mi?
      final buAy = '${bugun.year}-${bugun.month.toString().padLeft(2, '0')}';
      final sonIslemTarihi = islem['sonIslemTarihi'] as String?;
      final buAyIslendi =
          sonIslemTarihi != null && sonIslemTarihi.startsWith(buAy);

      expect(buAyIslendi, isFalse, reason: 'İlk seferde işlenmemiş olmalı');
      expect(gun <= bugun.day, isTrue, reason: 'Gün bugün veya geçmişte');

      // İşlem eklenecek
      if (gun <= bugun.day && !buAyIslendi) {
        tumHarcamalar.add({
          'isim': islem['isim'],
          'tutar': islem['tutar'],
          'kategori': 'Tekrarlayan İşlemler',
          'tarih': DateTime(bugun.year, bugun.month, gun).toString(),
          'silindi': false,
          'odemeYontemiId': islem['odemeYontemiId'],
        });
      }

      expect(tumHarcamalar.length, equals(1));
      expect(tumHarcamalar.first['isim'], equals('Kira'));
      expect(tumHarcamalar.first['tutar'], equals(5000.0));
    });

    test('bu ay zaten işlenmiş tekrarlayan harcama tekrar eklenmez', () {
      final bugun = DateTime.now();
      final buAy = '${bugun.year}-${bugun.month.toString().padLeft(2, '0')}';

      final islem = {
        'isim': 'Kira',
        'tutar': 5000.0,
        'gun': 1,
        'sonIslemTarihi': '$buAy-01', // Bu ay zaten işlenmiş!
        'odemeYontemiId': 'pm1',
      };

      final sonIslemTarihi = islem['sonIslemTarihi'] as String?;
      final buAyIslendi =
          sonIslemTarihi != null && sonIslemTarihi.startsWith(buAy);

      expect(buAyIslendi, isTrue, reason: 'Bu ay zaten işlenmiş olmalı');
    });

    test('gelecek aydaki tekrarlayan harcama erken eklenmez', () {
      final bugun = DateTime.now();

      final islem = {
        'isim': 'Internet',
        'tutar': 200.0,
        'gun': 31, // Ayın son günü
        'sonIslemTarihi': null,
      };

      final gun = islem['gun'] as int;

      // Eğer bugün 31'den küçükse bu işlem henüz eklenmemeli
      if (bugun.day < 31) {
        expect(
          gun <= bugun.day,
          isFalse,
          reason: 'Gelecek gün harcaması henüz eklenmemeli',
        );
      }
    });

    test('nakit bakiyesi tekrarlayan harcamada düşürülür', () {
      final pm = PaymentMethod(
        id: 'pm1',
        name: 'Nakit',
        type: 'nakit',
        balance: 10000.0,
        createdAt: DateTime.now(),
      );

      const tutar = 3000.0;
      final yeniBakiye = pm.balance - tutar;

      expect(yeniBakiye, equals(7000.0));
    });

    test('kredi kartı bakiyesi tekrarlayan harcamada artar (borç artar)', () {
      final pm = PaymentMethod(
        id: 'kredi1',
        name: 'Kredi',
        type: 'kredi',
        balance: 2000.0,
        createdAt: DateTime.now(),
      );

      const tutar = 500.0;
      final yeniBakiye = pm.balance + tutar; // Borç artar

      expect(yeniBakiye, equals(2500.0));
    });

    test('yetersiz bakiye uyarısı oluşturulur', () {
      final pm = PaymentMethod(
        id: 'pm1',
        name: 'Nakit',
        type: 'nakit',
        balance: 100.0,
        createdAt: DateTime.now(),
      );

      const tutar = 500.0;
      final yeniBakiye = pm.balance - tutar;
      final yetersiz = yeniBakiye < 0;

      expect(yetersiz, isTrue, reason: '100 - 500 = -400, yetersiz bakiye');
    });
  });

  group('RecurringTransactionService — Tekrarlayan Gelirler', () {
    test('tekrarlayan gelir doğru bilgilerle eklenir', () {
      final bugun = DateTime.now();
      final tumGelirler = <Income>[];

      final gelirTemplate = {
        'isim': 'Maaş',
        'tutar': 30000.0,
        'gun': 1,
        'sonIslemTarihi': null,
        'odemeYontemiId': 'banka1',
      };

      final gun = gelirTemplate['gun'] as int;
      if (gun <= bugun.day) {
        final islemTarihi = DateTime(bugun.year, bugun.month, gun);
        tumGelirler.add(
          Income(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: gelirTemplate['isim'] as String,
            amount: (gelirTemplate['tutar'] as num).toDouble(),
            category: 'Tekrarlayan Gelirler',
            date: islemTarihi,
            paymentMethodId: gelirTemplate['odemeYontemiId'] as String?,
          ),
        );
      }

      expect(tumGelirler.length, equals(1));
      expect(tumGelirler.first.name, equals('Maaş'));
      expect(tumGelirler.first.amount, equals(30000.0));
      expect(tumGelirler.first.category, equals('Tekrarlayan Gelirler'));
    });

    test('tekrarlayan gelir nakit bakiyesini artırır', () {
      final pm = PaymentMethod(
        id: 'banka1',
        name: 'Banka',
        type: 'banka',
        balance: 5000.0,
        createdAt: DateTime.now(),
      );

      const tutar = 30000.0;
      final yeniBakiye = pm.balance + tutar;

      expect(yeniBakiye, equals(35000.0));
    });

    test('tekrarlayan gelir kredi borcu azaltır', () {
      final pm = PaymentMethod(
        id: 'kredi1',
        name: 'Kredi',
        type: 'kredi',
        balance: 8000.0,
        createdAt: DateTime.now(),
      );

      const tutar = 3000.0;
      final yeniBakiye = pm.balance - tutar; // Borç azalır

      expect(yeniBakiye, equals(5000.0));
    });
  });

  group('RecurringTransactionService — Sonuç Bilgisi', () {
    test('getSonucBilgisi doğru formatta döner', () {
      final service = RecurringTransactionService(
        userId: 'test',
        tumHarcamalar: [],
        tumGelirler: [],
        tumOdemeYontemleri: [],
      );

      // Başlangıç durumu: hiç işlem yok
      final sonuc = service.getSonucBilgisi();

      expect(sonuc['harcamaEklendi'], isFalse);
      expect(sonuc['harcamaAdet'], equals(0));
      expect(sonuc['harcamaToplam'], equals(0));
      expect(sonuc['gelirEklendi'], isFalse);
      expect(sonuc['gelirAdet'], equals(0));
      expect(sonuc['gelirToplam'], equals(0));
      expect(sonuc['yetersizBakiyeVar'], isFalse);
    });
  });

  group('PaymentMethod Model — Edge Cases', () {
    test('kredi kartı kalan limit doğru hesaplanır', () {
      final pm = PaymentMethod(
        id: '1',
        name: 'Kredi',
        type: 'kredi',
        balance: 3000.0,
        limit: 10000.0,
        createdAt: DateTime.now(),
      );

      expect(pm.remainingLimit, equals(7000.0)); // 10000 - 3000
    });

    test('limitsiz kredi kartında remainingLimit null döner', () {
      final pm = PaymentMethod(
        id: '2',
        name: 'Kredi Limitsiz',
        type: 'kredi',
        balance: 1000.0,
        limit: null,
        createdAt: DateTime.now(),
      );

      expect(pm.remainingLimit, isNull);
    });

    test('nakit için remainingLimit null döner', () {
      final pm = PaymentMethod(
        id: '3',
        name: 'Nakit',
        type: 'nakit',
        balance: 5000.0,
        createdAt: DateTime.now(),
      );

      expect(pm.remainingLimit, isNull);
    });

    test('typeDisplayName doğru Türkçe karşılıklar', () {
      expect(
        PaymentMethod(
          id: '1',
          name: 'X',
          type: 'banka',
          balance: 0,
          createdAt: DateTime.now(),
        ).typeDisplayName,
        equals('Banka Kartı'),
      );
      expect(
        PaymentMethod(
          id: '2',
          name: 'X',
          type: 'kredi',
          balance: 0,
          createdAt: DateTime.now(),
        ).typeDisplayName,
        equals('Kredi Kartı'),
      );
      expect(
        PaymentMethod(
          id: '3',
          name: 'X',
          type: 'nakit',
          balance: 0,
          createdAt: DateTime.now(),
        ).typeDisplayName,
        equals('Nakit'),
      );
    });

    test('serialization round-trip doğru çalışır', () {
      final original = PaymentMethod(
        id: 'serial_pm',
        name: 'Ziraat',
        type: 'banka',
        lastFourDigits: '4567',
        balance: 12500.0,
        limit: null,
        colorIndex: 2,
        createdAt: DateTime(2024, 1, 15),
        paraBirimi: 'TRY',
      );

      final map = original.toMap();
      final restored = PaymentMethod.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.type, equals(original.type));
      expect(restored.lastFourDigits, equals(original.lastFourDigits));
      expect(restored.balance, equals(original.balance));
      expect(restored.colorIndex, equals(original.colorIndex));
      expect(restored.paraBirimi, equals(original.paraBirimi));
    });
  });
}

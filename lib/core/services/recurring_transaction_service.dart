import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cashly/features/income/domain/repositories/income_repository.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:uuid/uuid.dart';

/// Tekrarlayan harcama ve gelir işlemlerini kontrol eden servis.
/// Her ay belirli günlerde otomatik olarak harcama/gelir ekler.
class RecurringTransactionService {
  final String userId;
  final List<Map<String, dynamic>> tumHarcamalar;
  final List<Income> tumGelirler;
  final List<PaymentMethod> tumOdemeYontemleri;

  /// Tekrarlayan işlem sonucu
  int eklenenHarcamaAdet = 0;
  double eklenenHarcamaToplam = 0;
  int eklenenGelirAdet = 0;
  double eklenenGelirToplam = 0;
  List<String> yetersizBakiyeUyarilari = [];

  RecurringTransactionService({
    required this.userId,
    required this.tumHarcamalar,
    required this.tumGelirler,
    required this.tumOdemeYontemleri,
  });

  /// Tekrarlayan harcama işlemlerini kontrol eder ve gerekirse ekler.
  /// [onPaymentMethodUpdate] callback'i ödeme yöntemi güncellendiğinde çağrılır.
  void tekrarlayanHarcamalariKontrolEt({
    required void Function(int index, PaymentMethod pm) onPaymentMethodUpdate,
  }) {
    final expenseRepo = getIt<ExpenseRepository>();
    List<Map<String, dynamic>> tekrarlayanIslemler = expenseRepo
        .getFixedExpenseTemplates(userId);

    if (tekrarlayanIslemler.isEmpty) return;

    final bugun = DateTime.now();
    final buguninGunu = bugun.day;
    final buAy = '${bugun.year}-${bugun.month.toString().padLeft(2, '0')}';

    for (var islem in tekrarlayanIslemler) {
      final gun = islem['gun'] ?? 1;
      final sonIslemTarihi = islem['sonIslemTarihi'] as String?;

      // Bu ay zaten işlendi mi kontrol et
      final buAyIslendi =
          sonIslemTarihi != null && sonIslemTarihi.startsWith(buAy);

      // Eğer belirlenen gün bugün veya geçmişte VE bu ay işlenmedi ise
      if (gun <= buguninGunu && !buAyIslendi) {
        final tutar = (islem['tutar'] as num?)?.toDouble() ?? 0;
        final isim = islem['isim'] ?? 'Tekrarlayan İşlem';
        final odemeYontemiId = islem['odemeYontemiId'] as String?;

        // Harcama ekle - tarih belirlenen güne göre ayarlanır
        final islemTarihi = DateTime(bugun.year, bugun.month, gun);
        final islemParaBirimi =
            islem['paraBirimi']?.toString() ??
            getIt<CurrencyService>().currentCurrency;
        final yeniHarcama = {
          'id': const Uuid().v4(),
          'isim': isim,
          'tutar': tutar,
          'kategori': 'Tekrarlayan İşlemler',
          'tarih': islemTarihi.toString(),
          'silindi': false,
          'odemeYontemiId': odemeYontemiId,
          'paraBirimi': islemParaBirimi,
        };
        tumHarcamalar.add(yeniHarcama);
        expenseRepo.addExpense(userId, yeniHarcama);

        // Ödeme yönteminden düş
        if (odemeYontemiId != null) {
          final pmIndex = tumOdemeYontemleri.indexWhere(
            (pm) => pm.id == odemeYontemiId,
          );
          if (pmIndex != -1) {
            final pm = tumOdemeYontemleri[pmIndex];

            final cur = getIt<CurrencyService>();
            final convertedAmount = cur.convert(
              tutar,
              islemParaBirimi,
              pm.paraBirimi,
            );

            double yeniBakiye;
            if (pm.type == 'kredi') {
              yeniBakiye = pm.balance + convertedAmount; // Borç artar
            } else {
              yeniBakiye = pm.balance - convertedAmount; // Bakiyeden düşer
              // Yetersiz bakiye kontrolü
              if (yeniBakiye < 0) {
                yetersizBakiyeUyarilari.add(
                  '${pm.name}: $isim için yetersiz bakiye',
                );
              }
            }
            onPaymentMethodUpdate(pmIndex, pm.copyWith(balance: yeniBakiye));
          }
        }

        // Son işlem tarihini güncelle
        islem['sonIslemTarihi'] = bugun.toIso8601String().substring(0, 10);

        eklenenHarcamaAdet++;
        eklenenHarcamaToplam += tutar;
      }
    }

    if (eklenenHarcamaAdet > 0) {
      // Verileri kaydet
      for (var _ in tekrarlayanIslemler) {
        // Sablonlari guncelle (son islem tarihi degisti)
        // Sabit giderleri ayrica guncelleyen metod kullanilmali
      }
      getIt<ExpenseRepository>().saveFixedExpenseTemplates(
        userId,
        tekrarlayanIslemler,
      );
    }
  }

  /// Tekrarlayan gelir işlemlerini kontrol eder ve gerekirse ekler.
  /// [onPaymentMethodUpdate] callback'i ödeme yöntemi güncellendiğinde çağrılır.
  void tekrarlayanGelirleriKontrolEt({
    required void Function(int index, PaymentMethod pm) onPaymentMethodUpdate,
  }) {
    final incomeRepo = getIt<IncomeRepository>();
    List<Map<String, dynamic>> tekrarlayanGelirler = incomeRepo
        .getRecurringIncomes(userId);

    if (tekrarlayanGelirler.isEmpty) return;

    final bugun = DateTime.now();
    final buguninGunu = bugun.day;
    final buAy = '${bugun.year}-${bugun.month.toString().padLeft(2, '0')}';

    for (var gelir in tekrarlayanGelirler) {
      final gun = gelir['gun'] ?? 1;
      final sonIslemTarihi = gelir['sonIslemTarihi'] as String?;

      // Bu ay zaten işlendi mi kontrol et
      final buAyIslendi =
          sonIslemTarihi != null && sonIslemTarihi.startsWith(buAy);

      // Eğer belirlenen gün bugün veya geçmişte VE bu ay işlenmedi ise
      if (gun <= buguninGunu && !buAyIslendi) {
        final tutar = (gelir['tutar'] as num?)?.toDouble() ?? 0;
        final isim = gelir['isim'] ?? 'Tekrarlayan Gelir';
        final odemeYontemiId = gelir['odemeYontemiId'] as String?;

        // Gelir ekle - tarih belirlenen güne göre ayarlanır
        final islemTarihi = DateTime(bugun.year, bugun.month, gun);
        final gelirParaBirimi =
            gelir['paraBirimi']?.toString() ??
            getIt<CurrencyService>().currentCurrency;
        final yeniGelir = Income(
          id: const Uuid().v4(),
          name: isim,
          amount: tutar,
          category: 'Tekrarlayan Gelirler',
          date: islemTarihi,
          paymentMethodId: odemeYontemiId,
          paraBirimi: gelirParaBirimi,
        );
        tumGelirler.add(yeniGelir);
        incomeRepo.addIncome(userId, yeniGelir.toMap());

        // Ödeme yöntemine ekle (bakiye artar)
        if (odemeYontemiId != null) {
          final pmIndex = tumOdemeYontemleri.indexWhere(
            (pm) => pm.id == odemeYontemiId,
          );
          if (pmIndex != -1) {
            final pm = tumOdemeYontemleri[pmIndex];

            final cur = getIt<CurrencyService>();
            final convertedAmount = cur.convert(
              tutar,
              gelirParaBirimi,
              pm.paraBirimi,
            );

            double yeniBakiye;
            if (pm.type == 'kredi') {
              yeniBakiye = pm.balance - convertedAmount; // Borç azalır
            } else {
              yeniBakiye = pm.balance + convertedAmount; // Bakiye artar
            }
            onPaymentMethodUpdate(pmIndex, pm.copyWith(balance: yeniBakiye));
          }
        }

        // Son işlem tarihini güncelle
        gelir['sonIslemTarihi'] = bugun.toIso8601String().substring(0, 10);

        eklenenGelirAdet++;
        eklenenGelirToplam += tutar;
      }
    }

    if (eklenenGelirAdet > 0) {
      // Gelirleri kaydet
      final incomeRepo = getIt<IncomeRepository>();
      incomeRepo.saveRecurringIncomes(userId, tekrarlayanGelirler);
    }
  }

  /// İşlem sonucunun bildirim mesajlarını oluşturur
  Map<String, dynamic> getSonucBilgisi() {
    return {
      'harcamaEklendi': eklenenHarcamaAdet > 0,
      'harcamaAdet': eklenenHarcamaAdet,
      'harcamaToplam': eklenenHarcamaToplam,
      'gelirEklendi': eklenenGelirAdet > 0,
      'gelirAdet': eklenenGelirAdet,
      'gelirToplam': eklenenGelirToplam,
      'yetersizBakiyeVar': yetersizBakiyeUyarilari.isNotEmpty,
      'yetersizBakiyeAdet': yetersizBakiyeUyarilari.length,
    };
  }
}

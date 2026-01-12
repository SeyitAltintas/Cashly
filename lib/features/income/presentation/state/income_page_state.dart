import 'package:flutter/foundation.dart';
import '../../data/models/income_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Gelirler sayfası state yöneticisi
class IncomePageState extends ChangeNotifier {
  // Veri listeleri (referanslar - dışarıdan set edilir)
  List<Income> tumGelirler = [];
  List<PaymentMethod> tumOdemeYontemleri = [];

  // Arama modu state'i
  bool _aramaModu = false;
  bool get aramaModu => _aramaModu;
  set aramaModu(bool value) {
    if (_aramaModu != value) {
      _aramaModu = value;
      notifyListeners();
    }
  }

  // Loading state'i
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Seçilen ay state'i
  DateTime _secilenAy = DateTime.now();
  DateTime get secilenAy => _secilenAy;
  set secilenAy(DateTime value) {
    if (_secilenAy != value) {
      _secilenAy = value;
      notifyListeners();
    }
  }

  /// Gelir ekle
  void addIncome(Income gelir) {
    tumGelirler.add(gelir);
    notifyListeners();
  }

  /// Geliri sil (soft delete)
  void deleteIncome(Income income, {PaymentMethod? pm, int? pmIndex}) {
    income.isDeleted = true;
    // Bakiyeyi geri al
    if (pm != null && pmIndex != null && pmIndex != -1) {
      double yeniBakiye;
      if (pm.type == 'kredi') {
        yeniBakiye = pm.balance + income.amount;
      } else {
        yeniBakiye = pm.balance - income.amount;
      }
      tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: yeniBakiye);
    }
    notifyListeners();
  }

  /// Silme işlemini geri al
  void undoDelete(
    Income income, {
    bool? wasDeleted,
    PaymentMethod? pm,
    int? pmIndex,
    double? oldBalance,
  }) {
    income.isDeleted = wasDeleted ?? false;
    if (pm != null && pmIndex != null && pmIndex != -1 && oldBalance != null) {
      tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: oldBalance);
    }
    notifyListeners();
  }

  /// Geliri güncelle (düzenleme)
  void updateIncome({
    required Income income,
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
  }) {
    // 1. Eski bakiyeyi geri al
    if (income.paymentMethodId != null) {
      final eskiPmIndex = tumOdemeYontemleri.indexWhere(
        (p) => p.id == income.paymentMethodId,
      );
      if (eskiPmIndex != -1) {
        final pm = tumOdemeYontemleri[eskiPmIndex];
        double yeniBakiye;
        if (pm.type == 'kredi') {
          yeniBakiye = pm.balance + income.amount;
        } else {
          yeniBakiye = pm.balance - income.amount;
        }
        tumOdemeYontemleri[eskiPmIndex] = pm.copyWith(balance: yeniBakiye);
      }
    }

    // 2. Yeni bakiyeyi ekle
    if (paymentMethodId != null) {
      final yeniPmIndex = tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (yeniPmIndex != -1) {
        final pm = tumOdemeYontemleri[yeniPmIndex];
        double yeniBakiye;
        if (pm.type == 'kredi') {
          yeniBakiye = pm.balance - amount;
        } else {
          yeniBakiye = pm.balance + amount;
        }
        tumOdemeYontemleri[yeniPmIndex] = pm.copyWith(balance: yeniBakiye);
      }
    }

    // 3. Geliri güncelle
    int index = tumGelirler.indexOf(income);
    if (index != -1) {
      tumGelirler[index] = Income(
        id: income.id,
        name: name,
        amount: amount,
        category: category,
        date: date,
        paymentMethodId: paymentMethodId,
        isDeleted: false,
      );
    }
    notifyListeners();
  }

  /// Yeni gelir ekle (seçili ödeme yöntemi ile)
  void addIncomeWithPayment({
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
  }) {
    tumGelirler.insert(
      0,
      Income(
        id: DateTime.now().toString(),
        name: name,
        amount: amount,
        category: category,
        date: date,
        paymentMethodId: paymentMethodId,
      ),
    );

    // Bakiyeyi güncelle
    if (paymentMethodId != null) {
      final pmIndex = tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        final pm = tumOdemeYontemleri[pmIndex];
        double yeniBakiye;
        if (pm.type == 'kredi') {
          yeniBakiye = pm.balance - amount;
        } else {
          yeniBakiye = pm.balance + amount;
        }
        tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: yeniBakiye);
      }
    }
    notifyListeners();
  }

  /// Önceki aya git
  void oncekiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month - 1);
    notifyListeners();
  }

  /// Sonraki aya git
  void sonrakiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month + 1);
    notifyListeners();
  }

  /// Arama modunu toggle et
  void toggleAramaModu() {
    _aramaModu = !_aramaModu;
    notifyListeners();
  }

  /// Loading durumunu kapat
  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }
}

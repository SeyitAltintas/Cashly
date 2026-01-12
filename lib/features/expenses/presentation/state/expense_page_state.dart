import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Harcamalar sayfası state yöneticisi
/// ChangeNotifier kullanarak granular rebuild sağlar
/// Bu yaklaşım setState'e göre daha performanslı çünkü
/// sadece ilgili ValueListenableBuilder'lar rebuild olur
class ExpensePageState extends ChangeNotifier {
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

  // Gösterilen harcamalar listesi
  List<Map<String, dynamic>> _gosterilenHarcamalar = [];
  List<Map<String, dynamic>> get gosterilenHarcamalar => _gosterilenHarcamalar;
  set gosterilenHarcamalar(List<Map<String, dynamic>> value) {
    _gosterilenHarcamalar = value;
    notifyListeners();
  }

  // Aylık toplam (hesaplanmış değer)
  double get toplamTutar {
    double toplam = 0;
    for (var h in _gosterilenHarcamalar) {
      toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
    }
    return toplam;
  }

  /// Harcamaları filtrele ve sırala
  void filtreleVeGoster({
    required List<Map<String, dynamic>> tumHarcamalar,
    required String aramaMetni,
    Function(int)? onResetLazyLoading,
  }) {
    final filteredList = tumHarcamalar.where((h) {
      if (h['silindi'] == true) return false;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih == null) return false;
      bool ayFiltrelendi =
          tarih.year == _secilenAy.year && tarih.month == _secilenAy.month;
      if (!ayFiltrelendi) return false;
      if (aramaMetni.isEmpty) return true;
      String isim = (h['isim'] ?? "").toString().toLowerCase();
      String kategori = (h['kategori'] ?? "").toString().toLowerCase();
      return isim.contains(aramaMetni.toLowerCase()) ||
          kategori.contains(aramaMetni.toLowerCase());
    }).toList();

    filteredList.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    _gosterilenHarcamalar = filteredList;
    onResetLazyLoading?.call(filteredList.length);
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

  /// Harcamayı sil (çöp kutusuna taşı)
  void harcamaSil({
    required Map<String, dynamic> harcama,
    required List<Map<String, dynamic>> tumHarcamalar,
    required List<dynamic> tumOdemeYontemleri,
    String? aramaMetni,
    Function(int)? onResetLazyLoading,
  }) {
    harcama['silindi'] = true;

    // Ödeme yönteminin bakiyesini geri ekle
    final paymentMethodId = harcama['odemeYontemiId'];
    if (paymentMethodId != null) {
      final pmIndex = tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        final pm = tumOdemeYontemleri[pmIndex];
        final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
        double newBalance;
        if (pm.type == 'kredi') {
          newBalance = pm.balance - amount;
        } else {
          newBalance = pm.balance + amount;
        }
        tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
      }
    }

    filtreleVeGoster(
      tumHarcamalar: tumHarcamalar,
      aramaMetni: aramaMetni ?? '',
      onResetLazyLoading: onResetLazyLoading,
    );
  }

  /// Harcama silme işlemini geri al
  void harcamaSilmeGeriAl({
    required Map<String, dynamic> harcama,
    required List<Map<String, dynamic>> tumHarcamalar,
    required List<dynamic> tumOdemeYontemleri,
    bool? eskiSilindi,
    double? eskiBakiye,
    int? pmIndex,
    String? aramaMetni,
    Function(int)? onResetLazyLoading,
  }) {
    harcama['silindi'] = eskiSilindi ?? false;
    if (pmIndex != null && pmIndex != -1 && eskiBakiye != null) {
      tumOdemeYontemleri[pmIndex] = tumOdemeYontemleri[pmIndex].copyWith(
        balance: eskiBakiye,
      );
    }
    filtreleVeGoster(
      tumHarcamalar: tumHarcamalar,
      aramaMetni: aramaMetni ?? '',
      onResetLazyLoading: onResetLazyLoading,
    );
  }
}

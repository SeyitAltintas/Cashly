import 'package:flutter/foundation.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../payment_methods/domain/repositories/payment_method_repository.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Harcamalar Controller
/// Repository ile entegre, ChangeNotifier tabanlı state yönetimi sağlar.
/// Bu controller ExpensePageState'in yerini alır.
class ExpensesController extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final PaymentMethodRepository _paymentMethodRepository;
  final String userId;

  ExpensesController({
    required ExpenseRepository expenseRepository,
    required PaymentMethodRepository paymentMethodRepository,
    required this.userId,
  }) : _expenseRepository = expenseRepository,
       _paymentMethodRepository = paymentMethodRepository;

  // ===== STATE =====

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

  // Tüm harcamalar listesi (repository'den yüklenir)
  List<Map<String, dynamic>> _tumHarcamalar = [];
  List<Map<String, dynamic>> get tumHarcamalar => _tumHarcamalar;

  // Gösterilen (filtrelenmiş) harcamalar listesi
  List<Map<String, dynamic>> _gosterilenHarcamalar = [];
  List<Map<String, dynamic>> get gosterilenHarcamalar => _gosterilenHarcamalar;

  // Kategoriler
  List<Map<String, dynamic>> _kategoriler = [];
  List<Map<String, dynamic>> get kategoriler => _kategoriler;

  // Ödeme yöntemleri (referans)
  List<PaymentMethod> _tumOdemeYontemleri = [];
  List<PaymentMethod> get tumOdemeYontemleri => _tumOdemeYontemleri;

  // Aylık toplam (hesaplanmış değer)
  double get toplamTutar {
    double toplam = 0;
    for (var h in _gosterilenHarcamalar) {
      toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
    }
    return toplam;
  }

  // ===== REPOSITORY İŞLEMLERİ =====

  /// Tüm verileri yükle (repository'den)
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Harcamaları yükle
      _tumHarcamalar = _expenseRepository.getExpenses(userId);

      // Kategorileri yükle
      _kategoriler = _expenseRepository.getCategories(userId);

      // Ödeme yöntemlerini yükle
      final pmData = _paymentMethodRepository.getPaymentMethods(userId);
      _tumOdemeYontemleri = pmData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();

      // Filtrele ve göster
      filtreleVeGoster();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Harcamaları kaydet
  Future<void> saveExpenses() async {
    await _expenseRepository.saveExpenses(userId, _tumHarcamalar);
  }

  /// Ödeme yöntemlerini kaydet
  Future<void> savePaymentMethods() async {
    final pmData = _tumOdemeYontemleri.map((pm) => pm.toMap()).toList();
    await _paymentMethodRepository.savePaymentMethods(userId, pmData);
  }

  // ===== FİLTRELEME =====

  /// Harcamaları filtrele ve sırala
  void filtreleVeGoster({
    String aramaMetni = '',
    Function(int)? onResetLazyLoading,
  }) {
    final filteredList = _tumHarcamalar.where((h) {
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

  // ===== AY GEÇİŞLERİ =====

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

  // ===== GERİYE DÖNÜK UYUMLULUK =====
  // Bu metodlar mevcut sayfa yapısıyla uyumluluk için widget prop'larını kabul eder

  /// Widget prop'larıyla filtrele (geriye dönük uyumluluk)
  void filtreleVeGosterLegacy({
    required List<Map<String, dynamic>> tumHarcamalar,
    String aramaMetni = '',
    Function(int)? onResetLazyLoading,
  }) {
    _tumHarcamalar = tumHarcamalar;
    filtreleVeGoster(
      aramaMetni: aramaMetni,
      onResetLazyLoading: onResetLazyLoading,
    );
  }

  /// Widget prop'larıyla harcama sil (geriye dönük uyumluluk)
  void harcamaSilLegacy({
    required Map<String, dynamic> harcama,
    required List<Map<String, dynamic>> tumHarcamalar,
    required List<dynamic> tumOdemeYontemleri,
    String? aramaMetni,
    Function(int)? onResetLazyLoading,
  }) {
    _tumHarcamalar = tumHarcamalar;
    _syncPaymentMethodsFromDynamic(tumOdemeYontemleri);

    harcama['silindi'] = true;

    final paymentMethodId = harcama['odemeYontemiId'];
    if (paymentMethodId != null) {
      final pmIndex = _tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        final pm = _tumOdemeYontemleri[pmIndex];
        final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
        double newBalance;
        if (pm.type == 'kredi') {
          newBalance = pm.balance - amount;
        } else {
          newBalance = pm.balance + amount;
        }
        _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
        tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex];
      }
    }

    filtreleVeGoster(
      aramaMetni: aramaMetni ?? '',
      onResetLazyLoading: onResetLazyLoading,
    );
  }

  /// Widget prop'larıyla silme geri al (geriye dönük uyumluluk)
  void harcamaSilmeGeriAlLegacy({
    required Map<String, dynamic> harcama,
    required List<Map<String, dynamic>> tumHarcamalar,
    required List<dynamic> tumOdemeYontemleri,
    bool? eskiSilindi,
    double? eskiBakiye,
    int? pmIndex,
    String? aramaMetni,
    Function(int)? onResetLazyLoading,
  }) {
    _tumHarcamalar = tumHarcamalar;
    _syncPaymentMethodsFromDynamic(tumOdemeYontemleri);

    harcama['silindi'] = eskiSilindi ?? false;
    if (pmIndex != null && pmIndex != -1 && eskiBakiye != null) {
      _tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex].copyWith(
        balance: eskiBakiye,
      );
      tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex];
    }
    filtreleVeGoster(
      aramaMetni: aramaMetni ?? '',
      onResetLazyLoading: onResetLazyLoading,
    );
  }

  /// Widget prop'larıyla harcama ekle/düzenle (geriye dönük uyumluluk)
  void harcamaEkleVeyaDuzenleLegacy({
    required List<Map<String, dynamic>> tumHarcamalar,
    required List<dynamic> tumOdemeYontemleri,
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
    Map<String, dynamic>? duzenlenecekHarcama,
    String? eskiOdemeYontemiId,
    double? eskiTutar,
    String? aramaMetni,
    Function(int)? onResetLazyLoading,
  }) {
    _tumHarcamalar = tumHarcamalar;
    _syncPaymentMethodsFromDynamic(tumOdemeYontemleri);

    void updateBalance(String? pmId, double amountChange) {
      if (pmId == null) return;
      final pmIdx = _tumOdemeYontemleri.indexWhere((p) => p.id == pmId);
      if (pmIdx == -1) return;

      final pm = _tumOdemeYontemleri[pmIdx];
      double newBalance;
      if (pm.type == 'kredi') {
        newBalance = pm.balance + amountChange;
      } else {
        newBalance = pm.balance - amountChange;
      }
      _tumOdemeYontemleri[pmIdx] = pm.copyWith(balance: newBalance);
      tumOdemeYontemleri[pmIdx] = _tumOdemeYontemleri[pmIdx];
    }

    if (duzenlenecekHarcama != null) {
      if (eskiOdemeYontemiId != null) {
        updateBalance(eskiOdemeYontemiId, -(eskiTutar ?? 0));
      }
      if (paymentMethodId != null) {
        updateBalance(paymentMethodId, amount);
      }

      int index = _tumHarcamalar.indexOf(duzenlenecekHarcama);
      if (index != -1) {
        _tumHarcamalar[index] = {
          "isim": name,
          "tutar": amount,
          "kategori": category,
          "tarih": date.toString(),
          "silindi": false,
          "odemeYontemiId": paymentMethodId,
        };
      }
    } else {
      if (paymentMethodId != null) {
        updateBalance(paymentMethodId, amount);
      }

      _tumHarcamalar.add({
        "isim": name,
        "tutar": amount,
        "kategori": category,
        "tarih": date.toString(),
        "silindi": false,
        "odemeYontemiId": paymentMethodId,
      });
    }

    _tumHarcamalar.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    filtreleVeGoster(
      aramaMetni: aramaMetni ?? '',
      onResetLazyLoading: onResetLazyLoading,
    );
  }

  /// Dynamic listeden PaymentMethod'lara sync et
  void _syncPaymentMethodsFromDynamic(List<dynamic> list) {
    _tumOdemeYontemleri = list.map((item) {
      if (item is PaymentMethod) return item;
      return PaymentMethod.fromMap(item as Map<String, dynamic>);
    }).toList();
  }

  // ===== CRUD İŞLEMLERİ =====

  /// Harcamayı sil (çöp kutusuna taşı)
  Future<void> harcamaSil({
    required Map<String, dynamic> harcama,
    String aramaMetni = '',
    Function(int)? onResetLazyLoading,
  }) async {
    harcama['silindi'] = true;

    // Ödeme yönteminin bakiyesini geri ekle
    final paymentMethodId = harcama['odemeYontemiId'];
    if (paymentMethodId != null) {
      final pmIndex = _tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        final pm = _tumOdemeYontemleri[pmIndex];
        final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
        double newBalance;
        if (pm.type == 'kredi') {
          newBalance = pm.balance - amount;
        } else {
          newBalance = pm.balance + amount;
        }
        _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
      }
    }

    // Kaydet ve filtrele
    await saveExpenses();
    await savePaymentMethods();
    filtreleVeGoster(
      aramaMetni: aramaMetni,
      onResetLazyLoading: onResetLazyLoading,
    );
  }

  /// Harcama silme işlemini geri al
  Future<void> harcamaSilmeGeriAl({
    required Map<String, dynamic> harcama,
    bool? eskiSilindi,
    double? eskiBakiye,
    int? pmIndex,
    String aramaMetni = '',
    Function(int)? onResetLazyLoading,
  }) async {
    harcama['silindi'] = eskiSilindi ?? false;
    if (pmIndex != null && pmIndex != -1 && eskiBakiye != null) {
      _tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex].copyWith(
        balance: eskiBakiye,
      );
    }

    await saveExpenses();
    await savePaymentMethods();
    filtreleVeGoster(
      aramaMetni: aramaMetni,
      onResetLazyLoading: onResetLazyLoading,
    );
  }

  /// Harcama ekle veya düzenle
  Future<void> harcamaEkleVeyaDuzenle({
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
    Map<String, dynamic>? duzenlenecekHarcama,
    String? eskiOdemeYontemiId,
    double? eskiTutar,
    String aramaMetni = '',
    Function(int)? onResetLazyLoading,
  }) async {
    void updateBalance(String? pmId, double amountChange) {
      if (pmId == null) return;
      final pmIdx = _tumOdemeYontemleri.indexWhere((p) => p.id == pmId);
      if (pmIdx == -1) return;

      final pm = _tumOdemeYontemleri[pmIdx];
      double newBalance;
      if (pm.type == 'kredi') {
        newBalance = pm.balance + amountChange;
      } else {
        newBalance = pm.balance - amountChange;
      }
      _tumOdemeYontemleri[pmIdx] = pm.copyWith(balance: newBalance);
    }

    if (duzenlenecekHarcama != null) {
      if (eskiOdemeYontemiId != null) {
        updateBalance(eskiOdemeYontemiId, -(eskiTutar ?? 0));
      }
      if (paymentMethodId != null) {
        updateBalance(paymentMethodId, amount);
      }

      int index = _tumHarcamalar.indexOf(duzenlenecekHarcama);
      if (index != -1) {
        _tumHarcamalar[index] = {
          "isim": name,
          "tutar": amount,
          "kategori": category,
          "tarih": date.toString(),
          "silindi": false,
          "odemeYontemiId": paymentMethodId,
        };
      }
    } else {
      if (paymentMethodId != null) {
        updateBalance(paymentMethodId, amount);
      }

      _tumHarcamalar.add({
        "isim": name,
        "tutar": amount,
        "kategori": category,
        "tarih": date.toString(),
        "silindi": false,
        "odemeYontemiId": paymentMethodId,
      });
    }

    _tumHarcamalar.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    await saveExpenses();
    await savePaymentMethods();
    filtreleVeGoster(
      aramaMetni: aramaMetni,
      onResetLazyLoading: onResetLazyLoading,
    );
  }

  /// Ödeme yöntemlerini dışarıdan set et (başka controller'dan sync için)
  void setPaymentMethods(List<PaymentMethod> methods) {
    _tumOdemeYontemleri = methods;
    notifyListeners();
  }

  /// State'i yenile (UI rebuild için)
  void refresh() {
    notifyListeners();
  }
}

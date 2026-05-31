import 'mixins/expense_form_mixin.dart';
import 'mixins/expense_voice_mixin.dart';
import 'mixins/expense_category_mgmt_mixin.dart';
import 'mixins/expense_bin_mixin.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/speech/speech_service.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../payment_methods/domain/repositories/payment_method_repository.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/services/batch_service.dart';

/// Harcamalar Controller
/// Repository ile entegre, ChangeNotifier tabanlı state yönetimi sağlar.
/// Bu controller ExpensePageState'in yerini alır.
class ExpensesController extends ChangeNotifier with ExpenseFormMixin, ExpenseVoiceMixin, ExpenseCategoryMgmtMixin, ExpenseBinMixin {
  final ExpenseRepository _expenseRepository;
  final PaymentMethodRepository _paymentMethodRepository;
  final String userId;

  ExpensesController({
    required ExpenseRepository expenseRepository,
    required PaymentMethodRepository paymentMethodRepository,
    required this.userId,
  }) : _expenseRepository = expenseRepository,
       _paymentMethodRepository = paymentMethodRepository;

  StreamSubscription? _expensesSubscription;

  // ===== STATE =====


  @override
  ExpenseRepository get expenseRepository => _expenseRepository;
  
  @override
  Future<void> savePaymentMethodsInternal() => savePaymentMethods();


  // ===== ANA STATE =====

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
    // Gün/saat farkını görmezden gel — sadece yıl ve ay karşılaştır
    final isSameMonth =
        _secilenAy.year == value.year && _secilenAy.month == value.month;
    _secilenAy = DateTime(value.year, value.month);
    if (!isSameMonth) {
      _startExpensesStream();
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
    final cur = getIt<CurrencyService>();
    double toplam = 0;
    for (var h in _gosterilenHarcamalar) {
      final t = (h['tutar'] as num?)?.toDouble() ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      toplam += cur.convert(t, pb, cur.currentCurrency);
    }
    return toplam;
  }

  // ===== INIT VE DISPOSE =====

  void _startExpensesStream() {
    _expensesSubscription?.cancel();
    _expensesSubscription = _expenseRepository
        .watchExpensesByMonth(userId, _secilenAy)
        .listen((data) {
          _tumHarcamalar = data;
          filtreleVeGoster();
        });
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    super.dispose();
  }

  // ===== REPOSITORY İŞLEMLERİ =====

  /// Tüm verileri yükle (repository'den)
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Harcamaları stream ile yönetiyoruz
      _startExpensesStream();

      // Kategorileri yükle
      _kategoriler = _expenseRepository.getCategories(userId);

      // Ödeme yöntemlerini yükle
      final pmData = _paymentMethodRepository.getPaymentMethods(userId);
      _tumOdemeYontemleri = pmData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();

      // Filtrele ve göster
      filtreleVeGoster();
    } catch (e, s) {
      ErrorHandler.logError('ExpensesController.loadData', e, s);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Harcamaları kaydet
  Future<void> saveExpenses() async {
    // Deprecated: Handled by individual CRUD operations
  }

  /// Ödeme yöntemlerini kaydet
  Future<void> savePaymentMethods() async {
    for (var pm in _tumOdemeYontemleri) {
      await _paymentMethodRepository.updatePaymentMethod(userId, pm.toMap());
    }
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
    _startExpensesStream();
    notifyListeners();
  }

  /// Sonraki aya git
  void sonrakiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month + 1);
    _startExpensesStream();
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
  Future<void> harcamaSilLegacy({
    required Map<String, dynamic> harcama,
    required List<Map<String, dynamic>> tumHarcamalar,
    required List<dynamic> tumOdemeYontemleri,
    String? aramaMetni,
    Function(int)? onResetLazyLoading,
  }) async {
    try {
      _tumHarcamalar = List.from(tumHarcamalar);
      _syncPaymentMethodsFromDynamic(tumOdemeYontemleri);

      // Eski değerleri kopyala (Rollback için)
      final bool oldSilindi = harcama['silindi'] ?? false;
      final oldPaymentMethods = List<PaymentMethod>.from(
        _tumOdemeYontemleri.map((e) => e.copyWith()),
      );

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

      // Anında arayüzü güncelle (Optimistic UI update)
      filtreleVeGoster(
        aramaMetni: aramaMetni ?? '',
        onResetLazyLoading: onResetLazyLoading,
      );

      // Arka planda Firestore işlemlerini yap
      Future.microtask(() async {
        try {
          // Veritabanını arkaplanda güncelle
          await _expenseRepository.updateExpense(
            userId,
            harcama,
          ); // Soft delete
          await savePaymentMethods();
        } catch (e, s) {
          // Hata durumunda işlemi geri al (Rollback)
          ErrorHandler.logError(
            'ExpensesController.harcamaSilLegacy Background',
            e,
            s,
          );
          harcama['silindi'] = oldSilindi;
          _tumOdemeYontemleri = oldPaymentMethods;
          for (int i = 0; i < tumOdemeYontemleri.length; i++) {
            if (i < _tumOdemeYontemleri.length) {
              tumOdemeYontemleri[i] = _tumOdemeYontemleri[i];
            }
          }
          filtreleVeGoster(
            aramaMetni: aramaMetni ?? '',
            onResetLazyLoading: onResetLazyLoading,
          );
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('ExpensesController.harcamaSilLegacy', e, s);
      rethrow;
    }
  }

  /// Widget prop'larıyla silme geri al (geriye dönük uyumluluk)
  Future<void> harcamaSilmeGeriAlLegacy({
    required Map<String, dynamic> harcama,
    required List<Map<String, dynamic>> tumHarcamalar,
    required List<dynamic> tumOdemeYontemleri,
    bool? eskiSilindi,
    double? eskiBakiye,
    int? pmIndex,
    String? aramaMetni,
    Function(int)? onResetLazyLoading,
  }) async {
    try {
      _tumHarcamalar = List.from(tumHarcamalar);
      _syncPaymentMethodsFromDynamic(tumOdemeYontemleri);

      // Eski değerleri kopyala (Rollback için)
      final bool oldSilindi = harcama['silindi'] ?? false;
      final oldPaymentMethods = List<PaymentMethod>.from(
        _tumOdemeYontemleri.map((e) => e.copyWith()),
      );

      harcama['silindi'] = eskiSilindi ?? false;
      if (pmIndex != null && pmIndex != -1 && eskiBakiye != null) {
        _tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex].copyWith(
          balance: eskiBakiye,
        );
        tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex];
      }

      // Anında arayüzü güncelle (Optimistic UI update)
      filtreleVeGoster(
        aramaMetni: aramaMetni ?? '',
        onResetLazyLoading: onResetLazyLoading,
      );

      // Arka planda Firestore işlemlerini yap
      Future.microtask(() async {
        try {
          await _expenseRepository.updateExpense(userId, harcama); // Restore
          await savePaymentMethods();
        } catch (e, s) {
          // Hata durumunda işlemi geri al (Rollback)
          ErrorHandler.logError(
            'ExpensesController.harcamaSilmeGeriAlLegacy Background',
            e,
            s,
          );
          harcama['silindi'] = oldSilindi;
          _tumOdemeYontemleri = oldPaymentMethods;
          for (int i = 0; i < tumOdemeYontemleri.length; i++) {
            if (i < _tumOdemeYontemleri.length) {
              tumOdemeYontemleri[i] = _tumOdemeYontemleri[i];
            }
          }
          filtreleVeGoster(
            aramaMetni: aramaMetni ?? '',
            onResetLazyLoading: onResetLazyLoading,
          );
        }
      });
    } catch (e, s) {
      ErrorHandler.logError(
        'ExpensesController.harcamaSilmeGeriAlLegacy',
        e,
        s,
      );
      rethrow;
    }
  }

  /// Widget prop'larıyla harcama ekle/düzenle (geriye dönük uyumluluk)
  Future<void> harcamaEkleVeyaDuzenleLegacy({
    required List<Map<String, dynamic>> tumHarcamalar,
    required List<dynamic> tumOdemeYontemleri,
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
    String? paraBirimi,
    Map<String, dynamic>? duzenlenecekHarcama,
    String? eskiOdemeYontemiId,
    double? eskiTutar,
    String? aramaMetni,
    Function(int)? onResetLazyLoading,
  }) async {
    try {
      _tumHarcamalar = List.from(tumHarcamalar);
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

      Map<String, dynamic>? modifiedExpense;
      if (duzenlenecekHarcama != null) {
        if (eskiOdemeYontemiId != null) {
          updateBalance(eskiOdemeYontemiId, -(eskiTutar ?? 0));
        }
        if (paymentMethodId != null) {
          updateBalance(paymentMethodId, amount);
        }

        int index = _tumHarcamalar.indexOf(duzenlenecekHarcama);
        if (index != -1) {
          modifiedExpense = {
            "id": duzenlenecekHarcama['id'],
            "isim": name,
            "tutar": amount,
            "kategori": category,
            "tarih": date.toString(),
            "silindi": false,
            "odemeYontemiId": paymentMethodId,
            "paraBirimi":
                paraBirimi ??
                duzenlenecekHarcama['paraBirimi'] ??
                getIt<CurrencyService>().currentCurrency,
          };
          _tumHarcamalar[index] = modifiedExpense;
        }
      } else {
        if (paymentMethodId != null) {
          updateBalance(paymentMethodId, amount);
        }

        modifiedExpense = {
          "id": const Uuid().v4(),
          "isim": name,
          "tutar": amount,
          "kategori": category,
          "tarih": date.toString(),
          "silindi": false,
          "odemeYontemiId": paymentMethodId,
          "paraBirimi": paraBirimi ?? getIt<CurrencyService>().currentCurrency,
        };
        _tumHarcamalar.add(modifiedExpense);
      }

      filtreleVeGoster(
        aramaMetni: aramaMetni ?? '',
        onResetLazyLoading: onResetLazyLoading,
      );

      // Arka planda Firestore işlemlerini yap
      Future.microtask(() async {
        try {
          final operations = <BatchOperation>[];
          if (modifiedExpense != null) {
            if (duzenlenecekHarcama != null) {
              operations.add(
                _expenseRepository.getUpdateExpenseOperation(
                  userId,
                  modifiedExpense,
                ),
              );
            } else {
              operations.add(
                _expenseRepository.getAddExpenseOperation(
                  userId,
                  modifiedExpense,
                ),
              );
            }
          }

          if (eskiOdemeYontemiId != null) {
            final pmIdx = _tumOdemeYontemleri.indexWhere(
              (p) => p.id == eskiOdemeYontemiId,
            );
            if (pmIdx != -1) {
              operations.add(
                _paymentMethodRepository.getUpdatePaymentMethodOperation(
                  userId,
                  _tumOdemeYontemleri[pmIdx].toMap(),
                ),
              );
            }
          }

          if (paymentMethodId != null &&
              paymentMethodId != eskiOdemeYontemiId) {
            final pmIdx = _tumOdemeYontemleri.indexWhere(
              (p) => p.id == paymentMethodId,
            );
            if (pmIdx != -1) {
              operations.add(
                _paymentMethodRepository.getUpdatePaymentMethodOperation(
                  userId,
                  _tumOdemeYontemleri[pmIdx].toMap(),
                ),
              );
            }
          }

          await getIt<BatchService>().commit(operations);
        } catch (e, s) {
          ErrorHandler.logError(
            'ExpensesController.harcamaEkleVeyaDuzenleLegacy Background',
            e,
            s,
          );

          if (modifiedExpense != null) {
            if (duzenlenecekHarcama != null) {
              // Geri alma: Güncellemeyi iptal et
              int revertIndex = _tumHarcamalar.indexWhere(
                (h) => h['id'] == modifiedExpense!['id'],
              );
              if (revertIndex != -1) {
                _tumHarcamalar[revertIndex] = duzenlenecekHarcama;
              }
              // Bakiyeleri eski haline getir
              if (paymentMethodId != null) {
                updateBalance(paymentMethodId, -amount);
              }
              if (eskiOdemeYontemiId != null) {
                updateBalance(eskiOdemeYontemiId, eskiTutar ?? 0);
              }
            } else {
              // Geri alma: Eklemeyi iptal et
              _tumHarcamalar.removeWhere(
                (h) => h['id'] == modifiedExpense!['id'],
              );
              if (paymentMethodId != null) {
                updateBalance(paymentMethodId, -amount);
              }
            }
            filtreleVeGoster(
              aramaMetni: aramaMetni ?? '',
              onResetLazyLoading: onResetLazyLoading,
            );
          }
        }
      });
    } catch (e, s) {
      ErrorHandler.logError(
        'ExpensesController.harcamaEkleVeyaDuzenleLegacy',
        e,
        s,
      );
      rethrow;
    }
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
    try {
      final bool oldSilindi = harcama['silindi'] ?? false;
      harcama['silindi'] = true;

      final paymentMethodId = harcama['odemeYontemiId'];
      if (paymentMethodId != null) {
        final pmIndex = _tumOdemeYontemleri.indexWhere(
          (p) => p.id == paymentMethodId,
        );
        if (pmIndex != -1) {
          final pm = _tumOdemeYontemleri[pmIndex];
          final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;

          final amountCurrency =
              harcama['paraBirimi']?.toString() ??
              getIt<CurrencyService>().currentCurrency;
          final cur = getIt<CurrencyService>();
          final convertedAmount = cur.convert(
            amount,
            amountCurrency,
            pm.paraBirimi,
          );

          double newBalance;
          if (pm.type == 'kredi') {
            newBalance = pm.balance - convertedAmount;
          } else {
            newBalance = pm.balance + convertedAmount;
          }
          _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
        }
      }

      // Anında arayüzü güncelle (Optimistic UI update)
      filtreleVeGoster(
        aramaMetni: aramaMetni,
        onResetLazyLoading: onResetLazyLoading,
      );

      // Arka planda Firestore işlemlerini yap
      Future.microtask(() async {
        try {
          final operations = <BatchOperation>[];
          operations.add(
            _expenseRepository.getUpdateExpenseOperation(userId, harcama),
          );

          if (paymentMethodId != null) {
            final pmIdx = _tumOdemeYontemleri.indexWhere(
              (p) => p.id == paymentMethodId,
            );
            if (pmIdx != -1) {
              operations.add(
                _paymentMethodRepository.getUpdatePaymentMethodOperation(
                  userId,
                  _tumOdemeYontemleri[pmIdx].toMap(),
                ),
              );
            }
          }
          await getIt<BatchService>().commit(operations);
        } catch (e, s) {
          ErrorHandler.logError(
            'ExpensesController.harcamaSil Background',
            e,
            s,
          );
          harcama['silindi'] = oldSilindi;

          if (paymentMethodId != null) {
            final pmIndex = _tumOdemeYontemleri.indexWhere(
              (p) => p.id == paymentMethodId,
            );
            if (pmIndex != -1) {
              final pm = _tumOdemeYontemleri[pmIndex];
              final amount =
                  double.tryParse(harcama['tutar'].toString()) ?? 0.0;
              final amountCurrency =
                  harcama['paraBirimi']?.toString() ??
                  getIt<CurrencyService>().currentCurrency;
              final convertedAmount = getIt<CurrencyService>().convert(
                amount,
                amountCurrency,
                pm.paraBirimi,
              );

              double newBalance;
              if (pm.type == 'kredi') {
                newBalance = pm.balance + convertedAmount;
              } else {
                newBalance = pm.balance - convertedAmount;
              }
              _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
            }
          }

          filtreleVeGoster(
            aramaMetni: aramaMetni,
            onResetLazyLoading: onResetLazyLoading,
          );
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('ExpensesController.harcamaSil', e, s);
      rethrow;
    }
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
    try {
      final bool oldSilindi = harcama['silindi'] ?? false;

      harcama['silindi'] = eskiSilindi ?? false;
      if (pmIndex != null && pmIndex != -1 && eskiBakiye != null) {
        _tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex].copyWith(
          balance: eskiBakiye,
        );
      }

      // Anında arayüzü güncelle (Optimistic UI update)
      filtreleVeGoster(
        aramaMetni: aramaMetni,
        onResetLazyLoading: onResetLazyLoading,
      );

      // Arka planda Firestore işlemlerini yap
      Future.microtask(() async {
        try {
          final operations = <BatchOperation>[];
          operations.add(
            _expenseRepository.getUpdateExpenseOperation(userId, harcama),
          );

          final paymentMethodId = harcama['odemeYontemiId'];
          if (paymentMethodId != null) {
            final restorePmIndex = _tumOdemeYontemleri.indexWhere(
              (p) => p.id == paymentMethodId,
            );
            if (restorePmIndex != -1) {
              operations.add(
                _paymentMethodRepository.getUpdatePaymentMethodOperation(
                  userId,
                  _tumOdemeYontemleri[restorePmIndex].toMap(),
                ),
              );
            }
          }

          await getIt<BatchService>().commit(operations);
        } catch (e, s) {
          ErrorHandler.logError(
            'ExpensesController.harcamaSilmeGeriAl Background',
            e,
            s,
          );
          harcama['silindi'] = oldSilindi;

          final paymentMethodId = harcama['odemeYontemiId'];
          if (paymentMethodId != null) {
            final restorePmIndex = _tumOdemeYontemleri.indexWhere(
              (p) => p.id == paymentMethodId,
            );
            if (restorePmIndex != -1) {
              final pm = _tumOdemeYontemleri[restorePmIndex];
              final amount =
                  double.tryParse(harcama['tutar'].toString()) ?? 0.0;
              final amountCurrency =
                  harcama['paraBirimi']?.toString() ??
                  getIt<CurrencyService>().currentCurrency;
              final convertedAmount = getIt<CurrencyService>().convert(
                amount,
                amountCurrency,
                pm.paraBirimi,
              );

              double newBalance;
              if (pm.type == 'kredi') {
                newBalance = pm.balance - convertedAmount;
              } else {
                newBalance = pm.balance + convertedAmount;
              }
              _tumOdemeYontemleri[restorePmIndex] = pm.copyWith(
                balance: newBalance,
              );
            }
          }

          filtreleVeGoster(
            aramaMetni: aramaMetni,
            onResetLazyLoading: onResetLazyLoading,
          );
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('ExpensesController.harcamaSilmeGeriAl', e, s);
      rethrow;
    }
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
    void updateBalance(
      String? pmId,
      double amountChange,
      String amountCurrency,
    ) {
      if (pmId == null) return;
      final pmIdx = _tumOdemeYontemleri.indexWhere((p) => p.id == pmId);
      if (pmIdx == -1) return;

      final pm = _tumOdemeYontemleri[pmIdx];

      final cur = getIt<CurrencyService>();
      final convertedAmount = cur.convert(
        amountChange,
        amountCurrency,
        pm.paraBirimi,
      );

      double newBalance;
      if (pm.type == 'kredi') {
        newBalance = pm.balance + convertedAmount;
      } else {
        newBalance = pm.balance - convertedAmount;
      }
      _tumOdemeYontemleri[pmIdx] = pm.copyWith(balance: newBalance);
    }

    try {
      Map<String, dynamic>? modifiedExpense;
      if (duzenlenecekHarcama != null) {
        if (eskiOdemeYontemiId != null) {
          final eskiParaBirimi =
              duzenlenecekHarcama['paraBirimi']?.toString() ??
              getIt<CurrencyService>().currentCurrency;
          updateBalance(eskiOdemeYontemiId, -(eskiTutar ?? 0), eskiParaBirimi);
        }
        if (paymentMethodId != null) {
          final yeniParaBirimi =
              duzenlenecekHarcama['paraBirimi']?.toString() ??
              getIt<CurrencyService>().currentCurrency;
          updateBalance(paymentMethodId, amount, yeniParaBirimi);
        }

        int index = _tumHarcamalar.indexOf(duzenlenecekHarcama);
        if (index != -1) {
          modifiedExpense = {
            "id": duzenlenecekHarcama['id'],
            "isim": name,
            "tutar": amount,
            "kategori": category,
            "tarih": date.toString(),
            "silindi": false,
            "odemeYontemiId": paymentMethodId,
            "paraBirimi":
                duzenlenecekHarcama['paraBirimi'] ??
                getIt<CurrencyService>().currentCurrency,
          };
          _tumHarcamalar[index] = modifiedExpense;
        }
      } else {
        if (paymentMethodId != null) {
          updateBalance(
            paymentMethodId,
            amount,
            getIt<CurrencyService>().currentCurrency,
          );
        }

        modifiedExpense = {
          "id": const Uuid().v4(),
          "isim": name,
          "tutar": amount,
          "kategori": category,
          "tarih": date.toString(),
          "silindi": false,
          "odemeYontemiId": paymentMethodId,
          "paraBirimi": getIt<CurrencyService>().currentCurrency,
        };
        _tumHarcamalar.add(modifiedExpense);
      }

      _tumHarcamalar.sort((a, b) {
        DateTime tarihA =
            DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
        DateTime tarihB =
            DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
        return tarihB.compareTo(tarihA);
      });

      filtreleVeGoster(
        aramaMetni: aramaMetni,
        onResetLazyLoading: onResetLazyLoading,
      );

      // Arka planda Firestore işlemlerini yap
      Future.microtask(() async {
        try {
          final operations = <BatchOperation>[];
          if (modifiedExpense != null) {
            if (duzenlenecekHarcama != null) {
              operations.add(
                _expenseRepository.getUpdateExpenseOperation(
                  userId,
                  modifiedExpense,
                ),
              );
            } else {
              operations.add(
                _expenseRepository.getAddExpenseOperation(
                  userId,
                  modifiedExpense,
                ),
              );
            }
          }

          if (eskiOdemeYontemiId != null) {
            final pmIdx = _tumOdemeYontemleri.indexWhere(
              (p) => p.id == eskiOdemeYontemiId,
            );
            if (pmIdx != -1) {
              operations.add(
                _paymentMethodRepository.getUpdatePaymentMethodOperation(
                  userId,
                  _tumOdemeYontemleri[pmIdx].toMap(),
                ),
              );
            }
          }

          if (paymentMethodId != null &&
              paymentMethodId != eskiOdemeYontemiId) {
            final pmIdx = _tumOdemeYontemleri.indexWhere(
              (p) => p.id == paymentMethodId,
            );
            if (pmIdx != -1) {
              operations.add(
                _paymentMethodRepository.getUpdatePaymentMethodOperation(
                  userId,
                  _tumOdemeYontemleri[pmIdx].toMap(),
                ),
              );
            }
          }

          await getIt<BatchService>().commit(operations);
        } catch (e, s) {
          ErrorHandler.logError(
            'ExpensesController.harcamaEkleVeyaDuzenle Background',
            e,
            s,
          );

          if (modifiedExpense != null) {
            if (duzenlenecekHarcama != null) {
              int revertIndex = _tumHarcamalar.indexWhere(
                (h) => h['id'] == modifiedExpense!['id'],
              );
              if (revertIndex != -1) {
                _tumHarcamalar[revertIndex] = duzenlenecekHarcama;
              }
              // Bakiyeleri eski haline getir
              if (paymentMethodId != null) {
                final yeniParaBirimi =
                    duzenlenecekHarcama['paraBirimi']?.toString() ??
                    getIt<CurrencyService>().currentCurrency;
                updateBalance(paymentMethodId, -amount, yeniParaBirimi);
              }
              if (eskiOdemeYontemiId != null) {
                final eskiParaBirimi =
                    duzenlenecekHarcama['paraBirimi']?.toString() ??
                    getIt<CurrencyService>().currentCurrency;
                updateBalance(
                  eskiOdemeYontemiId,
                  eskiTutar ?? 0,
                  eskiParaBirimi,
                );
              }
            } else {
              _tumHarcamalar.removeWhere(
                (h) => h['id'] == modifiedExpense!['id'],
              );
              if (paymentMethodId != null) {
                updateBalance(
                  paymentMethodId,
                  -amount,
                  getIt<CurrencyService>().currentCurrency,
                );
              }
            }

            _tumHarcamalar.sort((a, b) {
              DateTime tarihA =
                  DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
              DateTime tarihB =
                  DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
              return tarihB.compareTo(tarihA);
            });

            filtreleVeGoster(
              aramaMetni: aramaMetni,
              onResetLazyLoading: onResetLazyLoading,
            );
          }
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('ExpensesController.harcamaEkleVeyaDuzenle', e, s);
      rethrow;
    }
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
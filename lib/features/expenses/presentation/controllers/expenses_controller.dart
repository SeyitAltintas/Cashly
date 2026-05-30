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

  StreamSubscription? _expensesSubscription;

  // ===== STATE =====

  // ===== FORM STATE (AddExpenseFormState'ten taşındı) =====

  // Form: Seçilen tarih
  DateTime _formSelectedDate = DateTime.now();
  DateTime get formSelectedDate => _formSelectedDate;
  void setFormDate(DateTime date) {
    if (_formSelectedDate != date) {
      _formSelectedDate = date;
      notifyListeners();
    }
  }

  // Form: Seçilen kategori
  String _formSelectedCategory = '';
  String get formSelectedCategory => _formSelectedCategory;
  void setFormCategory(String category) {
    if (_formSelectedCategory != category) {
      _formSelectedCategory = category;
      notifyListeners();
    }
  }

  // Form: Seçilen ödeme yöntemi
  String? _formSelectedPaymentMethodId;
  String? get formSelectedPaymentMethodId => _formSelectedPaymentMethodId;
  void setFormPaymentMethod(String? paymentMethodId) {
    if (_formSelectedPaymentMethodId != paymentMethodId) {
      _formSelectedPaymentMethodId = paymentMethodId;
      notifyListeners();
    }
  }

  /// Form state'ini initialize et
  void initializeFormState({
    required String defaultCategory,
    String? defaultPaymentMethodId,
    DateTime? editDate,
    String? editCategory,
    String? editPaymentMethodId,
  }) {
    _formSelectedCategory = editCategory ?? defaultCategory;
    _formSelectedPaymentMethodId =
        editPaymentMethodId ?? defaultPaymentMethodId;
    if (editDate != null) {
      _formSelectedDate = editDate;
    } else {
      _formSelectedDate = DateTime.now();
    }
    notifyListeners();
  }

  /// Form state'ini sıfırla
  void resetFormState() {
    _formSelectedDate = DateTime.now();
    _formSelectedCategory = '';
    _formSelectedPaymentMethodId = null;
    notifyListeners();
  }

  // ===== VOICE INPUT STATE (ExpenseVoiceInputState'ten taşındı) =====

  bool _voiceIsListening = false;
  bool get voiceIsListening => _voiceIsListening;

  bool _voiceIsInitializing = true;
  bool get voiceIsInitializing => _voiceIsInitializing;

  bool _voiceHasError = false;
  bool get voiceHasError => _voiceHasError;

  bool _voiceIsCommandMode = false;
  bool get voiceIsCommandMode => _voiceIsCommandMode;

  bool _voicePendingConfirmation = false;
  bool get voicePendingConfirmation => _voicePendingConfirmation;

  String _voiceConfirmationTitle = '';
  String get voiceConfirmationTitle => _voiceConfirmationTitle;

  String _voiceConfirmationMessage = '';
  String get voiceConfirmationMessage => _voiceConfirmationMessage;

  String _voiceErrorMessage = '';
  String get voiceErrorMessage => _voiceErrorMessage;

  String _voiceRecognizedText = '';
  String get voiceRecognizedText => _voiceRecognizedText;

  /// Voice state: Başlatma durumunu güncelle
  void setVoiceInitialized({bool success = true, String? error}) {
    _voiceIsInitializing = false;
    if (!success) {
      _voiceHasError = true;
      _voiceErrorMessage =
          error ?? 'Mikrofon izni verilemedi veya cihaz desteklemiyor.';
    }
    notifyListeners();
  }

  /// Voice state: Dinleme başlat
  void startVoiceListening() {
    _voiceIsListening = true;
    _voiceIsCommandMode = false;
    _voiceRecognizedText = '';
    _voiceHasError = false;
    notifyListeners();
  }

  /// Voice state: Dinleme durdur
  void stopVoiceListening() {
    _voiceIsListening = false;
    notifyListeners();
  }

  /// Voice state: Komut modu ayarla
  void setVoiceCommandMode(String text) {
    _voiceRecognizedText = text;
    _voiceIsCommandMode = true;
    notifyListeners();
  }

  /// Voice state: Tanınan metni güncelle
  void updateVoiceRecognizedText(String text) {
    _voiceRecognizedText = text;
    _voiceIsCommandMode = false;
    notifyListeners();
  }

  /// Voice state: Onay iste
  void requestVoiceConfirmation({
    required String title,
    required String message,
  }) {
    _voicePendingConfirmation = true;
    _voiceConfirmationTitle = title;
    _voiceConfirmationMessage = message;
    notifyListeners();
  }

  /// Voice state: Onayı temizle
  void clearVoiceConfirmation() {
    _voicePendingConfirmation = false;
    _voiceConfirmationTitle = '';
    _voiceConfirmationMessage = '';
    notifyListeners();
  }

  // Voice: Parse result
  SpeechParseResult? _voiceParseResult;
  SpeechParseResult? get voiceParseResult => _voiceParseResult;
  void setVoiceParseResult(SpeechParseResult? result) {
    _voiceParseResult = result;
    notifyListeners();
  }

  // Voice: Seçilen kategori
  String _voiceSelectedCategory = '';
  String get voiceSelectedCategory => _voiceSelectedCategory;
  void setVoiceCategory(String category) {
    if (_voiceSelectedCategory != category) {
      _voiceSelectedCategory = category;
      notifyListeners();
    }
  }

  // Voice: Seçilen ödeme yöntemi
  String? _voiceSelectedPaymentMethodId;
  String? get voiceSelectedPaymentMethodId => _voiceSelectedPaymentMethodId;
  void setVoicePaymentMethod(String? paymentMethodId) {
    if (_voiceSelectedPaymentMethodId != paymentMethodId) {
      _voiceSelectedPaymentMethodId = paymentMethodId;
      notifyListeners();
    }
  }

  /// Voice state: Formu sıfırla
  void resetVoiceForm() {
    _voiceRecognizedText = '';
    _voiceIsCommandMode = false;
    _voiceParseResult = null;
    notifyListeners();
  }

  // ===== CATEGORY MANAGEMENT STATE (CategoryManagementState'ten taşındı) =====

  // Kategori listesi
  List<Map<String, dynamic>> _catMgmtKategoriler = [];
  List<Map<String, dynamic>> get catMgmtKategoriler => _catMgmtKategoriler;
  void setCatMgmtKategoriler(List<Map<String, dynamic>> value) {
    _catMgmtKategoriler = value;
    notifyListeners();
  }

  // Seçilen ikon
  String _catMgmtSecilenIkon = 'category';
  String get catMgmtSecilenIkon => _catMgmtSecilenIkon;
  void setCatMgmtSecilenIkon(String value) {
    _catMgmtSecilenIkon = value;
    notifyListeners();
  }

  /// Kategori ekle
  void addCatMgmtKategori(String isim, String ikon) {
    _catMgmtKategoriler.add({'isim': isim, 'ikon': ikon});
    notifyListeners();
  }

  /// Kategori sil
  void removeCatMgmtKategoriAt(int index) {
    if (index >= 0 && index < _catMgmtKategoriler.length) {
      _catMgmtKategoriler.removeAt(index);
      notifyListeners();
    }
  }

  /// Kategorileri yeniden sırala
  void reorderCatMgmtKategoriler(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final kategori = _catMgmtKategoriler.removeAt(oldIndex);
    _catMgmtKategoriler.insert(newIndex, kategori);
    notifyListeners();
  }

  /// Varsayılana sıfırla
  void resetCatMgmtToDefault(List<Map<String, dynamic>> defaultCategories) {
    _catMgmtKategoriler = List.from(defaultCategories);
    notifyListeners();
  }

  // ===== RECYCLE BIN STATE (ExpenseRecycleBinState'ten taşındı) =====

  // Silinen harcamalar listesi
  List<Map<String, dynamic>> _binSilinenHarcamalar = [];
  List<Map<String, dynamic>> get binSilinenHarcamalar => _binSilinenHarcamalar;
  void setBinSilinenHarcamalar(List<Map<String, dynamic>> value) {
    _binSilinenHarcamalar = value;
    notifyListeners();
  }

  /// Silinen harcamayı geri yükle (bakiye güncelleme ile)
  Future<void> binRestoreHarcama(Map<String, dynamic> harcama) async {
    harcama['silindi'] = false;
    _binSilinenHarcamalar.remove(harcama);

    // Ödeme yönteminin bakiyesini güncelle
    final paymentMethodId = harcama['odemeYontemiId'];
    if (paymentMethodId != null) {
      final pmIndex = _tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        final pm = _tumOdemeYontemleri[pmIndex];
        final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
        
        final amountCurrency = harcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
        final cur = getIt<CurrencyService>();
        final convertedAmount = cur.convert(amount, amountCurrency, pm.paraBirimi);

        double newBalance;
        if (pm.type == 'kredi') {
          newBalance = pm.balance + convertedAmount;
        } else {
          newBalance = pm.balance - convertedAmount;
        }
        _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
      }
    }
    
    notifyListeners();

    Future.microtask(() async {
      try {
        await _expenseRepository.updateExpense(userId, harcama);
        if (paymentMethodId != null) {
          await savePaymentMethods();
        }
      } catch (e, s) {
        ErrorHandler.logError('ExpensesController.binRestoreHarcama', e, s);
      }
    });
  }

  /// Harcamayı kalıcı sil
  Future<void> binPermanentDeleteHarcama(Map<String, dynamic> harcama) async {
    _tumHarcamalar.remove(harcama);
    _binSilinenHarcamalar.remove(harcama);
    notifyListeners();

    Future.microtask(() async {
      try {
        if (harcama['id'] != null) {
          await _expenseRepository.deleteExpense(userId, harcama['id']);
        }
      } catch (e, s) {
        ErrorHandler.logError('ExpensesController.binPermanentDeleteHarcama', e, s);
      }
    });
  }

  /// Çöpü boşalt
  Future<void> binEmptyBin() async {
    final toDelete = _tumHarcamalar.where((element) => element['silindi'] == true).toList();
    _tumHarcamalar.removeWhere((element) => element['silindi'] == true);
    _binSilinenHarcamalar.clear();
    notifyListeners();

    Future.microtask(() async {
      try {
        for (var h in toDelete) {
          if (h['id'] != null) {
            await _expenseRepository.deleteExpense(userId, h['id']);
          }
        }
      } catch (e, s) {
        ErrorHandler.logError('ExpensesController.binEmptyBin', e, s);
      }
    });
  }

  /// Tümünü geri yükle (bakiye güncelleme ile)
  Future<void> binRestoreAll() async {
    bool hasBalanceChange = false;
    final List<Map<String, dynamic>> updatedExpenses = [];

    for (var harcama in List.from(_binSilinenHarcamalar)) {
      harcama['silindi'] = false;

      // Ödeme yönteminin bakiyesini güncelle
      final paymentMethodId = harcama['odemeYontemiId'];
      if (paymentMethodId != null) {
        final pmIndex = _tumOdemeYontemleri.indexWhere(
          (p) => p.id == paymentMethodId,
        );
        if (pmIndex != -1) {
          final pm = _tumOdemeYontemleri[pmIndex];
          final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
          
          final amountCurrency = harcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
          final cur = getIt<CurrencyService>();
          final convertedAmount = cur.convert(amount, amountCurrency, pm.paraBirimi);

          double newBalance;
          if (pm.type == 'kredi') {
            newBalance = pm.balance + convertedAmount;
          } else {
            newBalance = pm.balance - convertedAmount;
          }
          _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
          hasBalanceChange = true;
        }
      }
      updatedExpenses.add(harcama);
    }
    
    _binSilinenHarcamalar.clear();
    notifyListeners();

    Future.microtask(() async {
      try {
        for (var data in updatedExpenses) {
          await _expenseRepository.updateExpense(userId, data);
        }
        if (hasBalanceChange) {
          await savePaymentMethods();
        }
      } catch (e, s) {
        ErrorHandler.logError('ExpensesController.binRestoreAll', e, s);
      }
    });
  }

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
    final isSameMonth = _secilenAy.year == value.year && _secilenAy.month == value.month;
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
    _expensesSubscription = _expenseRepository.watchExpensesByMonth(userId, _secilenAy).listen((data) {
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
      final oldPaymentMethods = List<PaymentMethod>.from(_tumOdemeYontemleri.map((e) => e.copyWith()));

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
          await _expenseRepository.updateExpense(userId, harcama); // Soft delete
          await savePaymentMethods();
        } catch (e, s) {
          // Hata durumunda işlemi geri al (Rollback)
          ErrorHandler.logError('ExpensesController.harcamaSilLegacy Background', e, s);
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
      final oldPaymentMethods = List<PaymentMethod>.from(_tumOdemeYontemleri.map((e) => e.copyWith()));

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
          ErrorHandler.logError('ExpensesController.harcamaSilmeGeriAlLegacy Background', e, s);
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
          if (modifiedExpense != null) {
             if (duzenlenecekHarcama != null) {
               await _expenseRepository.updateExpense(userId, modifiedExpense);
             } else {
               await _expenseRepository.addExpense(userId, modifiedExpense);
             }
          }
          await savePaymentMethods();
        } catch (e, s) {
          ErrorHandler.logError('ExpensesController.harcamaEkleVeyaDuzenleLegacy Background', e, s);
          
          if (modifiedExpense != null) {
            if (duzenlenecekHarcama != null) {
              // Geri alma: Güncellemeyi iptal et
              int revertIndex = _tumHarcamalar.indexWhere((h) => h['id'] == modifiedExpense!['id']);
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
              _tumHarcamalar.removeWhere((h) => h['id'] == modifiedExpense!['id']);
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
          
          final amountCurrency = harcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
          final cur = getIt<CurrencyService>();
          final convertedAmount = cur.convert(amount, amountCurrency, pm.paraBirimi);

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
          // Veritabanını arkaplanda güncelle
          await _expenseRepository.updateExpense(userId, harcama); // Soft delete
          await savePaymentMethods();
        } catch (e, s) {
          ErrorHandler.logError('ExpensesController.harcamaSil Background', e, s);
          harcama['silindi'] = oldSilindi;
          
          if (paymentMethodId != null) {
            final pmIndex = _tumOdemeYontemleri.indexWhere((p) => p.id == paymentMethodId);
            if (pmIndex != -1) {
              final pm = _tumOdemeYontemleri[pmIndex];
              final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
              final amountCurrency = harcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
              final convertedAmount = getIt<CurrencyService>().convert(amount, amountCurrency, pm.paraBirimi);

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
          await _expenseRepository.updateExpense(userId, harcama); // Restore
          await savePaymentMethods();
        } catch (e, s) {
          ErrorHandler.logError('ExpensesController.harcamaSilmeGeriAl Background', e, s);
          harcama['silindi'] = oldSilindi;
          
          final paymentMethodId = harcama['odemeYontemiId'];
          if (paymentMethodId != null) {
            final restorePmIndex = _tumOdemeYontemleri.indexWhere((p) => p.id == paymentMethodId);
            if (restorePmIndex != -1) {
              final pm = _tumOdemeYontemleri[restorePmIndex];
              final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
              final amountCurrency = harcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
              final convertedAmount = getIt<CurrencyService>().convert(amount, amountCurrency, pm.paraBirimi);

              double newBalance;
              if (pm.type == 'kredi') {
                newBalance = pm.balance - convertedAmount;
              } else {
                newBalance = pm.balance + convertedAmount;
              }
              _tumOdemeYontemleri[restorePmIndex] = pm.copyWith(balance: newBalance);
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
    void updateBalance(String? pmId, double amountChange, String amountCurrency) {
      if (pmId == null) return;
      final pmIdx = _tumOdemeYontemleri.indexWhere((p) => p.id == pmId);
      if (pmIdx == -1) return;

      final pm = _tumOdemeYontemleri[pmIdx];
      
      final cur = getIt<CurrencyService>();
      final convertedAmount = cur.convert(amountChange, amountCurrency, pm.paraBirimi);
      
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
          final eskiParaBirimi = duzenlenecekHarcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
          updateBalance(eskiOdemeYontemiId, -(eskiTutar ?? 0), eskiParaBirimi);
        }
        if (paymentMethodId != null) {
          final yeniParaBirimi = duzenlenecekHarcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
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
          updateBalance(paymentMethodId, amount, getIt<CurrencyService>().currentCurrency);
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
          if (modifiedExpense != null) {
            if (duzenlenecekHarcama != null) {
              await _expenseRepository.updateExpense(userId, modifiedExpense);
            } else {
              await _expenseRepository.addExpense(userId, modifiedExpense);
            }
          }
          await savePaymentMethods();
        } catch (e, s) {
          ErrorHandler.logError('ExpensesController.harcamaEkleVeyaDuzenle Background', e, s);
          
          if (modifiedExpense != null) {
            if (duzenlenecekHarcama != null) {
              int revertIndex = _tumHarcamalar.indexWhere((h) => h['id'] == modifiedExpense!['id']);
              if (revertIndex != -1) {
                _tumHarcamalar[revertIndex] = duzenlenecekHarcama;
              }
              // Bakiyeleri eski haline getir
              if (paymentMethodId != null) {
                final yeniParaBirimi = duzenlenecekHarcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
                updateBalance(paymentMethodId, -amount, yeniParaBirimi);
              }
              if (eskiOdemeYontemiId != null) {
                final eskiParaBirimi = duzenlenecekHarcama['paraBirimi']?.toString() ?? getIt<CurrencyService>().currentCurrency;
                updateBalance(eskiOdemeYontemiId, eskiTutar ?? 0, eskiParaBirimi);
              }
            } else {
              _tumHarcamalar.removeWhere((h) => h['id'] == modifiedExpense!['id']);
              if (paymentMethodId != null) {
                updateBalance(paymentMethodId, -amount, getIt<CurrencyService>().currentCurrency);
              }
            }
            
            _tumHarcamalar.sort((a, b) {
              DateTime tarihA = DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
              DateTime tarihB = DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
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

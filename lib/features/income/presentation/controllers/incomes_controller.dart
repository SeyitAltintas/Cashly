import 'package:flutter/foundation.dart';
import '../../data/models/income_model.dart';
import '../../domain/repositories/income_repository.dart';
import '../../../payment_methods/domain/repositories/payment_method_repository.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/services/speech/speech_service.dart';
import '../../../../core/di/injection_container.dart';
import 'dart:async';
import '../../../../core/services/currency_service.dart';

/// Gelirler Controller
/// Repository ile entegre, ChangeNotifier tabanlı state yönetimi sağlar.
/// Bu controller IncomePageState'in yerini alır.
class IncomesController extends ChangeNotifier {
  final IncomeRepository _incomeRepository;
  final PaymentMethodRepository _paymentMethodRepository;
  final String userId;

  IncomesController({
    required IncomeRepository incomeRepository,
    required PaymentMethodRepository paymentMethodRepository,
    required this.userId,
  }) : _incomeRepository = incomeRepository,
       _paymentMethodRepository = paymentMethodRepository;

  StreamSubscription? _incomesSubscription;

  // ===== STATE =====

  // ===== FORM STATE (AddIncomeFormState'ten taşındı) =====

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

  // ===== VOICE INPUT STATE (IncomeVoiceInputState'ten taşındı) =====

  bool _voiceIsListening = false;
  bool get voiceIsListening => _voiceIsListening;

  bool _voiceIsInitializing = true;
  bool get voiceIsInitializing => _voiceIsInitializing;

  bool _voiceHasError = false;
  bool get voiceHasError => _voiceHasError;

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
    _voiceRecognizedText = '';
    _voiceHasError = false;
    notifyListeners();
  }

  /// Voice state: Dinleme durdur
  void stopVoiceListening() {
    _voiceIsListening = false;
    notifyListeners();
  }

  /// Voice state: Tanınan metni güncelle
  void updateVoiceRecognizedText(String text) {
    _voiceRecognizedText = text;
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

  /// Voice state: Formu sıfırla
  void resetVoiceForm() {
    _voiceRecognizedText = '';
    _voiceParseResult = null;
    notifyListeners();
  }

  // ===== ANA STATE =====

  bool _aramaModu = false;
  bool get aramaModu => _aramaModu;
  set aramaModu(bool value) {
    if (_aramaModu != value) {
      _aramaModu = value;
      notifyListeners();
    }
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  DateTime _secilenAy = DateTime.now();
  DateTime get secilenAy => _secilenAy;
  set secilenAy(DateTime value) {
    // Gün/saat farkını görmezden gel — sadece yıl ve ay karşılaştır
    final isSameMonth = _secilenAy.year == value.year && _secilenAy.month == value.month;
    _secilenAy = DateTime(value.year, value.month);
    if (!isSameMonth) {
      _startIncomesStream();
      notifyListeners();
    }
  }

  List<Income> _tumGelirler = [];

  // ===== GETTERS =====
  double get incomeTarget => _incomeRepository.getIncomeTarget(userId);

  List<Income> get tumGelirler => _tumGelirler;

  List<Map<String, dynamic>> _kategoriler = [];
  List<Map<String, dynamic>> get kategoriler => _kategoriler;

  List<PaymentMethod> _tumOdemeYontemleri = [];
  List<PaymentMethod> get tumOdemeYontemleri => _tumOdemeYontemleri;

  List<Income> get filteredGelirler {
    return _tumGelirler.where((g) {
      if (g.isDeleted) return false;
      return g.date.year == _secilenAy.year && g.date.month == _secilenAy.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double get toplamTutar {
    final cur = getIt<CurrencyService>();
    return filteredGelirler.fold(
      0.0,
      (sum, g) =>
          sum + cur.convert(g.amount, g.paraBirimi, cur.currentCurrency),
    );
  }

  // ===== INIT VE DISPOSE =====

  void _startIncomesStream() {
    _incomesSubscription?.cancel();
    _incomesSubscription = _incomeRepository.watchIncomesByMonth(userId, _secilenAy).listen((data) {
      _tumGelirler = data.map((m) => Income.fromMap(m)).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _incomesSubscription?.cancel();
    super.dispose();
  }

  // ===== REPOSITORY İŞLEMLERİ =====

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _startIncomesStream();

      _kategoriler = _incomeRepository.getCategories(userId);

      final pmData = _paymentMethodRepository.getPaymentMethods(userId);
      _tumOdemeYontemleri = pmData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();
    } catch (e, s) {
      ErrorHandler.logError('IncomesController.loadData', e, s);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // saveIncomes metodu deprecate edildi, tekil işlemler kullanılıyor

  Future<void> savePaymentMethods() async {
    for (var pm in _tumOdemeYontemleri) {
      await _paymentMethodRepository.updatePaymentMethod(userId, pm.toMap());
    }
  }

  // ===== AY GEÇİŞLERİ =====

  void oncekiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month - 1);
    _startIncomesStream();
    notifyListeners();
  }

  void sonrakiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month + 1);
    _startIncomesStream();
    notifyListeners();
  }

  void toggleAramaModu() {
    _aramaModu = !_aramaModu;
    notifyListeners();
  }

  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== CRUD İŞLEMLERİ =====

  Future<void> addIncome(Income gelir) async {
    try {
      _tumGelirler.insert(0, gelir);

      if (gelir.paymentMethodId != null) {
        _updateBalance(gelir.paymentMethodId!, gelir.amount, gelir.paraBirimi, isIncome: true);
      }

      await _incomeRepository.addIncome(userId, gelir.toMap());
      await savePaymentMethods();
      notifyListeners();
    } catch (e, s) {
      ErrorHandler.logError('IncomesController.addIncome', e, s);
      rethrow;
    }
  }

  Future<void> deleteIncome(
    Income income, {
    PaymentMethod? pm,
    int? pmIndex,
  }) async {
    try {
      final index = _tumGelirler.indexWhere((g) => g.id == income.id);
      if (index != -1) {
        _tumGelirler[index] = income.copyWith(isDeleted: true);

        if (income.paymentMethodId != null) {
          _updateBalance(
            income.paymentMethodId!,
            income.amount,
            income.paraBirimi,
            isIncome: false,
          );
        }

        await _incomeRepository.updateIncome(userId, _tumGelirler[index].toMap());
        await savePaymentMethods();
        notifyListeners();
      }
    } catch (e, s) {
      ErrorHandler.logError('IncomesController.deleteIncome', e, s);
      rethrow;
    }
  }

  Future<void> undoDelete(
    Income income, {
    bool? wasDeleted,
    double? oldBalance,
    int? pmIndex,
    PaymentMethod? pm,
  }) async {
    try {
      final index = _tumGelirler.indexWhere((g) => g.id == income.id);
      if (index != -1) {
        _tumGelirler[index] = income.copyWith(isDeleted: wasDeleted ?? false);

        if (pmIndex != null && pmIndex != -1 && oldBalance != null) {
          _tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex].copyWith(
            balance: oldBalance,
          );
        }

        await _incomeRepository.updateIncome(userId, _tumGelirler[index].toMap());
        await savePaymentMethods();
        notifyListeners();
      }
    } catch (e, s) {
      ErrorHandler.logError('IncomesController.undoDelete', e, s);
      rethrow;
    }
  }

  Future<void> updateIncome({
    required Income income,
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
    String? paraBirimi,
  }) async {
    try {
      if (income.paymentMethodId != null) {
        final eskiParaBirimi = income.paraBirimi;
        _updateBalance(income.paymentMethodId!, income.amount, eskiParaBirimi, isIncome: false);
      }

      if (paymentMethodId != null) {
        final yeniParaBirimi = paraBirimi ?? income.paraBirimi;
        _updateBalance(paymentMethodId, amount, yeniParaBirimi, isIncome: true);
      }

      final index = _tumGelirler.indexWhere((g) => g.id == income.id);
      if (index != -1) {
        _tumGelirler[index] = Income(
          id: income.id,
          name: name,
          amount: amount,
          category: category,
          date: date,
          paymentMethodId: paymentMethodId,
          paraBirimi: paraBirimi ?? income.paraBirimi,
          isDeleted: false,
        );
        await _incomeRepository.updateIncome(userId, _tumGelirler[index].toMap());
      }

      // await saveIncomes();
      await savePaymentMethods();
      notifyListeners();
    } catch (e, s) {
      ErrorHandler.logError('IncomesController.updateIncome', e, s);
      rethrow;
    }
  }

  Future<void> addIncomeWithPayment({
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
    String? paraBirimi,
  }) async {
    final newIncome = Income(
      id: DateTime.now().toString(),
      name: name,
      amount: amount,
      category: category,
      date: date,
      paymentMethodId: paymentMethodId,
      paraBirimi: paraBirimi ?? getIt<CurrencyService>().currentCurrency,
    );

    await addIncome(newIncome);
  }

  void _updateBalance(String pmId, double amount, String amountCurrency, {required bool isIncome}) {
    final pmIndex = _tumOdemeYontemleri.indexWhere((p) => p.id == pmId);
    if (pmIndex == -1) return;

    final pm = _tumOdemeYontemleri[pmIndex];
    
    final cur = getIt<CurrencyService>();
    final convertedAmount = cur.convert(amount, amountCurrency, pm.paraBirimi);
    
    double newBalance;

    if (isIncome) {
      newBalance = pm.type == 'kredi'
          ? pm.balance - convertedAmount
          : pm.balance + convertedAmount;
    } else {
      newBalance = pm.type == 'kredi'
          ? pm.balance + convertedAmount
          : pm.balance - convertedAmount;
    }

    _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
  }

  void setPaymentMethods(List<PaymentMethod> methods) {
    _tumOdemeYontemleri = methods;
    notifyListeners();
  }

  /// Widget prop'larından veriyi yükle (AssetsController.setAssetsFromWidget benzeri)
  /// initState'te çağrılır — notifyListeners gerekmez (ilk build henüz olmadı)
  void setIncomesFromWidget(
    List<Income> incomes,
    List<PaymentMethod> paymentMethods,
  ) {
    if (_incomesSubscription == null) {
      _startIncomesStream();
    }
    _tumOdemeYontemleri = List.from(paymentMethods);
  }

  void refresh() {
    notifyListeners();
  }

  // ===== SETTINGS STATE (IncomeSettingsState'ten taşındı) =====

  // Settings: Kategori değişikliği flag'i
  bool _settingsCategoryChanged = false;
  bool get settingsCategoryChanged => _settingsCategoryChanged;
  void setSettingsCategoryChanged(bool value) {
    _settingsCategoryChanged = value;
    notifyListeners();
  }

  // ===== RECURRING INCOME STATE (RecurringIncomeState'ten taşındı) =====

  // Recurring: Tekrarlayan gelirler listesi
  List<Map<String, dynamic>> _tekrarlayanGelirler = [];
  List<Map<String, dynamic>> get tekrarlayanGelirler => _tekrarlayanGelirler;
  void setTekrarlayanGelirler(List<Map<String, dynamic>> value) {
    _tekrarlayanGelirler = value;
    notifyListeners();
  }

  /// Tekrarlayan gelir ekle
  void addTekrarlayanGelir(Map<String, dynamic> gelir) {
    _tekrarlayanGelirler.add(gelir);
    notifyListeners();
  }

  /// Tekrarlayan gelir güncelle
  void updateTekrarlayanGelir(int index, Map<String, dynamic> gelir) {
    if (index >= 0 && index < _tekrarlayanGelirler.length) {
      _tekrarlayanGelirler[index] = gelir;
      notifyListeners();
    }
  }

  /// Tekrarlayan gelir sil
  void removeTekrarlayanGelirAt(int index) {
    if (index >= 0 && index < _tekrarlayanGelirler.length) {
      _tekrarlayanGelirler.removeAt(index);
      notifyListeners();
    }
  }

  // ===== CATEGORY MANAGEMENT STATE (IncomeCategoryManagementState'ten taşındı) =====

  // Kategori listesi
  List<Map<String, dynamic>> _catMgmtKategoriler = [];
  List<Map<String, dynamic>> get catMgmtKategoriler => _catMgmtKategoriler;
  void setCatMgmtKategoriler(List<Map<String, dynamic>> value) {
    _catMgmtKategoriler = value;
    notifyListeners();
  }

  // Değişiklik flag'i
  bool _catMgmtHasChanges = false;
  bool get catMgmtHasChanges => _catMgmtHasChanges;
  void setCatMgmtHasChanges(bool value) {
    _catMgmtHasChanges = value;
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

  // ===== RECYCLE BIN STATE (IncomeRecycleBinState'ten taşındı) =====

  // Silinen gelirler listesi
  List<Income> _binSilinenGelirler = [];
  List<Income> get binSilinenGelirler => _binSilinenGelirler;
  void setBinSilinenGelirler(List<Income> value) {
    _binSilinenGelirler = value;
    notifyListeners();
  }

  /// Silinen geliri geri yükle
  Future<void> binRestoreGelir(Income gelir) async {
    int index = _tumGelirler.indexWhere((g) => g.id == gelir.id);
    if (index != -1) {
      _tumGelirler[index] = gelir.copyWith(isDeleted: false);
      await _incomeRepository.updateIncome(userId, _tumGelirler[index].toMap());
    }
    _binSilinenGelirler.removeWhere((g) => g.id == gelir.id);
    
    if (gelir.paymentMethodId != null) {
      _updateBalance(gelir.paymentMethodId!, gelir.amount, gelir.paraBirimi, isIncome: true);
      await savePaymentMethods();
    }
    notifyListeners();
  }

  /// Geliri kalıcı sil
  Future<void> binPermanentDeleteGelir(Income gelir) async {
    _tumGelirler.removeWhere((g) => g.id == gelir.id);
    _binSilinenGelirler.removeWhere((g) => g.id == gelir.id);
    await _incomeRepository.deleteIncome(userId, gelir.id);
    notifyListeners();
  }

  /// Çöpü boşalt
  Future<void> binEmptyBin() async {
    for (var g in _tumGelirler.where((g) => g.isDeleted)) {
      await _incomeRepository.deleteIncome(userId, g.id);
    }
    _tumGelirler.removeWhere((g) => g.isDeleted);
    _binSilinenGelirler.clear();
    notifyListeners();
  }

  /// Tümünü geri yükle
  Future<void> binRestoreAll() async {
    bool hasBalanceChange = false;
    for (var gelir in _binSilinenGelirler) {
      int index = _tumGelirler.indexWhere((g) => g.id == gelir.id);
      if (index != -1) {
        _tumGelirler[index] = gelir.copyWith(isDeleted: false);
        await _incomeRepository.updateIncome(userId, _tumGelirler[index].toMap());
        
        if (gelir.paymentMethodId != null) {
          _updateBalance(gelir.paymentMethodId!, gelir.amount, gelir.paraBirimi, isIncome: true);
          hasBalanceChange = true;
        }
      }
    }
    if (hasBalanceChange) {
      await savePaymentMethods();
    }
    _binSilinenGelirler.clear();
    notifyListeners();
  }
}

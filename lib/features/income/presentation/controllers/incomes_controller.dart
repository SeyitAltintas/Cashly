import 'package:flutter/foundation.dart';
import '../../../../core/services/speech/speech_service.dart';
import '../../data/models/income_model.dart';
import '../../domain/repositories/income_repository.dart';
import '../../../payment_methods/domain/repositories/payment_method_repository.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

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
    if (_secilenAy != value) {
      _secilenAy = value;
      notifyListeners();
    }
  }

  List<Income> _tumGelirler = [];
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
    return filteredGelirler.fold(0.0, (sum, g) => sum + g.amount);
  }

  // ===== REPOSITORY İŞLEMLERİ =====

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final incomesData = _incomeRepository.getIncomes(userId);
      _tumGelirler = incomesData.map((m) => Income.fromMap(m)).toList();

      _kategoriler = _incomeRepository.getCategories(userId);

      final pmData = _paymentMethodRepository.getPaymentMethods(userId);
      _tumOdemeYontemleri = pmData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveIncomes() async {
    final data = _tumGelirler.map((g) => g.toMap()).toList();
    await _incomeRepository.saveIncomes(userId, data);
  }

  Future<void> savePaymentMethods() async {
    final pmData = _tumOdemeYontemleri.map((pm) => pm.toMap()).toList();
    await _paymentMethodRepository.savePaymentMethods(userId, pmData);
  }

  // ===== AY GEÇİŞLERİ =====

  void oncekiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month - 1);
    notifyListeners();
  }

  void sonrakiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month + 1);
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
    _tumGelirler.insert(0, gelir);

    if (gelir.paymentMethodId != null) {
      _updateBalance(gelir.paymentMethodId!, gelir.amount, isIncome: true);
    }

    await saveIncomes();
    await savePaymentMethods();
    notifyListeners();
  }

  Future<void> deleteIncome(
    Income income, {
    PaymentMethod? pm,
    int? pmIndex,
  }) async {
    final index = _tumGelirler.indexWhere((g) => g.id == income.id);
    if (index != -1) {
      _tumGelirler[index] = income.copyWith(isDeleted: true);

      if (income.paymentMethodId != null) {
        _updateBalance(income.paymentMethodId!, income.amount, isIncome: false);
      }

      await saveIncomes();
      await savePaymentMethods();
      notifyListeners();
    }
  }

  Future<void> undoDelete(
    Income income, {
    bool? wasDeleted,
    double? oldBalance,
    int? pmIndex,
    PaymentMethod? pm,
  }) async {
    final index = _tumGelirler.indexWhere((g) => g.id == income.id);
    if (index != -1) {
      _tumGelirler[index] = income.copyWith(isDeleted: wasDeleted ?? false);

      if (pmIndex != null && pmIndex != -1 && oldBalance != null) {
        _tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex].copyWith(
          balance: oldBalance,
        );
      }

      await saveIncomes();
      await savePaymentMethods();
      notifyListeners();
    }
  }

  Future<void> updateIncome({
    required Income income,
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
  }) async {
    if (income.paymentMethodId != null) {
      _updateBalance(income.paymentMethodId!, income.amount, isIncome: false);
    }

    if (paymentMethodId != null) {
      _updateBalance(paymentMethodId, amount, isIncome: true);
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
        isDeleted: false,
      );
    }

    await saveIncomes();
    await savePaymentMethods();
    notifyListeners();
  }

  Future<void> addIncomeWithPayment({
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
  }) async {
    final newIncome = Income(
      id: DateTime.now().toString(),
      name: name,
      amount: amount,
      category: category,
      date: date,
      paymentMethodId: paymentMethodId,
    );

    await addIncome(newIncome);
  }

  void _updateBalance(String pmId, double amount, {required bool isIncome}) {
    final pmIndex = _tumOdemeYontemleri.indexWhere((p) => p.id == pmId);
    if (pmIndex == -1) return;

    final pm = _tumOdemeYontemleri[pmIndex];
    double newBalance;

    if (isIncome) {
      newBalance = pm.type == 'kredi'
          ? pm.balance - amount
          : pm.balance + amount;
    } else {
      newBalance = pm.type == 'kredi'
          ? pm.balance + amount
          : pm.balance - amount;
    }

    _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
  }

  void setPaymentMethods(List<PaymentMethod> methods) {
    _tumOdemeYontemleri = methods;
    notifyListeners();
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
  void binRestoreGelir(Income gelir) {
    int index = _tumGelirler.indexWhere((g) => g.id == gelir.id);
    if (index != -1) {
      _tumGelirler[index] = gelir.copyWith(isDeleted: false);
    }
    _binSilinenGelirler.removeWhere((g) => g.id == gelir.id);
    notifyListeners();
  }

  /// Geliri kalıcı sil
  void binPermanentDeleteGelir(Income gelir) {
    _tumGelirler.removeWhere((g) => g.id == gelir.id);
    _binSilinenGelirler.removeWhere((g) => g.id == gelir.id);
    notifyListeners();
  }

  /// Çöpü boşalt
  void binEmptyBin() {
    _tumGelirler.removeWhere((g) => g.isDeleted);
    _binSilinenGelirler.clear();
    notifyListeners();
  }

  /// Tümünü geri yükle
  void binRestoreAll() {
    for (var gelir in _binSilinenGelirler) {
      int index = _tumGelirler.indexWhere((g) => g.id == gelir.id);
      if (index != -1) {
        _tumGelirler[index] = gelir.copyWith(isDeleted: false);
      }
    }
    _binSilinenGelirler.clear();
    notifyListeners();
  }
}

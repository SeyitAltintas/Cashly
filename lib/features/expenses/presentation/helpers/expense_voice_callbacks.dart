import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'expense_calculation_helper.dart';

/// VoiceInputSheet'e geçilecek tüm callback'leri merkezi olarak yönetir.
/// ExpenseCalculationHelper tek seferinde oluşturulup tüm callback'lerde paylaşılır.
class ExpenseVoiceCallbacks {
  ExpenseVoiceCallbacks({
    required this.tumHarcamalar,
    required this.gosterilenHarcamalar,
    required this.secilenAy,
    required this.butceLimiti,
    required this.userId,
    required this.onHarcamalarChanged,
    required this.onFiltrele,
    required this.snackBarContext,
  }) : _helper = ExpenseCalculationHelper(
         tumHarcamalar: tumHarcamalar,
         gosterilenHarcamalar: gosterilenHarcamalar,
         secilenAy: secilenAy,
         butceLimiti: butceLimiti,
       );

  final List<Map<String, dynamic>> tumHarcamalar;
  final List<Map<String, dynamic>> gosterilenHarcamalar;
  final DateTime secilenAy;
  final double butceLimiti;
  final String userId;
  final void Function(List<Map<String, dynamic>>) onHarcamalarChanged;
  final void Function() onFiltrele;
  // ignore: use_build_context_synchronously — context sadece SnackBar'lar için
  final dynamic snackBarContext;

  final ExpenseCalculationHelper _helper;

  double get monthlyTotal => _helper.toplamTutar;

  Map<String, dynamic>? get topCategory => _helper.getTopCategory();

  double get weeklyTotal => _helper.getWeeklyTotal();

  double get dailyTotal => _helper.getDailyTotal();

  List<Map<String, dynamic>> get lastExpenses => _helper.getLastExpenses();

  Map<String, dynamic> get budgetStatus => _helper.checkBudget();

  double categoryTotal(String kategori) => _helper.getCategoryTotal(kategori);

  double dateRangeTotal(DateTime baslangic, DateTime bitis) =>
      _helper.getDateRangeTotal(baslangic, bitis);

  double dateRangeCategoryTotal(
    DateTime baslangic,
    DateTime bitis,
    String kategori,
  ) => _helper.getDateRangeCategoryTotal(baslangic, bitis, kategori);

  /// Son harcamayı siler (silindi = true yapar), UI'ı günceller.
  Map<String, dynamic>? deleteLastExpense() {
    final buAy = _helper.buAyHarcamalari;
    if (buAy.isEmpty) return null;
    final son = buAy.first;
    son['silindi'] = true;
    onFiltrele();
    onHarcamalarChanged(tumHarcamalar);
    return son;
  }

  /// Son harcamanın tutarını düzenler ya da siler (tutar == 0 ise).
  Map<String, dynamic>? editLastExpense(double yeniTutar) {
    final buAy = _helper.buAyHarcamalari;
    if (buAy.isEmpty) return null;
    final son = buAy.first;
    final eskiTutar = (son['tutar'] as num?)?.toDouble() ?? 0;
    final isim = son['isim'] ?? 'Harcama';
    if (yeniTutar == 0) {
      son['silindi'] = true;
    } else {
      son['tutar'] = yeniTutar;
    }
    onHarcamalarChanged(tumHarcamalar);
    return {
      'isim': isim,
      'eskiTutar': eskiTutar,
      'yeniTutar': yeniTutar,
      'silindi': yeniTutar == 0,
    };
  }

  /// Sabit gider şablonlarını bu ayın harcamalarına ekler.
  Map<String, dynamic> addFixedExpenses() {
    final expenseRepo = getIt<ExpenseRepository>();
    final sabitGiderler = expenseRepo.getFixedExpenseTemplates(userId);
    if (sabitGiderler.isEmpty) return {'adet': 0, 'toplam': 0.0};

    final simdi = DateTime.now();
    double toplam = 0;
    for (var sablon in sabitGiderler) {
      final tutar = (sablon['tutar'] as num?)?.toDouble() ?? 0;
      toplam += tutar;
      tumHarcamalar.add({
        'isim': sablon['isim'],
        'tutar': tutar,
        'kategori': 'Sabit Giderler',
        'tarih': simdi.toString(),
        'silindi': false,
      });
    }
    onHarcamalarChanged(tumHarcamalar);
    onFiltrele();
    return {'adet': sabitGiderler.length, 'toplam': toplam};
  }
}

/// AppSnackBar helper — sadece bir uyarı göstermek için context döngüsünden bağımsız tutar.
void showExpenseAddedSnackBar(
  dynamic context,
  String name,
  double amount,
  String formattedAmount,
  String addedLabel,
  String expenseLabel,
) {
  AppSnackBar.success(
    context,
    '$expenseLabel $addedLabel: $name - $formattedAmount',
  );
}

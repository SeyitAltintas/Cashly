import 'package:flutter/foundation.dart';

/// PDF dışa aktarma için ChangeNotifier state yöneticisi
class PdfExportState extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  void initWithDate(DateTime date) {
    _selectedDate = date;
  }

  bool _includeExpenses = true;
  bool get includeExpenses => _includeExpenses;
  set includeExpenses(bool value) {
    _includeExpenses = value;
    notifyListeners();
  }

  bool _includeIncomes = true;
  bool get includeIncomes => _includeIncomes;
  set includeIncomes(bool value) {
    _includeIncomes = value;
    notifyListeners();
  }

  bool _includeAssets = true;
  bool get includeAssets => _includeAssets;
  set includeAssets(bool value) {
    _includeAssets = value;
    notifyListeners();
  }

  bool _isExporting = false;
  bool get isExporting => _isExporting;
  set isExporting(bool value) {
    _isExporting = value;
    notifyListeners();
  }

  bool _includeFinansalOzet = true;
  bool get includeFinansalOzet => _includeFinansalOzet;
  set includeFinansalOzet(bool value) {
    _includeFinansalOzet = value;
    notifyListeners();
  }

  bool _includeNetDurum = true;
  bool get includeNetDurum => _includeNetDurum;
  set includeNetDurum(bool value) {
    _includeNetDurum = value;
    notifyListeners();
  }

  bool _includePastaGrafik = true;
  bool get includePastaGrafik => _includePastaGrafik;
  set includePastaGrafik(bool value) {
    _includePastaGrafik = value;
    notifyListeners();
  }

  bool _includeButceDurumu = true;
  bool get includeButceDurumu => _includeButceDurumu;
  set includeButceDurumu(bool value) {
    _includeButceDurumu = value;
    notifyListeners();
  }

  bool _includeIstatistikler = true;
  bool get includeIstatistikler => _includeIstatistikler;
  set includeIstatistikler(bool value) {
    _includeIstatistikler = value;
    notifyListeners();
  }

  bool _includeTop5Harcama = true;
  bool get includeTop5Harcama => _includeTop5Harcama;
  set includeTop5Harcama(bool value) {
    _includeTop5Harcama = value;
    notifyListeners();
  }

  void toggleAllVisualOptions(bool value) {
    _includeFinansalOzet = value;
    _includeNetDurum = value;
    _includePastaGrafik = value;
    _includeButceDurumu = value;
    _includeIstatistikler = value;
    _includeTop5Harcama = value;
    notifyListeners();
  }

  bool get hasSelection =>
      _includeExpenses || _includeIncomes || _includeAssets;

  bool get allVisualOptionsSelected =>
      _includeFinansalOzet &&
      _includeNetDurum &&
      _includePastaGrafik &&
      _includeButceDurumu &&
      _includeIstatistikler &&
      _includeTop5Harcama;

  bool get hasAnyVisualOption =>
      _includeFinansalOzet ||
      _includeNetDurum ||
      _includePastaGrafik ||
      _includeButceDurumu ||
      _includeIstatistikler ||
      _includeTop5Harcama;
}

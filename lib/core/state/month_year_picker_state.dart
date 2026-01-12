import 'package:flutter/foundation.dart';

/// MonthYearPicker için ChangeNotifier state yöneticisi
class MonthYearPickerState extends ChangeNotifier {
  // Seçilen tarih
  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;

  // Seçilen yıl (monthYear modu için)
  int _selectedYear = DateTime.now().year;
  int get selectedYear => _selectedYear;

  // Seçilen ay indexi (monthYear modu için)
  int _selectedMonthIndex = DateTime.now().month - 1;
  int get selectedMonthIndex => _selectedMonthIndex;

  /// Başlangıç değerlerini ayarla
  void initialize(DateTime initialDate) {
    _currentDate = initialDate;
    _selectedYear = initialDate.year;
    _selectedMonthIndex = initialDate.month - 1;
  }

  /// Ay değiştiğinde
  void setMonth(int index) {
    _selectedMonthIndex = index % 12;
    notifyListeners();
  }

  /// Yıl değiştiğinde
  void setYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  /// Tarih değiştiğinde (CupertinoDatePicker için)
  void setDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  /// Seçilen ay/yıl olarak DateTime döndür
  DateTime getSelectedDateTime() {
    return DateTime(_selectedYear, _selectedMonthIndex + 1);
  }
}

import 'package:flutter/material.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';

/// BuildContext'ten AppLocalizations'a kolay erişim sağlar.
///
/// Kullanım:
/// ```dart
/// final l10n = context.l10n;
/// Text(l10n.settings);
/// ```
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Veritabanındaki varsayılan Türkçe kelimeleri, kullanıcının seçtiği dile göre
  /// dinamik olarak eşleştirip döndürür. (Nakit, Yemek ve Kafe vb.)
  String translateDbName(String defaultName) {
    if (defaultName.isEmpty) return defaultName;

    final localizations = l10n;

    // Ödeme Yöntemleri
    if (defaultName == 'Nakit') return localizations.cash;
    if (defaultName == 'Banka Kartı') return localizations.bankAccount;
    if (defaultName == 'Kredi Kartı') return localizations.creditCard;
    if (defaultName == 'Ziraat Bankası') return localizations.ziraatBank;

    // Harcama Kategorileri
    if (defaultName == 'Yemek ve Kafe') return localizations.foodAndCafe;
    if (defaultName == 'Market ve Atıştırmalık') {
      return localizations.groceryAndSnacks;
    }
    if (defaultName == 'Araç ve Ulaşım') {
      return localizations.vehicleAndTransport;
    }
    if (defaultName == 'Hediye ve Özel') return localizations.giftAndSpecial;
    if (defaultName == 'Sabit Giderler') return localizations.fixedExpenses;
    if (defaultName == 'Diğer') return localizations.categoryOther;

    // Gelir Kategorileri
    if (defaultName == 'Maaş') return localizations.salary;
    if (defaultName == 'Freelance') return localizations.freelance;
    if (defaultName == 'Yatırım') return localizations.investment;
    if (defaultName == 'Kira Geliri') return localizations.rentalIncome;
    if (defaultName == 'Hediye') return localizations.gift;

    return defaultName; // Kullanıcının özel eklediği farklı bir isimse aynen kalsın
  }

  /// Ay numarasına göre lokalize ay ismini döndürür
  String getMonthName(int month) {
    switch (month) {
      case 1:
        return l10n.january;
      case 2:
        return l10n.february;
      case 3:
        return l10n.march;
      case 4:
        return l10n.april;
      case 5:
        return l10n.may;
      case 6:
        return l10n.june;
      case 7:
        return l10n.july;
      case 8:
        return l10n.august;
      case 9:
        return l10n.september;
      case 10:
        return l10n.october;
      case 11:
        return l10n.november;
      case 12:
        return l10n.december;
      default:
        return '';
    }
  }

  /// Ay numarasına göre lokalize kısa ay ismini döndürür
  String getShortMonthName(int month) {
    switch (month) {
      case 1:
        return l10n.janShort;
      case 2:
        return l10n.febShort;
      case 3:
        return l10n.marShort;
      case 4:
        return l10n.aprShort;
      case 5:
        return l10n.mayShort;
      case 6:
        return l10n.junShort;
      case 7:
        return l10n.julShort;
      case 8:
        return l10n.augShort;
      case 9:
        return l10n.sepShort;
      case 10:
        return l10n.octShort;
      case 11:
        return l10n.novShort;
      case 12:
        return l10n.decShort;
      default:
        return '';
    }
  }
}

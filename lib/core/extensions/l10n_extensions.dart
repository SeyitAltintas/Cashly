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
    if (defaultName.isEmpty) {
      return defaultName;
    }

    final localizations = l10n;

    // Ödeme Yöntemleri
    if (defaultName == 'Nakit' || defaultName == 'Cash') {
      return localizations.cash;
    }
    if (defaultName == 'Banka Kartı' || defaultName == 'Bank Account') {
      return localizations.bankAccount;
    }
    if (defaultName == 'Kredi Kartı' || defaultName == 'Credit Card') {
      return localizations.creditCard;
    }
    if (defaultName == 'Ziraat Bankası' || defaultName == 'Ziraat Bank') {
      return localizations.ziraatBank;
    }

    // Harcama Kategorileri
    if (defaultName == 'Yemek ve Kafe' || defaultName == 'Food & Cafe') {
      return localizations.foodAndCafe;
    }
    if (defaultName == 'Market ve Atıştırmalık' ||
        defaultName == 'Grocery & Snacks') {
      return localizations.groceryAndSnacks;
    }
    if (defaultName == 'Araç ve Ulaşım' ||
        defaultName == 'Vehicle & Transport') {
      return localizations.vehicleAndTransport;
    }
    if (defaultName == 'Hediye ve Özel' || defaultName == 'Gift & Special') {
      return localizations.giftAndSpecial;
    }
    if (defaultName == 'Sabit Giderler' || defaultName == 'Fixed Expenses') {
      return localizations.fixedExpenses;
    }
    if (defaultName == 'Diğer' ||
        defaultName == 'CategoryOther' ||
        defaultName == 'Other') {
      return localizations.categoryOther;
    }

    // Gelir Kategorileri
    if (defaultName == 'Maaş' || defaultName == 'Salary') {
      return localizations.salary;
    }
    if (defaultName == 'Freelance') {
      return localizations.freelance;
    }
    if (defaultName == 'Yatırım' || defaultName == 'Investment') {
      return localizations.investment;
    }
    if (defaultName == 'Kira Geliri' || defaultName == 'Rental Income') {
      return localizations.rentalIncome;
    }
    if (defaultName == 'Hediye' || defaultName == 'Gift') {
      return localizations.gift;
    }

    // Varlık Kategorileri
    if (defaultName == 'Altın' || defaultName == 'Gold') {
      return localizations.gold;
    }
    if (defaultName == 'Gümüş' || defaultName == 'Silver') {
      return localizations.silver;
    }
    if (defaultName == 'Döviz' || defaultName == 'Currency') {
      return localizations.currency;
    }
    if (defaultName == 'Kripto' || defaultName == 'Crypto') {
      return localizations.crypto;
    }
    if (defaultName == 'Banka' || defaultName == 'Bank') {
      return localizations.banka;
    }
    if (defaultName == 'Hisse Senedi' || defaultName == 'Stock') {
      return localizations.hisseSenedi;
    }

    // Altın Türleri
    if (defaultName == 'Gram') {
      return localizations.goldGram;
    }
    if (defaultName == 'Çeyrek' || defaultName == 'Quarter') {
      return localizations.goldQuarter;
    }
    if (defaultName == 'Yarım' || defaultName == 'Half') {
      return localizations.goldHalf;
    }
    if (defaultName == 'Tam' || defaultName == 'Full') {
      return localizations.goldFull;
    }
    if (defaultName == 'Cumhuriyet' || defaultName == 'Republic') {
      return localizations.goldRepublic;
    }
    if (defaultName == 'Ata') {
      return localizations.goldAta;
    }
    if (defaultName == 'Ons' || defaultName == 'Ounce') {
      return localizations.goldOunce;
    }

    // Döviz Türleri
    if (defaultName == 'Amerikan Doları (USD)' ||
        defaultName == 'US Dollar (USD)') {
      return localizations.currencyUSD;
    }
    if (defaultName == 'Euro (EUR)') {
      return localizations.currencyEUR;
    }
    if (defaultName == 'İngiliz Sterlini (GBP)' ||
        defaultName == 'British Pound (GBP)') {
      return localizations.currencyGBP;
    }
    if (defaultName == 'İsviçre Frangı (CHF)' ||
        defaultName == 'Swiss Franc (CHF)') {
      return localizations.currencyCHF;
    }
    if (defaultName == 'Japon Yeni (JPY)' ||
        defaultName == 'Japanese Yen (JPY)') {
      return localizations.currencyJPY;
    }
    if (defaultName == 'Kanada Doları (CAD)' ||
        defaultName == 'Canadian Dollar (CAD)') {
      return localizations.currencyCAD;
    }

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

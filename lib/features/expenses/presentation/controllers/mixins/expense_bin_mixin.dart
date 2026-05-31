import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../../payment_methods/data/models/payment_method_model.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/currency_service.dart';

mixin ExpenseBinMixin on ChangeNotifier {
  ExpenseRepository get expenseRepository;
  String get userId;
  void refresh();
  Future<void> savePaymentMethodsInternal();
  List<PaymentMethod> get tumOdemeYontemleri;
  List<Map<String, dynamic>> get tumHarcamalar;


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
      final pmIndex = tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        final pm = tumOdemeYontemleri[pmIndex];
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
          newBalance = pm.balance + convertedAmount;
        } else {
          newBalance = pm.balance - convertedAmount;
        }
        tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
      }
    }

    notifyListeners();

    Future.microtask(() async {
      try {
        await expenseRepository.updateExpense(userId, harcama);
        if (paymentMethodId != null) {
          await savePaymentMethodsInternal();
        }
      } catch (e, s) {
        ErrorHandler.logError('ExpensesController.binRestoreHarcama', e, s);
      }
    });
  }

  /// Harcamayı kalıcı sil
  Future<void> binPermanentDeleteHarcama(Map<String, dynamic> harcama) async {
    tumHarcamalar.remove(harcama);
    _binSilinenHarcamalar.remove(harcama);
    notifyListeners();

    Future.microtask(() async {
      try {
        if (harcama['id'] != null) {
          await expenseRepository.deleteExpense(userId, harcama['id']);
        }
      } catch (e, s) {
        ErrorHandler.logError(
          'ExpensesController.binPermanentDeleteHarcama',
          e,
          s,
        );
      }
    });
  }

  /// Çöpü boşalt
  Future<void> binEmptyBin() async {
    final toDelete = tumHarcamalar
        .where((element) => element['silindi'] == true)
        .toList();
    tumHarcamalar.removeWhere((element) => element['silindi'] == true);
    _binSilinenHarcamalar.clear();
    notifyListeners();

    Future.microtask(() async {
      try {
        for (var h in toDelete) {
          if (h['id'] != null) {
            await expenseRepository.deleteExpense(userId, h['id']);
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
        final pmIndex = tumOdemeYontemleri.indexWhere(
          (p) => p.id == paymentMethodId,
        );
        if (pmIndex != -1) {
          final pm = tumOdemeYontemleri[pmIndex];
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
            newBalance = pm.balance + convertedAmount;
          } else {
            newBalance = pm.balance - convertedAmount;
          }
          tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
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
          await expenseRepository.updateExpense(userId, data);
        }
        if (hasBalanceChange) {
          await savePaymentMethodsInternal();
        }
      } catch (e, s) {
        ErrorHandler.logError('ExpensesController.binRestoreAll', e, s);
      }
    });
  }
}

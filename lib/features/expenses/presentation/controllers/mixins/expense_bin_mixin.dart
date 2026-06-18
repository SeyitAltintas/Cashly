import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../../payment_methods/data/models/payment_method_model.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/currency_service.dart';
import '../../../../../core/services/batch_service.dart';
import '../../../../payment_methods/domain/repositories/payment_method_repository.dart';

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
        final operations = <BatchOperation>[];
        operations.add(
          expenseRepository.getUpdateExpenseOperation(userId, harcama),
        );
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
            final convertedAmount = getIt<CurrencyService>().convert(
              amount,
              amountCurrency,
              pm.paraBirimi,
            );
            // Restore Expense: bakiye güncelleniyor
            // Kredi kartıysa (harcama borcu artırmıştı) geri gelince borç tekrar artar (+)
            // Nakitse bakiye azalır (-)
            final delta = pm.type == 'kredi'
                ? convertedAmount
                : -convertedAmount;

            operations.add(
              getIt<PaymentMethodRepository>().getIncrementBalanceOperation(
                userId,
                pm.id,
                delta,
              ),
            );
          }
        }
        await getIt<BatchService>().commit(operations);
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
          final operations = <BatchOperation>[];
          operations.add(
            expenseRepository.getDeleteExpenseOperation(userId, harcama['id']),
          );
          await getIt<BatchService>().commit(operations);
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
        final operations = <BatchOperation>[];
        for (var h in toDelete) {
          if (h['id'] != null) {
            operations.add(
              expenseRepository.getDeleteExpenseOperation(userId, h['id']),
            );
          }
        }
        if (operations.isNotEmpty) {
          await getIt<BatchService>().commit(operations);
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
        final operations = <BatchOperation>[];
        for (var data in updatedExpenses) {
          operations.add(
            expenseRepository.getUpdateExpenseOperation(userId, data),
          );
          
          if (hasBalanceChange) {
            final paymentMethodId = data['odemeYontemiId'];
            if (paymentMethodId != null) {
              final pmIndex = tumOdemeYontemleri.indexWhere(
                (p) => p.id == paymentMethodId,
              );
              if (pmIndex != -1) {
                final pm = tumOdemeYontemleri[pmIndex];
                final amount = double.tryParse(data['tutar'].toString()) ?? 0.0;
                final amountCurrency =
                    data['paraBirimi']?.toString() ??
                    getIt<CurrencyService>().currentCurrency;
                final convertedAmount = getIt<CurrencyService>().convert(
                  amount,
                  amountCurrency,
                  pm.paraBirimi,
                );
                
                final delta = pm.type == 'kredi'
                    ? convertedAmount
                    : -convertedAmount;

                operations.add(
                  getIt<PaymentMethodRepository>().getIncrementBalanceOperation(
                    userId,
                    pm.id,
                    delta,
                  ),
                );
              }
            }
          }
        }
        await getIt<BatchService>().commit(operations);
      } catch (e, s) {
        ErrorHandler.logError('ExpensesController.binRestoreAll', e, s);
      }
    });
  }
}

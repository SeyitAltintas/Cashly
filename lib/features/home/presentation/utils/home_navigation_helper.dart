import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/error_boundary.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:cashly/core/services/batch_service.dart';
import 'package:cashly/core/utils/error_handler.dart';

import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cashly/features/home/presentation/state/home_page_state.dart';

import 'package:cashly/features/assets/presentation/pages/assets_page.dart';
import 'package:cashly/features/assets/domain/repositories/asset_repository.dart';
import 'package:cashly/features/assets/data/models/asset_model.dart';

import 'package:cashly/features/analysis/presentation/pages/analysis_page.dart';

import 'package:cashly/features/payment_methods/presentation/pages/payment_methods_page.dart';
import 'package:cashly/features/payment_methods/presentation/pages/transfer_page.dart';
import 'package:cashly/features/payment_methods/presentation/pages/payment_method_detail_page.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/features/payment_methods/data/models/transfer_model.dart';
import 'package:cashly/features/payment_methods/domain/transfer_schedule_policy.dart';

import 'package:cashly/features/expenses/presentation/pages/expenses_page.dart';
import 'package:cashly/features/income/presentation/pages/incomes_page.dart';

class HomeNavigationHelper {
  static void navigateToAssets({
    required BuildContext context,
    required HomePageState state,
    required AuthController authController,
    required VoidCallback onReturn,
    bool replace = false,
    DateTime? initialDate,
  }) {
    final route = MaterialPageRoute(
      builder: (context) => PageErrorBoundary(
        pageName: context.l10n.assets,
        child: AssetsPage(
          assets: state.varliklar.where((a) => !a.isDeleted).toList(),
          deletedAssets: state.varliklar.where((a) => a.isDeleted).toList(),
          initialDate: initialDate ?? state.secilenAy,
          onDelete: (asset) {
            final index = state.varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              final deletedAsset = state.varliklar[index].copyWith(isDeleted: true);
              final newList = List<Asset>.from(state.varliklar);
              newList[index] = deletedAsset;
              state.varliklar = newList;
              getIt<AssetRepository>().updateAsset(
                authController.currentUser!.id,
                deletedAsset.toMap(),
              );
            }
          },
          onEdit: (asset) {
            final index = state.varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              final newList = List<Asset>.from(state.varliklar);
              newList[index] = asset;
              state.varliklar = newList;
              getIt<AssetRepository>().updateAsset(
                authController.currentUser!.id,
                asset.toMap(),
              );
            }
          },
          onRestore: (asset) {
            final index = state.varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              final restoredAsset = state.varliklar[index].copyWith(isDeleted: false);
              final newList = List<Asset>.from(state.varliklar);
              newList[index] = restoredAsset;
              state.varliklar = newList;
              getIt<AssetRepository>().updateAsset(
                authController.currentUser!.id,
                restoredAsset.toMap(),
              );
            }
          },
          onPermanentDelete: (asset) {
            final newList = List<Asset>.from(state.varliklar);
            newList.removeWhere((a) => a.id == asset.id);
            state.varliklar = newList;
            getIt<AssetRepository>().deleteAsset(
              authController.currentUser!.id,
              asset.id,
            );
          },
          onEmptyBin: () {
            final deletedAssets = state.varliklar.where((a) => a.isDeleted).toList();
            final newList = List<Asset>.from(state.varliklar);
            newList.removeWhere((a) => a.isDeleted);
            state.varliklar = newList;
            
            Future.microtask(() async {
              try {
                final operations = <BatchOperation>[];
                for (var asset in deletedAssets) {
                  operations.add(
                    getIt<AssetRepository>().getDeleteAssetOperation(
                      authController.currentUser!.id,
                      asset.id,
                    ),
                  );
                }
                await getIt<BatchService>().commit(operations);
              } catch (e, s) {
                ErrorHandler.logError('HomePage.Assets.onEmptyBin Background', e, s);
              }
            });
          },
          onAdd: (name, amount, quantity, category, type) {
            final newAsset = Asset(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              amount: amount,
              quantity: quantity,
              category: category,
              type: type,
              lastUpdated: DateTime.now(),
              isDeleted: false,
            );
            final newList = List<Asset>.from(state.varliklar);
            newList.add(newAsset);
            state.varliklar = newList;
            getIt<AssetRepository>().addAsset(
              authController.currentUser!.id,
              newAsset.toMap(),
            );
          },
        ),
      ),
    );

    final future = replace ? Navigator.pushReplacement(context, route) : Navigator.push(context, route);
    future.then((_) => onReturn());
  }

  static void navigateToAnalysis({
    required BuildContext context,
    required HomePageState state,
    required AuthController authController,
    required VoidCallback onReturn,
    required VoidCallback onDataRefresh,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageErrorBoundary(
          pageName: context.l10n.analysis,
          child: AnalysisPage(
            expenses: state.tumHarcamalar,
            assets: state.varliklar,
            incomes: state.tumGelirler,
            selectedDate: state.secilenAy,
            userId: authController.currentUser?.id ?? '',
            userName: authController.currentUser?.name ?? context.l10n.user,
            paymentMethods: state.tumOdemeYontemleri,
            categoryBudgets: state.categoryBudgets,
            totalBudget: state.butceLimiti,
            expenseCategoryIcons: state.kategoriIkonlari,
            incomeCategoryIcons: state.gelirKategoriIkonlari,
            onAddExpensePressed: (DateTime date) {
              navigateToExpenses(
                context: context,
                state: state,
                authController: authController,
                onReturn: onReturn,
                onDataRefresh: onDataRefresh,
                replace: true,
                initialDate: date,
              );
            },
            onAddIncomePressed: (DateTime date) {
              navigateToIncomes(
                context: context,
                state: state,
                authController: authController,
                onReturn: onReturn,
                onDataRefresh: onDataRefresh,
                replace: true,
                initialDate: date,
              );
            },
            onAddAssetPressed: (DateTime date) {
              navigateToAssets(
                context: context,
                state: state,
                authController: authController,
                onReturn: onReturn,
                replace: true,
                initialDate: date,
              );
            },
          ),
        ),
      ),
    ).then((_) => onReturn());
  }

  static void navigateToPaymentMethods({
    required BuildContext context,
    required HomePageState state,
    required AuthController authController,
    required VoidCallback onReturn,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageErrorBoundary(
          pageName: context.l10n.paymentMethods,
          child: PaymentMethodsPage(
            paymentMethods: state.tumOdemeYontemleri.where((p) => !p.isDeleted).toList(),
            deletedPaymentMethods: state.tumOdemeYontemleri.where((p) => p.isDeleted).toList(),
            userName: authController.currentUser?.name,
            userProfileUrl: authController.currentUser?.profileImage,
            onDelete: (pm) {
              final i = state.tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) {
                final deletedPm = pm.copyWith(isDeleted: true);
                final newList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
                newList[i] = deletedPm;
                state.tumOdemeYontemleri = newList;
                getIt<PaymentMethodRepository>().updatePaymentMethod(
                  authController.currentUser!.id,
                  deletedPm.toMap(),
                );
              }
            },
            onEdit: (pm) {
              final i = state.tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) {
                final newList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
                newList[i] = pm;
                state.tumOdemeYontemleri = newList;
                getIt<PaymentMethodRepository>().updatePaymentMethod(
                  authController.currentUser!.id,
                  pm.toMap(),
                );
              }
            },
            onRestore: (pm) {
              final i = state.tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) {
                final restoredPm = pm.copyWith(isDeleted: false);
                final newList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
                newList[i] = restoredPm;
                state.tumOdemeYontemleri = newList;
                getIt<PaymentMethodRepository>().updatePaymentMethod(
                  authController.currentUser!.id,
                  restoredPm.toMap(),
                );
              }
            },
            onPermanentDelete: (pm) {
              final newList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
              newList.removeWhere((p) => p.id == pm.id);
              state.tumOdemeYontemleri = newList;
              getIt<PaymentMethodRepository>().deletePaymentMethod(
                authController.currentUser!.id,
                pm.id,
              );
            },
            onEmptyBin: () {
              final deletedMethods = state.tumOdemeYontemleri.where((p) => p.isDeleted).toList();
              for (var delPm in deletedMethods) {
                getIt<PaymentMethodRepository>().deletePaymentMethod(
                  authController.currentUser!.id,
                  delPm.id,
                );
              }
              final newList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
              newList.removeWhere((p) => p.isDeleted);
              state.tumOdemeYontemleri = newList;
            },
            onAdd: (name, type, lastFourDigits, balance, limit, colorIndex) {
              final newPm = PaymentMethod(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                type: type,
                lastFourDigits: lastFourDigits,
                balance: balance,
                limit: limit,
                colorIndex: colorIndex,
                createdAt: DateTime.now(),
                isDeleted: false,
              );
              final newList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
              newList.add(newPm);
              state.tumOdemeYontemleri = newList;
              getIt<PaymentMethodRepository>().addPaymentMethod(
                authController.currentUser!.id,
                newPm.toMap(),
              );
            },
            onCardTap: (pm) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentMethodDetailPage(
                    paymentMethod: pm,
                    harcamalar: state.tumHarcamalar,
                    gelirler: state.tumGelirler,
                    transferler: state.tumTransferler,
                    tumOdemeYontemleri: state.tumOdemeYontemleri,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ).then((_) => onReturn());
  }

  static void navigateToTransfer({
    required BuildContext context,
    required HomePageState state,
    required AuthController authController,
    required VoidCallback onReturn,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferPage(
          userId: authController.currentUser?.id,
          paymentMethods: state.tumOdemeYontemleri.where((pm) => !pm.isDeleted).toList(),
          transfers: state.tumTransferler,
          onTransfer: (fromId, toId, amount, date) {
            final isScheduled = TransferSchedulePolicy.isScheduled(selectedDate: date);
            int finalFromIndex = -1;
            int finalToIndex = -1;
            
            final pmList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
            
            if (!isScheduled) {
              final cur = getIt<CurrencyService>();
              final fromIndex = pmList.indexWhere((pm) => pm.id == fromId);
              finalFromIndex = fromIndex;
              if (fromIndex != -1) {
                final fromPm = pmList[fromIndex];
                final convertedFromAmount = cur.convert(amount, cur.currentCurrency, fromPm.paraBirimi);
                double yeniBakiye = fromPm.type == 'kredi' ? fromPm.balance + convertedFromAmount : fromPm.balance - convertedFromAmount;
                pmList[fromIndex] = fromPm.copyWith(balance: yeniBakiye);
              }
              final toIndex = pmList.indexWhere((pm) => pm.id == toId);
              finalToIndex = toIndex;
              if (toIndex != -1) {
                final toPm = pmList[toIndex];
                final convertedToAmount = cur.convert(amount, cur.currentCurrency, toPm.paraBirimi);
                double yeniBakiye = toPm.type == 'kredi' ? toPm.balance - convertedToAmount : toPm.balance + convertedToAmount;
                pmList[toIndex] = toPm.copyWith(balance: yeniBakiye);
              }
              state.tumOdemeYontemleri = pmList;
            }

            final newTransfer = Transfer(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              fromAccountId: fromId,
              toAccountId: toId,
              amount: amount,
              date: date,
              isScheduled: isScheduled,
              isExecuted: !isScheduled,
              paraBirimi: getIt<CurrencyService>().currentCurrency,
            );
            
            final transferList = List<Transfer>.from(state.tumTransferler);
            transferList.insert(0, newTransfer);
            state.tumTransferler = transferList;
            
            Future.microtask(() async {
              try {
                final operations = <BatchOperation>[];
                if (!isScheduled) {
                  if (finalFromIndex != -1) {
                    operations.add(getIt<PaymentMethodRepository>().getUpdatePaymentMethodOperation(
                      authController.currentUser!.id,
                      pmList[finalFromIndex].toMap(),
                    ));
                  }
                  if (finalToIndex != -1) {
                    operations.add(getIt<PaymentMethodRepository>().getUpdatePaymentMethodOperation(
                      authController.currentUser!.id,
                      pmList[finalToIndex].toMap(),
                    ));
                  }
                }
                operations.add(getIt<PaymentMethodRepository>().getAddTransferOperation(
                  authController.currentUser!.id,
                  newTransfer.toMap(),
                ));
                await getIt<BatchService>().commit(operations);
              } catch (e, s) {
                ErrorHandler.logError('HomePage.Transfer Background', e, s);
              }
            });
          },
        ),
      ),
    ).then((_) => onReturn());
  }

  static void navigateToExpenses({
    required BuildContext context,
    required HomePageState state,
    required AuthController authController,
    required VoidCallback onReturn,
    required VoidCallback onDataRefresh,
    bool replace = false,
    DateTime? initialDate,
  }) {
    final targetDate = initialDate ?? DateTime.now();
    state.secilenAy = targetDate;

    final route = MaterialPageRoute(
      builder: (context) => PageErrorBoundary(
        pageName: context.l10n.expenses,
        child: ExpensesPage(
          tumHarcamalar: state.tumHarcamalar,
          tumOdemeYontemleri: state.tumOdemeYontemleri,
          kategoriIkonlari: state.kategoriIkonlari,
          butceLimiti: state.butceLimiti,
          secilenAy: targetDate,
          userId: authController.currentUser?.id,
          varsayilanOdemeYontemiId: state.varsayilanOdemeYontemiId,
          onHarcamalarChanged: (harcamalar) {
            state.tumHarcamalar = harcamalar;
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            state.tumOdemeYontemleri = odemeYontemleri;
          },
          onMonthChanged: (DateTime newMonth) {
            state.secilenAy = newMonth;
          },
        ),
      ),
    );

    final future = replace ? Navigator.pushReplacement(context, route) : Navigator.push(context, route);
    future.then((_) {
      onDataRefresh();
      onReturn();
    });
  }

  static void navigateToIncomes({
    required BuildContext context,
    required HomePageState state,
    required AuthController authController,
    required VoidCallback onReturn,
    required VoidCallback onDataRefresh,
    bool replace = false,
    DateTime? initialDate,
  }) {
    final targetDate = initialDate ?? DateTime.now();
    state.secilenAy = targetDate;

    final route = MaterialPageRoute(
      builder: (context) => PageErrorBoundary(
        pageName: context.l10n.incomes,
        child: IncomesPage(
          tumGelirler: state.tumGelirler,
          tumOdemeYontemleri: state.tumOdemeYontemleri,
          gelirKategoriIkonlari: state.gelirKategoriIkonlari,
          secilenAy: targetDate,
          userId: authController.currentUser?.id,
          onGelirlerChanged: (gelirler) {
            state.tumGelirler = gelirler;
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            state.tumOdemeYontemleri = odemeYontemleri;
          },
          onMonthChanged: (DateTime newMonth) {
            state.secilenAy = newMonth;
          },
        ),
      ),
    );

    final future = replace ? Navigator.pushReplacement(context, route) : Navigator.push(context, route);
    future.then((_) {
      onDataRefresh();
      onReturn();
    });
  }
}

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
              final deletedAsset = state.varliklar[index].copyWith(
                isDeleted: true,
              );
              final newList = List<Asset>.from(state.varliklar);
              newList[index] = deletedAsset;
              state.varliklar = newList;
              Future.microtask(() async {
                try {
                  await getIt<AssetRepository>().updateAsset(
                    authController.currentUser!.id,
                    deletedAsset.toMap(),
                  );
                } catch (e, s) {
                  ErrorHandler.logError(
                    'HomePage.Assets.onDelete Background',
                    e,
                    s,
                  );
                }
              });
            }
          },
          onEdit: (asset) {
            final index = state.varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              final newList = List<Asset>.from(state.varliklar);
              newList[index] = asset;
              state.varliklar = newList;
              Future.microtask(() async {
                try {
                  await getIt<AssetRepository>().updateAsset(
                    authController.currentUser!.id,
                    asset.toMap(),
                  );
                } catch (e, s) {
                  ErrorHandler.logError(
                    'HomePage.Assets.onEdit Background',
                    e,
                    s,
                  );
                }
              });
            }
          },
          onRestore: (asset) {
            final index = state.varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              final restoredAsset = state.varliklar[index].copyWith(
                isDeleted: false,
              );
              final newList = List<Asset>.from(state.varliklar);
              newList[index] = restoredAsset;
              state.varliklar = newList;
              Future.microtask(() async {
                try {
                  await getIt<AssetRepository>().updateAsset(
                    authController.currentUser!.id,
                    restoredAsset.toMap(),
                  );
                } catch (e, s) {
                  ErrorHandler.logError(
                    'HomePage.Assets.onRestore Background',
                    e,
                    s,
                  );
                }
              });
            }
          },
          onPermanentDelete: (asset) {
            final newList = List<Asset>.from(state.varliklar);
            newList.removeWhere((a) => a.id == asset.id);
            state.varliklar = newList;
            Future.microtask(() async {
              try {
                await getIt<AssetRepository>().deleteAsset(
                  authController.currentUser!.id,
                  asset.id,
                );
              } catch (e, s) {
                ErrorHandler.logError(
                  'HomePage.Assets.onPermanentDelete Background',
                  e,
                  s,
                );
              }
            });
          },
          onEmptyBin: () {
            final deletedAssets = state.varliklar
                .where((a) => a.isDeleted)
                .toList();
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
                ErrorHandler.logError(
                  'HomePage.Assets.onEmptyBin Background',
                  e,
                  s,
                );
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
            Future.microtask(() async {
              try {
                await getIt<AssetRepository>().addAsset(
                  authController.currentUser!.id,
                  newAsset.toMap(),
                );
              } catch (e, s) {
                ErrorHandler.logError('HomePage.Assets.onAdd Background', e, s);
              }
            });
          },
        ),
      ),
    );

    final future = replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);
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
            harcamalar: state.tumHarcamalar,
            gelirler: state.tumGelirler,
            transferler: state.tumTransferler,
            paymentMethods: state.tumOdemeYontemleri
                .where((p) => !p.isDeleted)
                .toList(),
            deletedPaymentMethods: state.tumOdemeYontemleri
                .where((p) => p.isDeleted)
                .toList(),
            userName: authController.currentUser?.name,
            userProfileUrl: authController.currentUser?.profileImage,
            onDelete: (pm) {
              final i = state.tumOdemeYontemleri.indexWhere(
                (p) => p.id == pm.id,
              );
              if (i != -1) {
                final deletedPm = pm.copyWith(isDeleted: true);
                final newList = List<PaymentMethod>.from(
                  state.tumOdemeYontemleri,
                );
                newList[i] = deletedPm;
                state.tumOdemeYontemleri = newList;
              }
            },
            onEdit: (pm) {
              final i = state.tumOdemeYontemleri.indexWhere(
                (p) => p.id == pm.id,
              );
              if (i != -1) {
                final newList = List<PaymentMethod>.from(
                  state.tumOdemeYontemleri,
                );
                newList[i] = pm;
                state.tumOdemeYontemleri = newList;
              }
            },
            onRestore: (pm) {
              final i = state.tumOdemeYontemleri.indexWhere(
                (p) => p.id == pm.id,
              );
              if (i != -1) {
                final restoredPm = pm.copyWith(isDeleted: false);
                final newList = List<PaymentMethod>.from(
                  state.tumOdemeYontemleri,
                );
                newList[i] = restoredPm;
                state.tumOdemeYontemleri = newList;
              }
            },
            onPermanentDelete: (pm) {
              final newList = List<PaymentMethod>.from(
                state.tumOdemeYontemleri,
              );
              newList.removeWhere((p) => p.id == pm.id);
              state.tumOdemeYontemleri = newList;
            },
            onEmptyBin: () {
              final newList = List<PaymentMethod>.from(
                state.tumOdemeYontemleri,
              );
              newList.removeWhere((p) => p.isDeleted);
              state.tumOdemeYontemleri = newList;
            },
            onAdd: (pm) {
              final newList = List<PaymentMethod>.from(
                state.tumOdemeYontemleri,
              );
              newList.add(pm);
              state.tumOdemeYontemleri = newList;
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
          paymentMethods: state.tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
          transfers: state.tumTransferler,
          onDeleteTransfer: (transfer) {
            final transferList = List<Transfer>.from(state.tumTransferler);
            transferList.removeWhere((t) => t.id == transfer.id);
            state.tumTransferler = transferList;
            
            final pmList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
            final Map<String, double> pmDeltas = {};

            if (transfer.isExecuted || !transfer.isScheduled) {
              final fromIndex = pmList.indexWhere((pm) => pm.id == transfer.fromAccountId);
              final toIndex = pmList.indexWhere((pm) => pm.id == transfer.toAccountId);

              final fromPm = fromIndex != -1 ? pmList[fromIndex] : null;
              final toPm = toIndex != -1 ? pmList[toIndex] : null;

              final cur = getIt<CurrencyService>();
              
              if (fromPm != null) {
                final convertedFromAmount = cur.convert(
                  transfer.amount,
                  transfer.paraBirimi,
                  fromPm.paraBirimi,
                );
                // Revert sender: If credit, decrease debt (-). If cash, increase cash (+).
                final deltaFrom = fromPm.type == 'kredi'
                    ? -convertedFromAmount
                    : convertedFromAmount;
                pmDeltas[fromPm.id] = (pmDeltas[fromPm.id] ?? 0) + deltaFrom;
                pmList[fromIndex] = fromPm.copyWith(balance: fromPm.balance + deltaFrom);
              }

              if (toPm != null) {
                final convertedToAmount = cur.convert(
                  transfer.amount,
                  transfer.paraBirimi,
                  toPm.paraBirimi,
                );
                // Revert receiver: If credit, increase debt (+). If cash, decrease cash (-).
                final deltaTo = toPm.type == 'kredi'
                    ? convertedToAmount
                    : -convertedToAmount;
                pmDeltas[toPm.id] = (pmDeltas[toPm.id] ?? 0) + deltaTo;
                pmList[toIndex] = toPm.copyWith(balance: toPm.balance + deltaTo);
              }
              
              state.tumOdemeYontemleri = pmList;
            }

            Future.microtask(() async {
              try {
                final pmRepo = getIt<PaymentMethodRepository>();
                final userId = authController.currentUser!.id;
                final operations = <BatchOperation>[];
                
                operations.add(pmRepo.getDeleteTransferOperation(userId, transfer.id));
                
                for (final entry in pmDeltas.entries) {
                  if (entry.value != 0) {
                    operations.add(
                      pmRepo.getIncrementBalanceOperation(userId, entry.key, entry.value),
                    );
                  }
                }
                
                await getIt<BatchService>().commit(operations);
              } catch (e, s) {
                ErrorHandler.logError(
                  'HomePage.DeleteTransfer Background',
                  e,
                  s,
                );
              }
            });
          },
          onTransfer: (fromId, toId, amount, date) {
            final isScheduled = TransferSchedulePolicy.isScheduled(
              selectedDate: date,
            );

            final pmList = List<PaymentMethod>.from(state.tumOdemeYontemleri);
            final fromIndex = pmList.indexWhere((pm) => pm.id == fromId);
            final toIndex = pmList.indexWhere((pm) => pm.id == toId);

            final fromPm = fromIndex != -1 ? pmList[fromIndex] : null;
            final toPm = toIndex != -1 ? pmList[toIndex] : null;

            final cur = getIt<CurrencyService>();
            // Kullanıcı arayüzünde girilen miktar her zaman uygulamanın ana para birimindedir.
            final transferCurrency = cur.currentCurrency;

            final Map<String, double> pmDeltas = {};

            if (!isScheduled) {
              if (fromPm != null) {
                // Ana para biriminden gönderen hesabın para birimine çevir
                final convertedFromAmount = cur.convert(
                  amount,
                  transferCurrency,
                  fromPm.paraBirimi,
                ); 
                final deltaFrom = fromPm.type == 'kredi'
                    ? convertedFromAmount // transferring out of credit increases debt
                    : -convertedFromAmount; // transferring out of cash decreases cash
                pmDeltas[fromId] = (pmDeltas[fromId] ?? 0) + deltaFrom;

                double yeniBakiye = fromPm.balance + deltaFrom;
                pmList[fromIndex] = fromPm.copyWith(balance: yeniBakiye);
              }

              if (toPm != null) {
                // Ana para biriminden alıcı hesabın para birimine çevir
                final convertedToAmount = cur.convert(
                  amount,
                  transferCurrency,
                  toPm.paraBirimi,
                );
                final deltaTo = toPm.type == 'kredi'
                    ? -convertedToAmount // transferring into credit decreases debt
                    : convertedToAmount; // transferring into cash increases cash
                pmDeltas[toId] = (pmDeltas[toId] ?? 0) + deltaTo;

                final currentToPm = pmList[toIndex];
                double yeniBakiye = currentToPm.balance + deltaTo;
                pmList[toIndex] = currentToPm.copyWith(balance: yeniBakiye);
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
              paraBirimi: transferCurrency,
            );

            final transferList = List<Transfer>.from(state.tumTransferler);
            transferList.insert(0, newTransfer);
            state.tumTransferler = transferList;

            Future.microtask(() async {
              try {
                final operations = <BatchOperation>[];
                if (!isScheduled) {
                  for (final entry in pmDeltas.entries) {
                    if (entry.value != 0) {
                      operations.add(
                        getIt<PaymentMethodRepository>()
                            .getIncrementBalanceOperation(
                              authController.currentUser!.id,
                              entry.key,
                              entry.value,
                            ),
                      );
                    }
                  }
                }
                operations.add(
                  getIt<PaymentMethodRepository>().getAddTransferOperation(
                    authController.currentUser!.id,
                    newTransfer.toMap(),
                  ),
                );
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

    final future = replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);
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

    final future = replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);
    future.then((_) {
      onDataRefresh();
      onReturn();
    });
  }
}

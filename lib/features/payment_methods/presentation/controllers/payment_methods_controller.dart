import 'package:flutter/foundation.dart';
import '../../data/models/payment_method_model.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/services/batch_service.dart';
import 'mixins/payment_method_form_mixin.dart';
import 'mixins/payment_method_transfer_mixin.dart';
import 'mixins/payment_method_detail_mixin.dart';

/// Ödeme Yöntemleri Controller — CRUD, filtreleme ve liste yönetimi.
///
/// Sayfaya özgü geçici state mixin'lere ayrılmıştır:
/// - [PaymentMethodFormMixin]     → AddPaymentMethodPage form state'i
/// - [PaymentMethodTransferMixin] → TransferPage state'i
/// - [PaymentMethodDetailMixin]   → PaymentMethodDetailPage ay/yıl state'i
class PaymentMethodsController extends ChangeNotifier
    with
        PaymentMethodFormMixin,
        PaymentMethodTransferMixin,
        PaymentMethodDetailMixin {
  final PaymentMethodRepository _paymentMethodRepository;
  final String userId;

  PaymentMethodsController({
    required PaymentMethodRepository paymentMethodRepository,
    required this.userId,
  }) : _paymentMethodRepository = paymentMethodRepository;

  // ===== ANA STATE =====

  bool _aramaModu = false;
  bool get aramaModu => _aramaModu;
  set aramaModu(bool value) {
    if (_aramaModu != value) {
      _aramaModu = value;
      notifyListeners();
      _filtrele();
    }
  }

  String _aramaMetni = '';
  String get aramaMetni => _aramaMetni;
  set aramaMetni(String value) {
    if (_aramaMetni != value) {
      _aramaMetni = value;
      _filtrele();
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

  List<PaymentMethod> _paymentMethods = [];
  List<PaymentMethod> _deletedPaymentMethods = [];
  List<PaymentMethod> _filteredMethods = [];

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<PaymentMethod> get deletedPaymentMethods => _deletedPaymentMethods;
  List<PaymentMethod> get filteredMethods => _filteredMethods;

  /// Transfer page için alias
  List<PaymentMethod> get odemeYontemleri => _paymentMethods;

  double get totalBalance {
    final cur = getIt<CurrencyService>();
    return _filteredMethods
        .where((pm) => pm.type != 'kredi')
        .fold(
          0.0,
          (sum, pm) =>
              sum + cur.convert(pm.balance, pm.paraBirimi, cur.currentCurrency),
        );
  }

  double get totalDebt {
    final cur = getIt<CurrencyService>();
    return _filteredMethods
        .where((pm) => pm.type == 'kredi')
        .fold(
          0.0,
          (sum, pm) =>
              sum + cur.convert(pm.balance, pm.paraBirimi, cur.currentCurrency),
        );
  }

  // ===== VERİ YÜKLEME =====

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final methodsData = _paymentMethodRepository.getPaymentMethods(userId);
      _paymentMethods = methodsData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();

      final deletedData = _paymentMethodRepository.getDeletedPaymentMethods(
        userId,
      );
      _deletedPaymentMethods = deletedData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();

      _filteredMethods = List.from(_paymentMethods);
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.loadData', e, s);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Widget prop'larından veriyi yükle (prop-down pattern için)
  void initData(
    List<PaymentMethod> methods,
    List<PaymentMethod> deletedMethods,
  ) {
    _paymentMethods = List.from(methods);
    _deletedPaymentMethods = List.from(deletedMethods);
    _filteredMethods = List.from(_paymentMethods);
    notifyListeners();
  }

  // ===== FİLTRELEME =====

  void _filtrele() {
    final activeMethods = _paymentMethods.where((pm) => !pm.isDeleted).toList();
    if (_aramaModu && _aramaMetni.isNotEmpty) {
      final text = _aramaMetni.toLowerCase();
      _filteredMethods = activeMethods.where((pm) {
        return pm.name.toLowerCase().contains(text) ||
            pm.typeDisplayName.toLowerCase().contains(text);
      }).toList();
    } else {
      _filteredMethods = activeMethods;
    }
    notifyListeners();
  }

  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() => notifyListeners();

  // ===== BAKİYE GÜNCELLEME =====

  void updatePaymentMethodBalance(String accountId, double newBalance) {
    final index = _paymentMethods.indexWhere((pm) => pm.id == accountId);
    if (index != -1) {
      _paymentMethods[index] = _paymentMethods[index].copyWith(
        balance: newBalance,
      );
      notifyListeners();
    }
  }

  // ===== CRUD İŞLEMLERİ =====

  Future<void> addMethod(PaymentMethod method) async {
    try {
      _paymentMethods.add(method);
      _filtrele();

      Future.microtask(() async {
        try {
          await _paymentMethodRepository.addPaymentMethod(
            userId,
            method.toMap(),
          );
        } catch (e, s) {
          ErrorHandler.logError(
            'PaymentMethodsController.addMethod Background',
            e,
            s,
          );
          _paymentMethods.removeWhere((p) => p.id == method.id);
          _filtrele();
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.addMethod', e, s);
      rethrow;
    }
  }

  Future<void> updateMethod(PaymentMethod method) async {
    try {
      final index = _paymentMethods.indexWhere((p) => p.id == method.id);
      if (index != -1) {
        final oldMethod = _paymentMethods[index];
        final double balanceDelta = method.balance - oldMethod.balance;
        _paymentMethods[index] = method;
        _filtrele();

        Future.microtask(() async {
          try {
            final operations = <BatchOperation>[
              _paymentMethodRepository.getUpdatePaymentMethodOperation(
                userId,
                method.toMap(),
              ),
            ];
            if (balanceDelta != 0) {
              operations.add(
                _paymentMethodRepository.getIncrementBalanceOperation(
                  userId,
                  method.id,
                  balanceDelta,
                ),
              );
            }
            await getIt<BatchService>().commit(operations);
          } catch (e, s) {
            ErrorHandler.logError(
              'PaymentMethodsController.updateMethod Background',
              e,
              s,
            );
            final revertIndex = _paymentMethods.indexWhere(
              (p) => p.id == method.id,
            );
            if (revertIndex != -1) {
              _paymentMethods[revertIndex] = oldMethod;
              _filtrele();
            }
          }
        });
      }
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.updateMethod', e, s);
      rethrow;
    }
  }

  Future<void> moveToBin(PaymentMethod method) async {
    try {
      _paymentMethods.removeWhere((p) => p.id == method.id);
      final deleted = method.copyWith(isDeleted: true);
      _deletedPaymentMethods.add(deleted);
      _filtrele();

      Future.microtask(() async {
        try {
          final operations = <BatchOperation>[
            _paymentMethodRepository.getUpdatePaymentMethodOperation(
              userId,
              deleted.toMap(),
            ),
          ];
          await getIt<BatchService>().commit(operations);
        } catch (e, s) {
          ErrorHandler.logError(
            'PaymentMethodsController.moveToBin Background',
            e,
            s,
          );
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.moveToBin', e, s);
      rethrow;
    }
  }

  Future<void> restoreMethod(PaymentMethod method) async {
    try {
      _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
      final restored = method.copyWith(isDeleted: false);
      _paymentMethods.add(restored);
      _filtrele();

      Future.microtask(() async {
        try {
          final operations = <BatchOperation>[
            _paymentMethodRepository.getUpdatePaymentMethodOperation(
              userId,
              restored.toMap(),
            ),
          ];
          await getIt<BatchService>().commit(operations);
        } catch (e, s) {
          ErrorHandler.logError(
            'PaymentMethodsController.restoreMethod Background',
            e,
            s,
          );
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.restoreMethod', e, s);
      rethrow;
    }
  }

  Future<void> permanentDelete(PaymentMethod method) async {
    try {
      final methodToRestore = _deletedPaymentMethods.firstWhere(
        (p) => p.id == method.id,
        orElse: () => method,
      );
      _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
      notifyListeners();

      Future.microtask(() async {
        try {
          await _paymentMethodRepository.deletePaymentMethod(userId, method.id);
        } catch (e, s) {
          ErrorHandler.logError(
            'PaymentMethodsController.permanentDelete Background',
            e,
            s,
          );
          _deletedPaymentMethods.add(methodToRestore);
          notifyListeners();
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.permanentDelete', e, s);
      rethrow;
    }
  }

  Future<void> emptyBin() async {
    try {
      final deletedIds = _deletedPaymentMethods.map((m) => m.id).toList();
      _deletedPaymentMethods.clear();
      notifyListeners();

      Future.microtask(() async {
        try {
          final operations = <BatchOperation>[
            for (final id in deletedIds)
              _paymentMethodRepository.getDeletePaymentMethodOperation(
                userId,
                id,
              ),
          ];
          await getIt<BatchService>().commit(operations);
        } catch (e, s) {
          ErrorHandler.logError(
            'PaymentMethodsController.emptyBin Background',
            e,
            s,
          );
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.emptyBin', e, s);
      rethrow;
    }
  }

  Future<void> restoreAll() async {
    try {
      final restoredMaps = <Map<String, dynamic>>[];
      for (final method in _deletedPaymentMethods) {
        final restored = method.copyWith(isDeleted: false);
        _paymentMethods.add(restored);
        restoredMaps.add(restored.toMap());
      }
      _deletedPaymentMethods.clear();
      _filtrele();

      Future.microtask(() async {
        try {
          final operations = <BatchOperation>[
            for (final data in restoredMaps)
              _paymentMethodRepository.getUpdatePaymentMethodOperation(
                userId,
                data,
              ),
          ];
          await getIt<BatchService>().commit(operations);
        } catch (e, s) {
          ErrorHandler.logError(
            'PaymentMethodsController.restoreAll Background',
            e,
            s,
          );
        }
      });
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.restoreAll', e, s);
      rethrow;
    }
  }

  Future<void> updateBalance(String methodId, double amount) async {
    try {
      final index = _paymentMethods.indexWhere((p) => p.id == methodId);
      if (index != -1) {
        final pm = _paymentMethods[index];
        _paymentMethods[index] = pm.copyWith(balance: pm.balance + amount);
        notifyListeners();

        Future.microtask(() async {
          try {
            final operations = <BatchOperation>[
              _paymentMethodRepository.getIncrementBalanceOperation(
                userId,
                methodId,
                amount,
              ),
            ];
            await getIt<BatchService>().commit(operations);
          } catch (e, s) {
            ErrorHandler.logError(
              'PaymentMethodsController.updateBalance Background',
              e,
              s,
            );
          }
        });
      }
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.updateBalance', e, s);
      rethrow;
    }
  }

  void syncFromBin(List<PaymentMethod> updatedDeletedList) {
    _deletedPaymentMethods = List.from(updatedDeletedList);
    notifyListeners();
  }
}

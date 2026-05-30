import 'package:cashly/core/services/currency_service.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/features/payment_methods/presentation/controllers/payment_methods_controller.dart';
import 'package:cashly/features/payment_methods/presentation/pages/transfer_page.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:cashly/core/services/batch_service.dart';

class _MockPaymentMethodRepository implements PaymentMethodRepository {
  List<Map<String, dynamic>> methods = [];

  @override
  BatchOperation getAddPaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getUpdatePaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getDeletePaymentMethodOperation(String userId, String id) => DummyBatchOperation();
  @override
  BatchOperation getAddTransferOperation(String userId, Map<String, dynamic> transfer) => DummyBatchOperation();

  @override
  Future<void> addDeletedPaymentMethod(
    String userId,
    Map<String, dynamic> method,
  ) async {}

  @override
  Future<void> addPaymentMethod(
    String userId,
    Map<String, dynamic> method,
  ) async {}

  @override
  Future<void> addTransfer(
    String userId,
    Map<String, dynamic> transfer,
  ) async {}

  @override
  Future<void> deletePaymentMethod(String userId, String id) async {}

  @override
  Future<void> deleteTransfer(String userId, String transferId) async {}

  @override
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId) => [];

  @override
  String? getDefaultPaymentMethod(String userId) => null;

  @override
  List<Map<String, dynamic>> getPaymentMethods(String userId) => methods;

  @override
  List<Map<String, dynamic>> getTransfers(String userId) => [];

  @override
  Future<void> removeDeletedPaymentMethod(String userId, String id) async {}

  @override
  Future<void> saveDefaultPaymentMethod(String userId, String? id) async {}

  @override
  Future<void> updatePaymentMethod(
    String userId,
    Map<String, dynamic> method,
  ) async {}

  @override
  Future<void> updateTransfer(
    String userId,
    Map<String, dynamic> transfer,
  ) async {}
}

class DummyBatchOperation implements BatchOperation {
  @override
  BatchOperationType get type => BatchOperationType.set;
  @override
  String get collectionPath => '';
  @override
  String get documentId => '';
  @override
  Map<String, dynamic>? get data => null;
}

class MockBatchService implements BatchService {
  @override
  Future<void> commit(List<BatchOperation> operations) async {}
}
void main() {
  setUp(() async {
    await GetIt.instance.reset();
    GetIt.instance.registerLazySingleton<CurrencyService>(
      () => CurrencyService(),
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('secilmis hesap listeden kalkarsa transfer sayfasi crash olmaz', (
    tester,
  ) async {
    final repo = _MockPaymentMethodRepository();
    final controller = PaymentMethodsController(
      paymentMethodRepository: repo,
      userId: 'user-1',
    );
    controller.initData([
      PaymentMethod(
        id: 'cash',
        name: 'Nakit',
        type: 'nakit',
        balance: 1000,
        colorIndex: 0,
        createdAt: DateTime(2026, 1, 1),
      ),
    ], []);
    controller.setTransferFromAccountId('deleted-account');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: TransferPage(
          paymentMethods: const [],
          transfers: const [],
          controller: controller,
          onTransfer: (_, _, _, _) {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(TransferPage), findsOneWidget);
  });
}

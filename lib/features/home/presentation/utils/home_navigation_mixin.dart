import 'package:flutter/material.dart';
import '../../../assets/presentation/pages/assets_page.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../analysis/presentation/pages/analysis_page.dart';
import '../../../payment_methods/presentation/pages/payment_methods_page.dart';
import '../../../payment_methods/presentation/pages/payment_method_detail_page.dart';
import '../../../payment_methods/presentation/pages/transfer_page.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../payment_methods/data/models/transfer_model.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';
import '../../../income/presentation/pages/incomes_page.dart';
import '../../../income/data/models/income_model.dart';

/// Ana sayfa navigasyon işlemleri için mixin
/// Home page'de kullanılan tüm navigasyon metodlarını içerir
mixin HomeNavigationMixin<T extends StatefulWidget> on State<T> {
  // State referansları - Alt sınıfta tanımlanmalı
  List<Asset> get varliklar;
  set varliklar(List<Asset> value);

  List<Map<String, dynamic>> get tumHarcamalar;
  set tumHarcamalar(List<Map<String, dynamic>> value);

  List<Income> get tumGelirler;
  set tumGelirler(List<Income> value);

  List<PaymentMethod> get tumOdemeYontemleri;
  set tumOdemeYontemleri(List<PaymentMethod> value);

  List<Transfer> get tumTransferler;

  double get butceLimiti;
  DateTime get secilenAy;
  String? get varsayilanOdemeYontemiId;
  String? get userId;
  String? get userName;

  Map<String, IconData> get kategoriIkonlari;
  Map<String, IconData> get gelirKategoriIkonlari;

  // Kayıt metodları - Alt sınıfta tanımlanmalı
  void varliklariKaydet();
  void harcamalariKaydet();
  void gelirleriKaydet();
  void odemeYontemleriKaydet();
  void transferleriKaydet();
  void verileriOku();

  /// Varlıklar sayfasına git
  void navigateToAssets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetsPage(
          assets: varliklar.where((a) => !a.isDeleted).toList(),
          deletedAssets: varliklar.where((a) => a.isDeleted).toList(),
          onDelete: (asset) {
            asset.isDeleted = true;
            varliklar = List.from(varliklar); // trigger notifyListeners
            varliklariKaydet();
          },
          onEdit: (asset) {
            final index = varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              varliklar[index] = asset;
              varliklar = List.from(varliklar); // trigger notifyListeners
            }
            varliklariKaydet();
          },
          onRestore: (asset) {
            asset.isDeleted = false;
            varliklar = List.from(varliklar); // trigger notifyListeners
            varliklariKaydet();
          },
          onPermanentDelete: (asset) {
            varliklar.remove(asset);
            varliklar = List.from(varliklar); // trigger notifyListeners
            varliklariKaydet();
          },
          onEmptyBin: () {
            varliklar.removeWhere((a) => a.isDeleted);
            varliklar = List.from(varliklar); // trigger notifyListeners
            varliklariKaydet();
          },
          onAdd: (name, amount, quantity, category, type) {
            varliklar.add(
              Asset(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                amount: amount,
                quantity: quantity,
                category: category,
                type: type,
                lastUpdated: DateTime.now(),
                isDeleted: false,
              ),
            );
            varliklar = List.from(varliklar); // trigger notifyListeners
            varliklariKaydet();
          },
        ),
      ),
    ).then((_) => verileriOku()); // Sayfadan döndüğünde verileri yenile
  }

  /// Analiz sayfasina git
  void navigateToAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisPage(
          expenses: tumHarcamalar,
          assets: varliklar,
          incomes: tumGelirler,
          selectedDate: secilenAy,
          userId: userId ?? '',
          userName: userName ?? 'Kullanici',
          paymentMethods: tumOdemeYontemleri,
        ),
      ),
    ).then((_) => verileriOku()); // Sayfadan döndüğünde verileri yenile
  }

  /// Ödeme yöntemleri sayfasına git
  void navigateToPaymentMethods() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodsPage(
          paymentMethods: tumOdemeYontemleri
              .where((p) => !p.isDeleted)
              .toList(),
          deletedPaymentMethods: tumOdemeYontemleri
              .where((p) => p.isDeleted)
              .toList(),
          onDelete: (pm) {
            final index = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
            if (index != -1) {
              tumOdemeYontemleri[index] = pm.copyWith(isDeleted: true);
              tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            }
            odemeYontemleriKaydet();
          },
          onEdit: (pm) {
            final index = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
            if (index != -1) {
              tumOdemeYontemleri[index] = pm;
              tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            }
            odemeYontemleriKaydet();
          },
          onRestore: (pm) {
            final index = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
            if (index != -1) {
              tumOdemeYontemleri[index] = pm.copyWith(isDeleted: false);
              tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            }
            odemeYontemleriKaydet();
          },
          onPermanentDelete: (pm) {
            tumOdemeYontemleri.removeWhere((p) => p.id == pm.id);
            tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            odemeYontemleriKaydet();
          },
          onEmptyBin: () {
            tumOdemeYontemleri.removeWhere((p) => p.isDeleted);
            tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            odemeYontemleriKaydet();
          },
          onAdd: (name, type, lastFourDigits, balance, limit, colorIndex) {
            tumOdemeYontemleri.add(
              PaymentMethod(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                type: type,
                lastFourDigits: lastFourDigits,
                balance: balance,
                limit: limit,
                colorIndex: colorIndex,
                createdAt: DateTime.now(),
                isDeleted: false,
              ),
            );
            tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            odemeYontemleriKaydet();
          },
          onCardTap: (pm) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentMethodDetailPage(
                  paymentMethod: pm,
                  harcamalar: tumHarcamalar,
                  gelirler: tumGelirler,
                  transferler: tumTransferler,
                  tumOdemeYontemleri: tumOdemeYontemleri,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Transfer sayfasına git
  void navigateToTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferPage(
          userId: userId,
          paymentMethods: tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
          transfers: tumTransferler,
          onTransfer: (fromId, toId, amount, date) {
            // Tarihi kontrol et - bugün mü yoksa ileri tarih mi?
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final transferDate = DateTime(date.year, date.month, date.day);
            final isScheduled = transferDate.isAfter(today);

            if (!isScheduled) {
              // Gönderen hesap
              final fromIndex = tumOdemeYontemleri.indexWhere(
                (pm) => pm.id == fromId,
              );
              if (fromIndex != -1) {
                final fromPm = tumOdemeYontemleri[fromIndex];
                double yeniBakiye = fromPm.type == 'kredi'
                    ? fromPm.balance + amount
                    : fromPm.balance - amount;
                tumOdemeYontemleri[fromIndex] = fromPm.copyWith(
                  balance: yeniBakiye,
                );
              }

              // Alan hesap
              final toIndex = tumOdemeYontemleri.indexWhere(
                (pm) => pm.id == toId,
              );
              if (toIndex != -1) {
                final toPm = tumOdemeYontemleri[toIndex];
                double yeniBakiye = toPm.type == 'kredi'
                    ? toPm.balance - amount
                    : toPm.balance + amount;
                tumOdemeYontemleri[toIndex] = toPm.copyWith(
                  balance: yeniBakiye,
                );
              }
              tumOdemeYontemleri = List.from(tumOdemeYontemleri);
              odemeYontemleriKaydet();
            }

            transferleriKaydet();
          },
        ),
      ),
    );
  }

  /// Harcamalar sayfasına git
  void navigateToExpenses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpensesPage(
          tumHarcamalar: tumHarcamalar,
          tumOdemeYontemleri: tumOdemeYontemleri,
          kategoriIkonlari: kategoriIkonlari,
          butceLimiti: butceLimiti,
          secilenAy: secilenAy,
          userId: userId,
          varsayilanOdemeYontemiId: varsayilanOdemeYontemiId,
          onHarcamalarChanged: (harcamalar) {
            tumHarcamalar = harcamalar;
            harcamalariKaydet();
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            tumOdemeYontemleri = odemeYontemleri;
            odemeYontemleriKaydet();
          },
        ),
      ),
    ).then((_) => verileriOku());
  }

  /// Gelirler sayfasına git
  void navigateToIncomes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomesPage(
          tumGelirler: tumGelirler,
          tumOdemeYontemleri: tumOdemeYontemleri,
          gelirKategoriIkonlari: gelirKategoriIkonlari,
          secilenAy: secilenAy,
          userId: userId,
          onGelirlerChanged: (gelirler) {
            tumGelirler = gelirler;
            gelirleriKaydet();
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            tumOdemeYontemleri = odemeYontemleri;
            odemeYontemleriKaydet();
          },
        ),
      ),
    ).then((_) => verileriOku());
  }
}

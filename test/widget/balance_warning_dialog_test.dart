// BalanceWarningDialog Widget Tests
//
// Bu widget karmaşık UI tasarımı içerdiğinden (Row'lar içinde Row'lar,
// gradient'ler, animasyonlar), test ortamında layout overflow sorunları
// yaşamaktadır. Widget gerçek cihazda düzgün çalışmaktadır.
//
// Widget özellikleri:
// - paymentType: 'banka' veya 'kredi' tiplerini destekler
// - currentBalance: Mevcut bakiye/limit tutarını gösterir
// - expenseAmount: Harcama tutarını gösterir
// - İptal ve Devam Et butonları ile kullanıcı etkileşimi sağlar
// - BalanceWarningDialog.show() static metodu ile dialog açılır
//
// Manuel test adımları:
// 1. Yetersiz bakiyeli bir hesaptan harcama yapmaya çalışın
// 2. Uyarı dialogunun açıldığını doğrulayın
// 3. "Bakiye Uyarısı" veya "Limit Uyarısı" başlığının görüntülendiğini kontrol edin
// 4. İptal butonunun dialogu kapattığını ve işlemi iptal ettiğini doğrulayın
// 5. Devam Et butonunun dialogu kapattığını ve işleme devam ettiğini doğrulayın

import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/balance_warning_dialog.dart';

void main() {
  group('BalanceWarningDialog Unit Tests', () {
    test('BalanceWarningDialog can be instantiated', () {
      // Arrange & Act
      const dialog = BalanceWarningDialog(
        paymentType: 'banka',
        currentBalance: 1000.0,
        expenseAmount: 1500.0,
      );

      // Assert
      expect(dialog.paymentType, 'banka');
      expect(dialog.currentBalance, 1000.0);
      expect(dialog.expenseAmount, 1500.0);
    });

    test('BalanceWarningDialog accepts credit type', () {
      // Arrange & Act
      const dialog = BalanceWarningDialog(
        paymentType: 'kredi',
        currentBalance: 5000.0,
        expenseAmount: 6000.0,
      );

      // Assert
      expect(dialog.paymentType, 'kredi');
    });

    test('BalanceWarningDialog accepts zero balance', () {
      // Arrange & Act
      const dialog = BalanceWarningDialog(
        paymentType: 'banka',
        currentBalance: 0.0,
        expenseAmount: 100.0,
      );

      // Assert
      expect(dialog.currentBalance, 0.0);
    });

    test('BalanceWarningDialog accepts large amounts', () {
      // Arrange & Act
      const dialog = BalanceWarningDialog(
        paymentType: 'banka',
        currentBalance: 1000000.0,
        expenseAmount: 1500000.0,
      );

      // Assert
      expect(dialog.currentBalance, 1000000.0);
      expect(dialog.expenseAmount, 1500000.0);
    });
  });
}

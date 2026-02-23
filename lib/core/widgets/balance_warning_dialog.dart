import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

/// Yetersiz bakiye veya limit uyarısı göstermek için modern tasarımlı diyalog widget'ı.
///
/// Bu widget, kullanıcıya mevcut bakiye/limit durumunu ve planladığı harcama tutarını
/// görsel olarak sunar ve devam etmek isteyip istemediğini sorar.
class BalanceWarningDialog extends StatelessWidget {
  /// Ödeme yönteminin tipi ('kredi', 'banka', 'nakit')
  final String paymentType;

  /// Mevcut bakiye veya kalan limit miktarı
  final double currentBalance;

  /// Plananan harcama tutarı
  final double expenseAmount;

  const BalanceWarningDialog({
    super.key,
    required this.paymentType,
    required this.currentBalance,
    required this.expenseAmount,
  });

  /// Uyarı diyaloğunu gösterir ve kullanıcının onayını döndürür.
  ///
  /// Kullanıcı "Devam Et" butonuna tıklarsa `true`, "İptal" veya dışarı tıklarsa `false` döner.
  static Future<bool?> show({
    required BuildContext context,
    required String paymentType,
    required double currentBalance,
    required double expenseAmount,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Uyarı',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: BalanceWarningDialog(
                paymentType: paymentType,
                currentBalance: currentBalance,
                expenseAmount: expenseAmount,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = paymentType == 'kredi';
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isCredit),
          _buildContent(context, isCredit, theme),
        ],
      ),
    );
  }

  /// Üst kısım - Animasyonlu ikon ve başlık
  Widget _buildHeader(bool isCredit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange.withValues(alpha: 0.15), Colors.transparent],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Animasyonlu uyarı ikonu
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orange.shade400, Colors.orange.shade700],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            isCredit ? 'Limit Uyarısı' : 'Bakiye Uyarısı',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// İçerik kısmı - Detay kartı, soru ve butonlar
  Widget _buildContent(BuildContext context, bool isCredit, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // Detay kartı
          _buildDetailCard(context, isCredit, theme),
          const SizedBox(height: 16),
          // Onay sorusu
          Text(
            'Yine de devam etmek istiyor musunuz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          // Butonlar
          _buildButtons(context, theme),
        ],
      ),
    );
  }

  /// Bakiye/Limit ve harcama tutarı detay kartı
  Widget _buildDetailCard(
    BuildContext context,
    bool isCredit,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Mevcut bakiye/limit satırı
          _buildBalanceRow(context, isCredit, theme),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              height: 1,
            ),
          ),
          // Harcama tutarı satırı
          _buildExpenseRow(context, theme),
        ],
      ),
    );
  }

  /// Mevcut bakiye/limit satırı
  Widget _buildBalanceRow(
    BuildContext context,
    bool isCredit,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCredit ? Icons.credit_score : Icons.account_balance_wallet,
                color: Colors.green,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isCredit ? 'Kalan Limit' : 'Mevcut Bakiye',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          CurrencyFormatter.format(currentBalance),
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Harcama tutarı satırı
  Widget _buildExpenseRow(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.red,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Harcama Tutarı',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          CurrencyFormatter.format(expenseAmount),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// İptal ve Devam Et butonları
  Widget _buildButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // İptal butonu
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Text(
              'İptal',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Devam Et butonu
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade700],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Devam Et',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

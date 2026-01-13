import 'package:flutter/material.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import '../../constants/color_constants.dart';

/// Ödeme yöntemi seçici widget'ı
/// Harcama ve gelir girişlerinde ödeme yöntemi seçimi için yeniden kullanılabilir.
class PaymentMethodSelector extends StatelessWidget {
  final String? selectedPaymentMethodId;
  final List<PaymentMethod> paymentMethods;
  final Function(String?) onChanged;
  final String? labelText;
  final Color? accentColor;
  final bool isExpanded;
  final bool allowNull;
  final String? nullOptionText;

  const PaymentMethodSelector({
    super.key,
    required this.selectedPaymentMethodId,
    required this.paymentMethods,
    required this.onChanged,
    this.labelText = 'Ödeme Yöntemi',
    this.accentColor,
    this.isExpanded = true,
    this.allowNull = true,
    this.nullOptionText = 'Ödeme yöntemi seçin',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? ColorConstants.kirmiziVurgu;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedPaymentMethodId,
                hint: Text(
                  labelText ?? 'Ödeme yöntemi seçin',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                isExpanded: isExpanded,
                dropdownColor: theme.colorScheme.surface,
                items: _buildItems(theme, color),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String?>> _buildItems(ThemeData theme, Color color) {
    final items = <DropdownMenuItem<String?>>[];

    // Null seçeneği opsiyonel
    if (allowNull) {
      items.add(
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            nullOptionText ?? 'Ödeme yöntemi seçin',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    // Ödeme yöntemlerini ekle
    for (final pm in paymentMethods) {
      items.add(
        DropdownMenuItem<String?>(
          value: pm.id,
          child: Row(
            children: [
              _getPaymentMethodIcon(pm.type, color),
              const SizedBox(width: 8),
              Expanded(child: Text(pm.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      );
    }

    return items;
  }

  Widget _getPaymentMethodIcon(String type, Color color) {
    IconData icon;
    switch (type.toLowerCase()) {
      case 'banka':
        icon = Icons.account_balance;
        break;
      case 'kredi kartı':
        icon = Icons.credit_card;
        break;
      case 'nakit':
        icon = Icons.money;
        break;
      case 'dijital cüzdan':
        icon = Icons.account_balance_wallet;
        break;
      default:
        icon = Icons.payment;
    }
    return Icon(icon, size: 20, color: color);
  }

  /// Harcama için ödeme yöntemi seçici (kırmızı tema)
  static PaymentMethodSelector expense({
    Key? key,
    required String? selectedPaymentMethodId,
    required List<PaymentMethod> paymentMethods,
    required Function(String?) onChanged,
  }) {
    return PaymentMethodSelector(
      key: key,
      selectedPaymentMethodId: selectedPaymentMethodId,
      paymentMethods: paymentMethods,
      onChanged: onChanged,
      accentColor: ColorConstants.kirmiziVurgu,
    );
  }

  /// Gelir için ödeme yöntemi seçici (yeşil tema)
  static PaymentMethodSelector income({
    Key? key,
    required String? selectedPaymentMethodId,
    required List<PaymentMethod> paymentMethods,
    required Function(String?) onChanged,
  }) {
    return PaymentMethodSelector(
      key: key,
      selectedPaymentMethodId: selectedPaymentMethodId,
      paymentMethods: paymentMethods,
      onChanged: onChanged,
      accentColor: Colors.green,
    );
  }
}

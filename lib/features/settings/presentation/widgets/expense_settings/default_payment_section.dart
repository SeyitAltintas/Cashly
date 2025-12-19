import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme_manager.dart';
import '../../../../payment_methods/data/models/payment_method_model.dart';

/// Varsayılan ödeme yöntemi seçimi widget'ı
class DefaultPaymentSection extends StatelessWidget {
  final List<PaymentMethod> odemeYontemleri;
  final String? varsayilanOdemeYontemiId;
  final ValueChanged<String?> onChanged;

  const DefaultPaymentSection({
    super.key,
    required this.odemeYontemleri,
    required this.varsayilanOdemeYontemiId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "VARSAYILAN ÖDEME YÖNTEMİ",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: odemeYontemleri.isEmpty
              ? _buildEmptyState(context)
              : _buildDropdown(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Henüz ödeme yöntemi eklemediniz. Araçlar sayfasından ekleyebilirsiniz.",
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.credit_card,
          color: context.watch<ThemeManager>().isDefaultTheme
              ? Colors.white
              : Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: varsayilanOdemeYontemiId,
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              isExpanded: true,
              hint: Text(
                'Seçiniz',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'İlk ödeme yöntemini kullan',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                ...odemeYontemleri.map((pm) {
                  return DropdownMenuItem<String?>(
                    value: pm.id,
                    child: Row(
                      children: [
                        Icon(
                          pm.type == 'nakit'
                              ? Icons.wallet
                              : pm.type == 'kredi'
                              ? Icons.credit_card
                              : Icons.account_balance,
                          size: 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pm.lastFourDigits != null
                                ? '${pm.name} ****${pm.lastFourDigits}'
                                : pm.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

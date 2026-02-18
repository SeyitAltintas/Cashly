import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64B5F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Color(0xFF64B5F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.defaultPaymentMethod,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // İçerik
          Padding(
            padding: const EdgeInsets.all(16),
            child: odemeYontemleri.isEmpty
                ? _buildEmptyState(context)
                : _buildDropdown(context),
          ),
        ],
      ),
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
            context.l10n.noPaymentMethodAdded,
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
        Icon(Icons.credit_card, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: varsayilanOdemeYontemiId,
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              isExpanded: true,
              hint: Text(
                context.l10n.select,
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
                    context.l10n.useFirstPaymentMethod,
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

import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/utils/currency_formatter.dart';
import 'package:cashly/core/constants/card_color_constants.dart';
import 'package:cashly/core/widgets/obscured_amount_text.dart';
import '../../data/models/payment_method_model.dart';
import '../controllers/payment_methods_controller.dart';
import 'package:flutter/services.dart';
import '../pages/add_payment_method_page.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';

class RealisticPaymentCard extends StatelessWidget {
  final PaymentMethod pm;
  final PaymentMethodsController controller;
  final Function(PaymentMethod) onDelete;
  final Function(PaymentMethod) onEdit;
  final Function(PaymentMethod)? onCardTap;
  final bool isObscured;

  const RealisticPaymentCard({
    super.key,
    required this.pm,
    required this.controller,
    required this.onDelete,
    required this.onEdit,
    this.onCardTap,
    this.isObscured = false,
  });

  void _showLongPressMenu(BuildContext context) {
    HapticService.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              pm.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.edit),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPaymentMethodPage(
                      paymentMethod: pm,
                      onSave:
                          (
                            name,
                            type,
                            lastFourDigits,
                            balance,
                            limit,
                            colorIndex,
                          ) async {
                            try {
                              final updatedPm = PaymentMethod(
                                id: pm.id,
                                name: name,
                                type: type,
                                lastFourDigits: lastFourDigits,
                                balance: balance,
                                limit: limit,
                                colorIndex: colorIndex,
                                createdAt: pm.createdAt,
                                isDeleted: false,
                                paraBirimi: pm.paraBirimi,
                              );
                              await controller.updateMethod(updatedPm);
                              onEdit(updatedPm);
                            } catch (e) {
                              if (!context.mounted) return;
                              if (e is AppException) {
                                ErrorHandler.handleAppException(context, e);
                              }
                            }
                          },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                context.l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await controller.moveToBin(pm);
                  onDelete(pm);
                } catch (e) {
                  if (context.mounted && e is AppException) {
                    ErrorHandler.handleAppException(context, e);
                  }
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CardColorConstants.getGradient(pm.colorIndex);
    // Minimalist Apple Card Style: Soft gradient with a matte finish

    // Determine text color based on the primary background color brightness
    final isBgLight =
        ThemeData.estimateBrightnessForColor(colors[0]) == Brightness.light;
    final textColor = isBgLight ? Colors.black87 : Colors.white;
    final subTextColor = isBgLight ? Colors.black54 : Colors.white70;

    return GestureDetector(
      onLongPress: () => _showLongPressMenu(context),
      onTap: onCardTap != null ? () => onCardTap!(pm) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            // Inner highlight for metallic matte feel
            BoxShadow(
              color: Colors.white.withValues(alpha: isBgLight ? 0.5 : 0.1),
              blurRadius: 1,
              spreadRadius: -1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle noise overlay for matte texture (optional, simulated with gradient)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.5, -0.5),
                      radius: 1.5,
                      colors: [
                        Colors.white.withValues(alpha: isBgLight ? 0.3 : 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Chip and NFC
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip
                        Container(
                          width: 42,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFD700), Color(0xFFD4AF37)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: CustomPaint(painter: _ChipPainter()),
                        ),
                        // NFC / Network Icon
                        Icon(
                          Icons.wifi,
                          color: textColor.withValues(alpha: 0.7),
                          size: 28,
                        ),
                      ],
                    ),

                    // Middle Row: Card Number
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pm.type == 'nakit' ? 'CASH' : 'CARD',
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (pm.type != 'nakit') ...[
                              _buildHiddenDigits(textColor),
                              const SizedBox(width: 12),
                              _buildHiddenDigits(textColor),
                              const SizedBox(width: 12),
                              _buildHiddenDigits(textColor),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              (pm.lastFourDigits ?? '').isEmpty
                                  ? '••••'
                                  : pm.lastFourDigits!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                letterSpacing: 4,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom Row: Name and Balance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KART SAHİBİ',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 9,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pm.name.toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              pm.type == 'kredi'
                                  ? context.l10n.debt.toUpperCase()
                                  : context.l10n.balance.toUpperCase(),
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 9,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ObscuredAmountText(
                              CurrencyFormatter.format(
                                pm.type == 'kredi'
                                    ? pm.balance.abs()
                                    : pm.balance,
                              ),
                              isObscured: isObscured,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHiddenDigits(Color color) {
    return Row(
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw chip lines
    final path = Path();

    // Horizontal lines
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.3);

    path.moveTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.3);

    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.7);

    path.moveTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.7);

    // Vertical center section
    path.addRect(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.4,
        size.height * 0.6,
      ),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HapticService {
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }
}

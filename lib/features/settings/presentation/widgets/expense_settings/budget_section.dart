import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bütçe limiti ayarları bölümü widget'ı
class BudgetSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaved;
  final VoidCallback onSave;
  final String? savedMessage;

  const BudgetSection({
    super.key,
    required this.controller,
    required this.isSaved,
    required this.onSave,
    this.savedMessage,
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
                    color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFFFFB74D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Aylık Gelir (Bütçe Limiti)",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ThousandSeparatorFormatter(),
                          LengthLimitingTextInputFormatter(
                            14,
                          ), // Max 10.000.000.000
                        ],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          hintText: 'Tutar girin',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                          suffixText: "₺",
                          suffixStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      width: 90,
                      child: ElevatedButton(
                        onPressed: isSaved ? null : onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF2E7D32),
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: isSaved
                              ? const Icon(
                                  Icons.check,
                                  key: ValueKey('check'),
                                  color: Colors.white,
                                  size: 22,
                                )
                              : const Text(
                                  'Kaydet',
                                  key: ValueKey('save'),
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Kayıt mesajı - Nefes alma animasyonu
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: savedMessage != null && isSaved
                      ? TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, fadeValue, child) {
                            return Opacity(
                              opacity: fadeValue,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - fadeValue)),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _BreathingContainer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        savedMessage!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Binlik ayıraç ekleyen TextInputFormatter
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sadece rakamları al
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Baştaki sıfırları kaldır (tek sıfır hariç)
    String trimmed = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    if (trimmed.isEmpty) trimmed = '0';

    // Binlik ayıraç ekle
    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      if (i > 0 && (trimmed.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Nefes alma animasyonu container'ı
class _BreathingContainer extends StatefulWidget {
  final Widget child;

  const _BreathingContainer({required this.child});

  @override
  State<_BreathingContainer> createState() => _BreathingContainerState();
}

class _BreathingContainerState extends State<_BreathingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}

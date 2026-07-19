import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputDialog extends StatefulWidget {
  final bool isCreating;
  final String? title;
  final Future<bool> Function(String)? onVerify;

  const PinInputDialog({
    super.key,
    this.isCreating = false,
    this.title,
    this.onVerify,
  });

  @override
  State<PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends State<PinInputDialog> {
  String _pin = '';
  String _firstPin = ''; // Used during creation flow to confirm PIN
  bool _isConfirming = false;
  bool _isError = false;
  bool _isLoading = false;

  void _onKeyPress(String key) {
    if (_isLoading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isError = false;
      if (key == 'back') {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_pin.length < 4) {
          _pin += key;
        }
      }
    });

    if (_pin.length == 4) {
      _submitPin();
    }
  }

  Future<void> _submitPin() async {
    if (widget.isCreating) {
      if (!_isConfirming) {
        // First entry done, go to confirmation
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _isConfirming = true;
        });
      } else {
        // Confirmation done
        if (_pin == _firstPin) {
          Navigator.of(context).pop(_pin);
        } else {
          // Pins do not match
          HapticFeedback.heavyImpact();
          setState(() {
            _pin = '';
            _isError = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN kodları eşleşmedi. Tekrar deneyin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Verification flow
      if (widget.onVerify != null) {
        setState(() => _isLoading = true);
        final isValid = await widget.onVerify!(_pin);
        if (mounted) {
          setState(() => _isLoading = false);
          if (isValid) {
            Navigator.of(context).pop(_pin);
          } else {
            HapticFeedback.heavyImpact();
            setState(() {
              _pin = '';
              _isError = true;
            });
          }
        }
      } else {
        Navigator.of(context).pop(_pin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String currentTitle = widget.title ?? 'Güvenlik Kodu';
    if (widget.isCreating) {
      currentTitle = _isConfirming ? 'PIN Kodunu Doğrula' : 'Yeni PIN Kodu Belirle';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top lock icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isError
                    ? colorScheme.errorContainer.withValues(alpha: 0.2)
                    : colorScheme.primaryContainer.withValues(alpha: 0.2),
              ),
              child: Icon(
                _isError ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                color: _isError ? colorScheme.error : colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isError
                  ? 'Hatalı PIN. Tekrar deneyin.'
                  : (widget.isCreating && !_isConfirming
                      ? 'Notlarınızı kilitlemek için 4 haneli kod belirleyin'
                      : 'Devam etmek için 4 haneli PIN kodunu girin'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _isError ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.5),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            // Pin indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final hasChar = index < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 14,
                  width: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isError
                        ? (hasChar ? colorScheme.error : Colors.transparent)
                        : (hasChar ? colorScheme.primary : Colors.transparent),
                    border: Border.all(
                      color: _isError
                          ? colorScheme.error
                          : (hasChar ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.2)),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            if (_isLoading)
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              // Keypad
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey('1'),
                      _buildKey('2'),
                      _buildKey('3'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey('4'),
                      _buildKey('5'),
                      _buildKey('6'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey('7'),
                      _buildKey('8'),
                      _buildKey('9'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey('', isGhost: true),
                      _buildKey('0'),
                      _buildKey('back', isIcon: true),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'İptal',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String val, {bool isIcon = false, bool isGhost = false}) {
    if (isGhost) return const SizedBox(width: 64, height: 64);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(val),
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
          ),
          child: Center(
            child: isIcon
                ? Icon(
                    Icons.backspace_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  )
                : Text(
                    val,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

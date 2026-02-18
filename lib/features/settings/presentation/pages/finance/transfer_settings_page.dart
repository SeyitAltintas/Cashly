import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/services/haptic_service.dart';
import 'state/transfer_settings_state.dart';

/// Para Transferleri Ayarları Sayfası
/// İşlem geçmişinde gösterilecek transfer sayısını ayarlar
class TransferSettingsPage extends StatefulWidget {
  final String userId;

  const TransferSettingsPage({super.key, required this.userId});

  @override
  State<TransferSettingsPage> createState() => _TransferSettingsPageState();
}

class _TransferSettingsPageState extends State<TransferSettingsPage> {
  final SettingsRepository _settingsRepo = getIt<SettingsRepository>();
  late final TransferSettingsState _tsState;
  late final List<int> _limitOptions;

  int get _savedLimit => _tsState.savedLimit;
  int get _tempLimit => _tsState.tempLimit;
  bool get _hasChanged => _tsState.hasChanged;

  @override
  void initState() {
    super.initState();
    _tsState = TransferSettingsState();
    _tsState.addListener(_onStateChanged);

    // 5'ten 200'e kadar sayılar (Tümü seçeneği performans için kaldırıldı)
    _limitOptions = List.generate(196, (i) => i + 5);

    var savedVal = _settingsRepo.getTransferHistoryLimit(widget.userId);
    // Eğer kayıtlı değer geçersizse varsayılana ayarla
    if (!_limitOptions.contains(savedVal)) {
      if (savedVal < 5) {
        savedVal = 5;
      } else if (savedVal > 200) {
        savedVal = 200;
      }
    }
    _tsState.savedLimit = savedVal;
    _tsState.tempLimit = savedVal;
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tsState.removeListener(_onStateChanged);
    _tsState.dispose();
    super.dispose();
  }

  /// Geçici değeri günceller (kaydetmez)
  void _updateTempLimit(int newLimit) {
    if (newLimit != _tempLimit) {
      HapticService.selectionClick();
      _tsState.tempLimit = newLimit;
    }
  }

  /// Seçilen değeri kalıcı olarak kaydeder
  Future<void> _saveCurrentLimit() async {
    if (_tempLimit == _savedLimit) return;

    await HapticService.mediumImpact();
    await _settingsRepo.saveTransferHistoryLimit(widget.userId, _tempLimit);

    _tsState.savedLimit = _tempLimit;
    _tsState.hasChanged = true;

    if (mounted) {
      AppSnackBar.success(
        context,
        context.l10n.historyLimitSaved(_tempLimit),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Limit değerini gösterim metnine çevirir
  String _getLimitDisplayText(int limit) {
    return '$limit';
  }

  /// Kaydet butonu görünür mü?
  bool get _showSaveButton => _tempLimit != _savedLimit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.transferSettingsTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasChanged),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildHistoryLimitSection(context, textColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Sayfa başlığı
  Widget _buildHeader(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.transferSettingsPageTitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.transferSettingsDesc,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// İşlem geçmişi limit seçimi bölümü
  Widget _buildHistoryLimitSection(
    BuildContext context,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.transactionHistoryLimit,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.transactionHistoryLimitDesc,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cupertino tarzı yatay kaydırmalı seçici
          SizedBox(height: 120, child: _buildCupertinoPicker(isDark)),

          // Kaydet yazısı (değer değiştiğinde görünür)
          if (_showSaveButton)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _saveCurrentLimit,
                  child: Text(
                    context.l10n.save,
                    style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Cupertino tarzı yatay kaydırmalı picker
  Widget _buildCupertinoPicker(bool isDark) {
    final selectedIndex = _limitOptions.indexOf(_tempLimit);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Seçili öğe arka plan vurgusu
        Container(
          width: 75,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.teal.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
        ),
        // Yatay kaydırmalı liste
        RotatedBox(
          quarterTurns: -1, // Dikey picker'ı yatay yap
          child: ListWheelScrollView.useDelegate(
            controller: FixedExtentScrollController(
              initialItem: selectedIndex >= 0 ? selectedIndex : 2,
            ),
            itemExtent: 65,
            perspective: 0.005,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              if (index >= 0 && index < _limitOptions.length) {
                _updateTempLimit(_limitOptions[index]);
              }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _limitOptions.length,
              builder: (context, index) {
                final limit = _limitOptions[index];
                final isSelected = _tempLimit == limit;

                return RotatedBox(
                  quarterTurns: 1, // Metni tekrar düz çevir
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.teal
                            : (isDark ? Colors.white60 : Colors.black54),
                        fontSize: isSelected ? 18 : 15,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                      child: Text(_getLimitDisplayText(limit)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

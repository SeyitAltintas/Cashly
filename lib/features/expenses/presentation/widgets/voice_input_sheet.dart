import 'package:flutter/material.dart';
import '../../../../services/speech_service.dart';
import '../../../../services/tts_service.dart';

/// Sesli harcama girişi için modal bottom sheet widget'ı
class VoiceInputSheet extends StatefulWidget {
  final Map<String, IconData> categoryIcons;
  final Function(String name, double amount, String category) onConfirm;
  final String? userId;

  /// Mevcut sesli komut callback'leri
  final Future<Map<String, dynamic>?> Function()? onDeleteLastExpense;
  final double Function()? onGetMonthlyTotal;
  final Map<String, dynamic>? Function()? onGetTopCategory;

  /// Yeni sesli komut callback'leri
  final double Function()? onGetWeeklyTotal;
  final double Function()? onGetDailyTotal;
  final List<Map<String, dynamic>> Function()? onGetLastExpenses;
  final Map<String, dynamic> Function()? onCheckBudget;
  final double Function(String kategori)? onGetCategoryTotal;

  const VoiceInputSheet({
    super.key,
    required this.categoryIcons,
    required this.onConfirm,
    this.userId,
    this.onDeleteLastExpense,
    this.onGetMonthlyTotal,
    this.onGetTopCategory,
    this.onGetWeeklyTotal,
    this.onGetDailyTotal,
    this.onGetLastExpenses,
    this.onCheckBudget,
    this.onGetCategoryTotal,
  });

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();

  bool _isListening = false;
  bool _isInitializing = true;
  bool _hasError = false;
  bool _isEditingValues = false; // Sadece tutar ve isim düzenleme modu
  bool _isCommandMode = false; // Sesli komut modunda mı?
  String _errorMessage = '';
  String _recognizedText = '';
  SpeechParseResult? _parseResult;

  // Düzenleme için controller'lar
  final TextEditingController _tutarController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  String _selectedCategory = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryIcons.isNotEmpty
        ? widget.categoryIcons.keys.first
        : '';
    _initAnimation();
    _initSpeech();
  }

  void _initAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initSpeech() async {
    bool success = await _speechService.initialize();

    if (mounted) {
      setState(() {
        _isInitializing = false;
        if (!success) {
          _hasError = true;
          _errorMessage = 'Mikrofon izni verilemedi veya cihaz desteklemiyor.';
        } else {
          _startListening();
        }
      });
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _isEditingValues = false;
      _isCommandMode = false; // Komut modu sıfırla
      _recognizedText = '';
      _parseResult = null;
      _hasError = false;
    });

    await _speechService.startListening(
      onResult: (text) {
        if (mounted) {
          // Önce sesli komut olup olmadığını kontrol et
          final commandResult = _speechService.detectVoiceCommand(
            text,
            mevcutKategoriler: widget.categoryIcons.keys.toList(),
          );

          if (commandResult.komutAlgilandi) {
            // Komut algılandı - UI'ı güncelle ve işle
            setState(() {
              _recognizedText = text;
              _isCommandMode = true;
              _parseResult = null; // Harcama ekleme UI'ını gösterme
            });
            _handleVoiceCommand(commandResult);
          } else {
            // Normal harcama girişi - parse et
            setState(() {
              _recognizedText = text;
              _isCommandMode = false;
              _parseResult = _speechService.parseText(
                text,
                widget.categoryIcons.keys.toList(),
              );
              // Parse sonucunu düzenleme alanlarına aktar
              if (_parseResult != null && _parseResult!.basarili) {
                _tutarController.text = _parseResult!.tutar!.toStringAsFixed(2);
                _isimController.text =
                    _parseResult!.harcamaIsmi ?? _recognizedText;
                // Kategori tahmini varsa seç, yoksa mevcut seçimi koru
                if (_parseResult!.kategori != null) {
                  _selectedCategory = _parseResult!.kategori!;
                }
              }
            });
          }
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
    );
  }

  /// Sesli komutu işle
  Future<void> _handleVoiceCommand(VoiceCommandResult command) async {
    // Dinlemeyi durdur
    await _speechService.stopListening();

    setState(() {
      _isListening = false;
    });

    switch (command.komutTuru) {
      case VoiceCommandType.sonHarcamayiSil:
        await _handleDeleteLastExpense();
        break;
      case VoiceCommandType.buAyNeKadarHarcadim:
        await _handleGetMonthlyTotal();
        break;
      case VoiceCommandType.enCokHangiKategori:
        await _handleGetTopCategory();
        break;
      case VoiceCommandType.buHaftaNeKadarHarcadim:
        await _handleGetWeeklyTotal();
        break;
      case VoiceCommandType.bugunNeKadarHarcadim:
        await _handleGetDailyTotal();
        break;
      case VoiceCommandType.sonHarcamalariListele:
        await _handleListLastExpenses();
        break;
      case VoiceCommandType.butceyiAstimMi:
        await _handleCheckBudget();
        break;
      case VoiceCommandType.kategoriHarcamasi:
        await _handleGetCategoryTotal(command.kategori);
        break;
      default:
        // Normal harcama ekleme veya bilinmeyen komut
        break;
    }
  }

  /// "Son harcamayı sil" komutunu işle
  Future<void> _handleDeleteLastExpense() async {
    if (widget.onDeleteLastExpense != null) {
      final deletedExpense = await widget.onDeleteLastExpense!();

      if (deletedExpense != null && mounted) {
        await _ttsService.harcamaSilindiBildirimi(
          harcamaIsmi: deletedExpense['isim'] ?? 'Harcama',
          tutar: (deletedExpense['tutar'] as num?)?.toDouble() ?? 0,
          userId: widget.userId,
        );

        // SnackBar göster ve sheet'i kapat
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${deletedExpense['isim']} silindi',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } else if (mounted) {
        await _ttsService.harcamaBulunamadiBildirimi(userId: widget.userId);
      }
    }
  }

  /// "Bu ay ne kadar harcadım?" komutunu işle
  Future<void> _handleGetMonthlyTotal() async {
    if (widget.onGetMonthlyTotal != null) {
      final total = widget.onGetMonthlyTotal!();

      await _ttsService.buAyHarcamaBildirimi(
        toplam: total,
        userId: widget.userId,
      );

      // Sheet'i kapat
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "En çok hangi kategoride harcamışım?" komutunu işle
  Future<void> _handleGetTopCategory() async {
    if (widget.onGetTopCategory != null) {
      final topCategory = widget.onGetTopCategory!();

      if (topCategory != null) {
        await _ttsService.enCokKategoriBildirimi(
          kategori: topCategory['kategori'] ?? 'Bilinmiyor',
          tutar: (topCategory['tutar'] as num?)?.toDouble() ?? 0,
          userId: widget.userId,
        );
      } else {
        await _ttsService.speak(
          'Henüz harcama bulunmuyor',
          userId: widget.userId,
        );
      }

      // Sheet'i kapat
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Bu hafta ne kadar harcadım?" komutunu işle
  Future<void> _handleGetWeeklyTotal() async {
    if (widget.onGetWeeklyTotal != null) {
      final total = widget.onGetWeeklyTotal!();

      await _ttsService.buHaftaHarcamaBildirimi(
        toplam: total,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        'Bu komut henüz desteklenmiyor',
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Bugün ne kadar harcadım?" komutunu işle
  Future<void> _handleGetDailyTotal() async {
    if (widget.onGetDailyTotal != null) {
      final total = widget.onGetDailyTotal!();

      await _ttsService.bugunHarcamaBildirimi(
        toplam: total,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        'Bu komut henüz desteklenmiyor',
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Son harcamalarım neler?" komutunu işle
  Future<void> _handleListLastExpenses() async {
    if (widget.onGetLastExpenses != null) {
      final harcamalar = widget.onGetLastExpenses!();

      await _ttsService.sonHarcamalarBildirimi(
        harcamalar: harcamalar,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        'Bu komut henüz desteklenmiyor',
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Bütçemi aştım mı?" komutunu işle
  Future<void> _handleCheckBudget() async {
    if (widget.onCheckBudget != null) {
      final budgetInfo = widget.onCheckBudget!();

      await _ttsService.butceDurumBildirimi(
        kalanLimit: (budgetInfo['kalanLimit'] as num?)?.toDouble() ?? 0,
        asilanMiktar: (budgetInfo['asilanMiktar'] as num?)?.toDouble() ?? 0,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        'Bu komut henüz desteklenmiyor',
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// Kategori bazlı harcama sorgusunu işle
  Future<void> _handleGetCategoryTotal(String? kategori) async {
    if (kategori == null) {
      await _ttsService.speak('Kategori anlaşılamadı', userId: widget.userId);
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (widget.onGetCategoryTotal != null) {
      final total = widget.onGetCategoryTotal!(kategori);

      await _ttsService.kategoriHarcamaBildirimi(
        kategori: kategori,
        toplam: total,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        'Bu komut henüz desteklenmiyor',
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  void _enableEditingValues() {
    setState(() {
      _isEditingValues = true;
    });
  }

  void _confirm() {
    double? tutar = double.tryParse(_tutarController.text.replaceAll(',', '.'));
    String isim = _isimController.text.trim();

    if (tutar == null || tutar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir tutar girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isim.isEmpty) {
      isim = _recognizedText.isNotEmpty ? _recognizedText : 'Harcama';
    }

    widget.onConfirm(isim, tutar, _selectedCategory);

    // Sesli geri bildirim
    _ttsService.harcamaEklendiBildirimi(
      tutar: tutar,
      harcamaIsmi: isim,
      kategori: _selectedCategory,
      userId: widget.userId,
    );

    Navigator.pop(context);
  }

  /// Yardım dialog'unu göster
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              'Sesli Asistan',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sesli asistan ile şunları yapabilirsiniz:',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              Icons.add_circle_outline,
              'Harcama ekleme',
            ),
            _buildFeatureItem(context, Icons.delete_outline, 'Harcama silme'),
            _buildFeatureItem(
              context,
              Icons.account_balance_wallet,
              'Harcama sorgulama',
            ),
            _buildFeatureItem(context, Icons.pie_chart, 'Kategori analizi'),
            _buildFeatureItem(context, Icons.warning_amber, 'Bütçe kontrolü'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Detaylı komut listesi için:\nAyarlar → Sesli Asistan → Tüm Komutlar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tamam',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Özellik satırı widget'ı
  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechService.dispose();
    _tutarController.dispose();
    _isimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool canConfirm =
        _tutarController.text.isNotEmpty &&
        double.tryParse(_tutarController.text.replaceAll(',', '.')) != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Başlık ve Info butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 40), // Simetri için boşluk
                Expanded(
                  child: Text(
                    'Sesli Asistan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: _showHelpDialog,
                  tooltip: 'Nasıl kullanılır?',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mikrofon animasyonu
            if (_isInitializing)
              _buildLoadingState()
            else if (_hasError)
              _buildErrorState()
            else
              _buildMicrophoneState(),

            const SizedBox(height: 20),

            // Tanınan metin
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duyulan:',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _recognizedText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Komut modunda işlem bilgisi göster
            if (_isCommandMode && _recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Komut işleniyor...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Parse sonucu (Tutar ve İsim) - önizleme veya düzenleme
            // Sadece komut modunda değilse göster
            if (!_isCommandMode &&
                _parseResult != null &&
                _parseResult!.basarili) ...[
              if (_isEditingValues)
                _buildValuesEditForm()
              else
                _buildValuesPreview(),
              const SizedBox(height: 12),
            ],

            // KATEGORİ SEÇİMİ - Her zaman görünür ve düzenlenebilir
            // Sadece komut modunda değilse göster
            if (!_isCommandMode &&
                _parseResult != null &&
                _parseResult!.basarili) ...[
              // Bilgi notu - sola yaslı ve silik
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kategori tahmini yapıldı, değiştirebilirsiniz.',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildCategorySelector(),
              const SizedBox(height: 20),
            ],

            // Butonlar
            if (_isCommandMode)
              // Komut modunda sadece Kapat butonu
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Kapat'),
                ),
              )
            else
              // Normal modda İptal ve Onayla butonları
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canConfirm ? _confirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      child: const Text(
                        'Onayla',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Tutar ve İsim önizlemesi
  Widget _buildValuesPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _buildResultRow(
            'Tutar',
            '${_tutarController.text} ₺',
            Icons.currency_lira,
          ),
          if (_isimController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildResultRow('İsim', _isimController.text, Icons.edit),
          ],
          const SizedBox(height: 12),
          // Düzenle butonu
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _enableEditingValues,
              icon: Icon(
                Icons.edit_note,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              label: Text(
                'Tutar ve İsmi Düzenle',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tutar ve İsim düzenleme formu
  Widget _buildValuesEditForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tutar alanı
          TextField(
            controller: _tutarController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Tutar (₺)',
              labelStyle: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                Icons.currency_lira,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // İsim alanı
          TextField(
            controller: _isimController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Harcama İsmi (opsiyonel)',
              labelStyle: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Önizlemeye dön butonu
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isEditingValues = false;
                });
              },
              child: Text(
                'Tamam',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kategori seçici - HER ZAMAN GÖRÜNÜR
  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          isExpanded: true,
          hint: Row(
            children: [
              Icon(
                Icons.category,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Kategori Seçiniz',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          items: widget.categoryIcons.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                children: [
                  Icon(
                    entry.value,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(entry.key, style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue ?? widget.categoryIcons.keys.first;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Mikrofon hazırlanıyor...',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.1),
          ),
          child: const Icon(Icons.error_outline, size: 40, color: Colors.red),
        ),
        const SizedBox(height: 16),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _initSpeech,
          icon: const Icon(Icons.refresh),
          label: const Text('Tekrar Dene'),
        ),
      ],
    );
  }

  Widget _buildMicrophoneState() {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 40,
                    color: _isListening
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            _isListening ? 'Dinleniyor...' : 'Tekrar konuşmak için dokunun',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

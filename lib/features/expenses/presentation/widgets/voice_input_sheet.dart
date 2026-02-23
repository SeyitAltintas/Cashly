import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/speech/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../controllers/expenses_controller.dart';

/// Sesli harcama girişi için modal bottom sheet widget'ı
class VoiceInputSheet extends StatefulWidget {
  final Map<String, IconData> categoryIcons;
  final Function(String name, double amount, String category, DateTime date)
  onConfirm;
  final String? userId;

  /// Mevcut sesli komut callback'leri
  final Future<Map<String, dynamic>?> Function()? onDeleteLastExpense;
  final double Function()? onGetMonthlyTotal;
  final Map<String, dynamic>? Function()? onGetTopCategory;

  final double Function()? onGetWeeklyTotal;
  final double Function()? onGetDailyTotal;
  final List<Map<String, dynamic>> Function()? onGetLastExpenses;
  final Map<String, dynamic> Function()? onCheckBudget;
  final double Function(String kategori)? onGetCategoryTotal;
  final Future<Map<String, dynamic>> Function()? onAddFixedExpenses;
  final Future<Map<String, dynamic>?> Function(double yeniTutar)?
  onEditLastExpense;

  final double Function(DateTime baslangic, DateTime bitis)?
  onGetDateRangeTotal;
  final double Function(DateTime baslangic, DateTime bitis, String kategori)?
  onGetDateRangeCategoryTotal;

  final Future<void> Function(double yeniLimit)? onSetBudgetLimit;
  final Map<String, dynamic> Function()? onGetSavings;

  /// Controller (opsiyonel)
  final ExpensesController? controller;

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
    this.onAddFixedExpenses,
    this.onEditLastExpense,
    this.onGetDateRangeTotal,
    this.onGetDateRangeCategoryTotal,
    this.onSetBudgetLimit,
    this.onGetSavings,
    this.controller,
  });

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();

  // Controller veya yerel state
  ExpensesController? _controller;
  bool _localIsListening = false;
  bool _localIsInitializing = true;
  bool _localHasError = false;
  bool _localIsCommandMode = false;
  bool _localPendingConfirmation = false;
  String _localConfirmationTitle = '';
  String _localConfirmationMessage = '';
  String _localErrorMessage = '';
  String _localRecognizedText = '';
  SpeechParseResult? _localParseResult;
  String _localSelectedCategory = '';

  // Getter'lar
  bool get _isListening => _controller?.voiceIsListening ?? _localIsListening;
  bool get _isInitializing =>
      _controller?.voiceIsInitializing ?? _localIsInitializing;
  bool get _hasError => _controller?.voiceHasError ?? _localHasError;
  bool get _isCommandMode =>
      _controller?.voiceIsCommandMode ?? _localIsCommandMode;
  String get _errorMessage =>
      _controller?.voiceErrorMessage ?? _localErrorMessage;
  String get _recognizedText =>
      _controller?.voiceRecognizedText ?? _localRecognizedText;
  SpeechParseResult? get _parseResult =>
      _controller?.voiceParseResult ?? _localParseResult;
  bool get _pendingConfirmation =>
      _controller?.voicePendingConfirmation ?? _localPendingConfirmation;
  String get _confirmationTitle =>
      _controller?.voiceConfirmationTitle ?? _localConfirmationTitle;
  String get _confirmationMessage =>
      _controller?.voiceConfirmationMessage ?? _localConfirmationMessage;
  String get _selectedCategory =>
      _controller?.voiceSelectedCategory ?? _localSelectedCategory;

  // Onay callback (state dışında tutulur)
  Future<void> Function()? _onConfirmCallback;

  // Düzenleme için controller'lar
  final TextEditingController _tutarController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onStateChanged);

    // İlk kategoriyi seç
    if (widget.categoryIcons.isNotEmpty) {
      if (_controller != null) {
        _controller!.setVoiceCategory(widget.categoryIcons.keys.first);
      } else {
        _localSelectedCategory = widget.categoryIcons.keys.first;
      }
    }
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
      if (success) {
        if (_controller != null) {
          _controller!.setVoiceInitialized(success: true);
        } else {
          _localIsInitializing = false;
          setState(() {});
        }
        _startListening();
      } else {
        if (_controller != null) {
          _controller!.setVoiceInitialized(
            success: false,
            error: context.l10n.micPermissionDenied,
          );
        } else {
          _localIsInitializing = false;
          _localHasError = true;
          _localErrorMessage = context.l10n.micPermissionDenied;
          setState(() {});
        }
      }
    }
  }

  Future<void> _startListening() async {
    // Android sistem sesi çal - dinleme başladı
    await SystemSound.play(SystemSoundType.click);
    await HapticFeedback.lightImpact();

    // Listening state başlat
    if (_controller != null) {
      _controller!.startVoiceListening();
    } else {
      _localIsListening = true;
      _localIsCommandMode = false;
      _localRecognizedText = '';
      _localParseResult = null;
      _localHasError = false;
      setState(() {});
    }

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
            debugPrint('Komut algılandı: ${commandResult.komutTuru}');
            if (_controller != null) {
              _controller!.setVoiceCommandMode(text);
            } else {
              _localRecognizedText = text;
              _localIsCommandMode = true;
              _localParseResult = null;
              setState(() {});
            }
            // Async olarak işle (callback içinde await yapamıyoruz)
            _handleVoiceCommand(commandResult).catchError((e) {
              debugPrint('_handleVoiceCommand hatası: $e');
            });
          } else {
            // Normal harcama girişi - parse et
            final parseResult = _speechService.parseText(
              text,
              widget.categoryIcons.keys.toList(),
            );
            // State güncelle
            if (_controller != null) {
              _controller!.updateVoiceRecognizedText(text);
              _controller!.setVoiceParseResult(parseResult);
            } else {
              _localRecognizedText = text;
              _localIsCommandMode = false;
              _localParseResult = parseResult;
              setState(() {});
            }
            // Parse sonucunu düzenleme alanlarına aktar
            if (parseResult.basarili) {
              _tutarController.text = parseResult.tutar!.toStringAsFixed(2);
              _isimController.text = parseResult.harcamaIsmi ?? text;
              // Kategori tahmini varsa seç, yoksa mevcut seçimi koru
              if (parseResult.kategori != null) {
                if (_controller != null) {
                  _controller!.setVoiceCategory(parseResult.kategori!);
                } else {
                  _localSelectedCategory = parseResult.kategori!;
                  setState(() {});
                }
              }
            }
          }
        }
      },
      onDone: () {
        if (mounted) {
          if (_controller != null) {
            _controller!.stopVoiceListening();
          } else {
            _localIsListening = false;
            setState(() {});
          }
        }
      },
    );
  }

  /// Sesli komutu işle
  Future<void> _handleVoiceCommand(VoiceCommandResult command) async {
    // Dinlemeyi durdur
    await _speechService.stopListening();

    if (mounted) {
      if (_controller != null) {
        _controller!.stopVoiceListening();
      } else {
        _localIsListening = false;
        setState(() {});
      }
    }

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
      case VoiceCommandType.sabitGiderleriEkle:
        await _handleAddFixedExpenses();
        break;
      case VoiceCommandType.sonHarcamayiDuzenle:
        await _handleEditLastExpense(command.yeniTutar);
        break;
      case VoiceCommandType.dunNeKadarHarcadim:
        await _handleDunNeKadarHarcadim(command.baslangicTarihi!);
        break;
      case VoiceCommandType.gecenHaftaNeKadarHarcadim:
        await _handleGecenHaftaNeKadarHarcadim(
          command.baslangicTarihi!,
          command.bitisTarihi!,
        );
        break;
      case VoiceCommandType.gecenAyNeKadarHarcadim:
        await _handleGecenAyNeKadarHarcadim(
          command.baslangicTarihi!,
          command.bitisTarihi!,
        );
        break;
      case VoiceCommandType.buYilNeKadarHarcadim:
        await _handleBuYilNeKadarHarcadim(
          command.baslangicTarihi!,
          command.bitisTarihi!,
        );
        break;
      case VoiceCommandType.tarihliKategoriHarcamasi:
        await _handleTarihliKategoriHarcamasi(
          command.baslangicTarihi!,
          command.bitisTarihi!,
          command.kategori,
        );
        break;
      case VoiceCommandType.kalanButce:
        await _handleKalanButce();
        break;
      case VoiceCommandType.limitBelirle:
        await _handleLimitBelirle(command.yeniLimit);
        break;
      case VoiceCommandType.tasarrufHesapla:
        await _handleTasarrufHesapla();
        break;
      default:
        // Normal harcama ekleme veya bilinmeyen komut
        break;
    }
  }

  /// "Son harcamayı sil" komutunu işle
  Future<void> _handleDeleteLastExpense() async {
    if (widget.onDeleteLastExpense != null) {
      // Inline onay iste
      _requestConfirmation(
        baslik: 'Harcama Silme',
        mesaj: 'Son eklenen harcamayı silmek istediğinizden emin misiniz?',
        onConfirm: () async {
          final deletedExpense = await widget.onDeleteLastExpense!();

          if (deletedExpense != null && mounted) {
            await _ttsService.harcamaSilindiBildirimi(
              harcamaIsmi: deletedExpense['isim'] ?? 'Harcama',
              tutar: (deletedExpense['tutar'] as num?)?.toDouble() ?? 0,
              userId: widget.userId,
            );

            // SnackBar göster ve sheet'i kapat
            if (mounted) {
              AppSnackBar.deleted(context, '${deletedExpense['isim']} silindi');
              Navigator.pop(context);
            }
          } else if (mounted) {
            await _ttsService.harcamaBulunamadiBildirimi(userId: widget.userId);
            if (mounted) Navigator.pop(context);
          }
        },
      );
    } else {
      if (mounted) Navigator.pop(context);
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
          kategori: topCategory['kategori'] ?? context.l10n.unknown,
          tutar: (topCategory['tutar'] as num?)?.toDouble() ?? 0,
          userId: widget.userId,
        );
      } else {
        await _ttsService.speak(
          context.l10n.noExpenseFoundYet,
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
        context.l10n.commandNotSupported,
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
        context.l10n.commandNotSupported,
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
        context.l10n.commandNotSupported,
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
        context.l10n.commandNotSupported,
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
      await _ttsService.speak(
        context.l10n.categoryNotUnderstood,
        userId: widget.userId,
      );
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
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Tekrarlayan işlemleri ekle" komutunu işle
  Future<void> _handleAddFixedExpenses() async {
    if (widget.onAddFixedExpenses != null) {
      // Inline onay iste
      _requestConfirmation(
        baslik: context.l10n.recurringTransactionsLabel,
        mesaj: context.l10n.addRecurringToMonthConfirm,
        onConfirm: () async {
          final result = await widget.onAddFixedExpenses!();

          await _ttsService.sabitGiderlerEklendiBildirimi(
            adet: (result['adet'] as int?) ?? 0,
            toplam: (result['toplam'] as num?)?.toDouble() ?? 0,
            userId: widget.userId,
          );

          if (mounted) {
            if ((result['adet'] as int?) != null &&
                (result['adet'] as int) > 0) {
              AppSnackBar.success(
                context,
                context.l10n.recurringItemsAdded(result['adet'] as int),
              );
            }
            Navigator.pop(context);
          }
        },
      );
    } else {
      await _ttsService.speak(
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Son harcamayı X lira yap" komutunu işle
  Future<void> _handleEditLastExpense(double? yeniTutar) async {
    if (yeniTutar == null) {
      await _ttsService.speak(
        context.l10n.newAmountNotUnderstood,
        userId: widget.userId,
      );
      if (mounted) Navigator.pop(context);
      return;
    }

    if (widget.onEditLastExpense != null) {
      // Inline onay iste
      _requestConfirmation(
        baslik: context.l10n.expenseEditingTitle,
        mesaj: context.l10n.updateExpenseAmountMsg(
          yeniTutar.toStringAsFixed(0),
        ),
        onConfirm: () async {
          Map<String, dynamic>? result;
          try {
            result = await widget.onEditLastExpense!(yeniTutar);
          } catch (e) {
            // Hata durumunda (harcama bulunamadı vb.)
            debugPrint('Harcama düzenleme hatası: $e');
            await _ttsService.harcamaBulunamadiBildirimi(userId: widget.userId);
            if (mounted) Navigator.pop(context);
            return;
          }

          if (result != null) {
            final harcamaIsmi = result['isim'] ?? 'Harcama';
            final eskiTutar = (result['eskiTutar'] as num?)?.toDouble() ?? 0;
            final silindi = result['silindi'] == true;

            if (silindi) {
              // 0 TL ile silme durumu
              await _ttsService.harcamaSilindiBildirimi(
                harcamaIsmi: harcamaIsmi,
                tutar: eskiTutar,
                userId: widget.userId,
              );

              if (mounted) {
                AppSnackBar.deleted(
                  context,
                  context.l10n.expenseDeleted(harcamaIsmi),
                );
                Navigator.pop(context);
              }
            } else {
              // Normal güncelleme
              await _ttsService.harcamaDuzenlendiBildirimi(
                harcamaIsmi: harcamaIsmi,
                eskiTutar: eskiTutar,
                yeniTutar: yeniTutar,
                userId: widget.userId,
              );

              if (mounted) {
                AppSnackBar.info(
                  context,
                  '$harcamaIsmi güncellendi: ${yeniTutar.toStringAsFixed(0)} ₺',
                );
                Navigator.pop(context);
              }
            }
          } else {
            await _ttsService.harcamaBulunamadiBildirimi(userId: widget.userId);
            if (mounted) Navigator.pop(context);
          }
        },
      );
    } else {
      await _ttsService.speak(
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  /// "Dün ne kadar harcadım?" komutunu işle
  Future<void> _handleDunNeKadarHarcadim(DateTime tarih) async {
    if (widget.onGetDateRangeTotal != null) {
      final total = widget.onGetDateRangeTotal!(tarih, tarih);

      await _ttsService.dunHarcamaBildirimi(
        toplam: total,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Geçen hafta ne kadar harcadım?" komutunu işle
  Future<void> _handleGecenHaftaNeKadarHarcadim(
    DateTime baslangic,
    DateTime bitis,
  ) async {
    if (widget.onGetDateRangeTotal != null) {
      final total = widget.onGetDateRangeTotal!(baslangic, bitis);

      await _ttsService.gecenHaftaHarcamaBildirimi(
        toplam: total,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Geçen ay ne kadar harcadım?" komutunu işle
  Future<void> _handleGecenAyNeKadarHarcadim(
    DateTime baslangic,
    DateTime bitis,
  ) async {
    if (widget.onGetDateRangeTotal != null) {
      final total = widget.onGetDateRangeTotal!(baslangic, bitis);

      await _ttsService.gecenAyHarcamaBildirimi(
        toplam: total,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Bu yıl ne kadar harcadım?" komutunu işle
  Future<void> _handleBuYilNeKadarHarcadim(
    DateTime baslangic,
    DateTime bitis,
  ) async {
    if (widget.onGetDateRangeTotal != null) {
      final total = widget.onGetDateRangeTotal!(baslangic, bitis);

      await _ttsService.buYilHarcamaBildirimi(
        toplam: total,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// Tarihli kategori sorgusunu işle ("Dün markete ne kadar harcadım?")
  Future<void> _handleTarihliKategoriHarcamasi(
    DateTime baslangic,
    DateTime bitis,
    String? kategori,
  ) async {
    if (kategori == null) {
      await _ttsService.speak(
        context.l10n.categoryNotUnderstood,
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (widget.onGetDateRangeCategoryTotal != null) {
      final total = widget.onGetDateRangeCategoryTotal!(
        baslangic,
        bitis,
        kategori,
      );

      // Dönem adını belirle
      String donem;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateDiff = today.difference(baslangic).inDays;

      if (dateDiff == 1 && baslangic == bitis) {
        donem = context.l10n.yesterday;
      } else if (dateDiff <= 7) {
        donem = context.l10n.thisWeek;
      } else if (dateDiff <= 14) {
        donem = context.l10n.lastWeek;
      } else {
        donem = context.l10n.lastMonth;
      }

      await _ttsService.tarihliKategoriHarcamaBildirimi(
        donem: donem,
        kategori: kategori,
        toplam: total,
        userId: widget.userId,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      await _ttsService.speak(
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Kalan bütçem ne kadar?" komutunu işle
  Future<void> _handleKalanButce() async {
    debugPrint('_handleKalanButce başladı');
    try {
      if (widget.onCheckBudget != null) {
        debugPrint('onCheckBudget mevcut, çağrılıyor...');
        final budgetInfo = widget.onCheckBudget!();
        debugPrint('budgetInfo: $budgetInfo');
        final kalanLimit = (budgetInfo['kalanLimit'] as num?)?.toDouble() ?? 0;
        final butceLimiti =
            (budgetInfo['butceLimiti'] as num?)?.toDouble() ?? 8000;
        debugPrint('kalanLimit: $kalanLimit, butceLimiti: $butceLimiti');

        await _ttsService.kalanButceBildirimi(
          kalanButce: kalanLimit,
          butceLimiti: butceLimiti,
          userId: widget.userId,
        );
        debugPrint('TTS bildirimi tamamlandı');
      } else {
        debugPrint('onCheckBudget null!');
        await _ttsService.speak(
          context.l10n.commandNotSupported,
          userId: widget.userId,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('_handleKalanButce hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      await _ttsService.speak(
        context.l10n.anErrorOccurred,
        userId: widget.userId,
      );
    } finally {
      debugPrint('_handleKalanButce finally bloğu, mounted: $mounted');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// "Aylık limitimi X lira yap" komutunu işle
  Future<void> _handleLimitBelirle(double? yeniLimit) async {
    if (yeniLimit == null || yeniLimit <= 0) {
      await _ttsService.speak(
        context.l10n.limitNotUnderstood,
        userId: widget.userId,
      );
      if (mounted) Navigator.pop(context);
      return;
    }

    if (widget.onSetBudgetLimit != null) {
      // Inline onay iste
      _requestConfirmation(
        baslik: context.l10n.budgetLimitUpdateTitle,
        mesaj: context.l10n.monthlyBudgetUpdateConfirm(
          yeniLimit.toStringAsFixed(0),
        ),
        onConfirm: () async {
          try {
            await widget.onSetBudgetLimit!(yeniLimit);

            await _ttsService.limitGuncellendiBildirimi(
              yeniLimit: yeniLimit,
              userId: widget.userId,
            );

            if (mounted) {
              AppSnackBar.success(
                context,
                context.l10n.monthlyBudgetUpdated(yeniLimit.toStringAsFixed(0)),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            debugPrint('Limit güncelleme hatası: $e');
            await _ttsService.speak(
              context.l10n.limitUpdateError,
              userId: widget.userId,
            );
            if (mounted) Navigator.pop(context);
          }
        },
      );
    } else {
      await _ttsService.speak(
        context.l10n.commandNotSupported,
        userId: widget.userId,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  /// Inline onay iste (BottomSheet içinde gösterilir)
  void _requestConfirmation({
    required String baslik,
    required String mesaj,
    required Future<void> Function() onConfirm,
  }) {
    if (_controller != null) {
      _controller!.requestVoiceConfirmation(title: baslik, message: mesaj);
    } else {
      _localPendingConfirmation = true;
      _localConfirmationTitle = baslik;
      _localConfirmationMessage = mesaj;
      setState(() {});
    }
    _onConfirmCallback = onConfirm;
  }

  /// Onay verildi
  Future<void> _handleConfirm() async {
    if (_onConfirmCallback != null) {
      await _onConfirmCallback!();
    }
    _resetConfirmation();
  }

  /// Onay durumunu sıfırla
  void _resetConfirmation() {
    if (_controller != null) {
      _controller!.clearVoiceConfirmation();
    } else {
      _localPendingConfirmation = false;
      _localConfirmationTitle = '';
      _localConfirmationMessage = '';
      setState(() {});
    }
    _onConfirmCallback = null;
  }

  /// "Bu ay ne kadar tasarruf ettim?" komutunu işle
  Future<void> _handleTasarrufHesapla() async {
    try {
      if (widget.onGetSavings != null) {
        final savingsInfo = widget.onGetSavings!();
        final tasarruf = (savingsInfo['tasarruf'] as num?)?.toDouble() ?? 0;
        final butceLimiti =
            (savingsInfo['butceLimiti'] as num?)?.toDouble() ?? 8000;

        await _ttsService.tasarrufBildirimi(
          tasarruf: tasarruf,
          butceLimiti: butceLimiti,
          userId: widget.userId,
        );
      } else {
        await _ttsService.speak(
          context.l10n.commandNotSupported,
          userId: widget.userId,
        );
      }
    } catch (e) {
      debugPrint('_handleTasarrufHesapla hatası: $e');
      await _ttsService.speak('Bir hata oluştu', userId: widget.userId);
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();

    // Android sistem sesi çal - dinleme durdu
    await SystemSound.play(SystemSoundType.click);
    await HapticFeedback.mediumImpact();

    if (mounted) {
      if (_controller != null) {
        _controller!.stopVoiceListening();
      } else {
        _localIsListening = false;
        setState(() {});
      }
    }
  }

  void _confirm() {
    double? tutar = double.tryParse(_tutarController.text.replaceAll(',', '.'));
    String isim = _isimController.text.trim();

    if (tutar == null || tutar <= 0) {
      AppSnackBar.error(context, context.l10n.enterValidAmount);
      return;
    }

    if (isim.isEmpty) {
      isim = _recognizedText.isNotEmpty
          ? _recognizedText
          : context.l10n.expense;
    }

    // Tarih: parseResult'tan gelen tarih veya bugün
    final DateTime tarih = _parseResult?.tarih ?? DateTime.now();

    widget.onConfirm(isim, tutar, _selectedCategory, tarih);

    // Sesli geri bildirim
    _ttsService.harcamaEklendiBildirimi(
      tutar: tutar,
      harcamaIsmi: isim,
      kategori: _selectedCategory,
      userId: widget.userId,
      tarih: _parseResult?.tarih,
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
            Icon(Icons.mic, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 12),
            Text(
              context.l10n.voiceAssistant,
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
              context.l10n.voiceAssistantCapabilities,
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
              context.l10n.addingExpenseLabel,
            ),
            _buildFeatureItem(
              context,
              Icons.delete_outline,
              context.l10n.deletingExpenseLabel,
            ),
            _buildFeatureItem(
              context,
              Icons.account_balance_wallet,
              context.l10n.queryExpenseLabel,
            ),
            _buildFeatureItem(
              context,
              Icons.pie_chart,
              context.l10n.categoryAnalysisLabel,
            ),
            _buildFeatureItem(
              context,
              Icons.warning_amber,
              context.l10n.budgetControlLabel,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.detailedCommandListInfo,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
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
              context.l10n.ok,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
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
                    context.l10n.voiceAssistant,
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
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: context.l10n.heard,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.54),
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: _recognizedText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Komut modunda işlem bilgisi veya onay UI göster
            if (_isCommandMode && _recognizedText.isNotEmpty) ...[
              // Onay bekleniyorsa onay UI göster
              if (_pendingConfirmation) ...[
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _confirmationTitle,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Mesaj
                      Text(
                        _confirmationMessage,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Onay butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(context.l10n.confirm),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Onay beklenmiyorsa işleniyor göster
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
                        context.l10n.commandProcessing,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],

            // Parse sonucu - Gelirlerim sayfasındaki gibi basit form
            // Sadece komut modunda değilse göster
            if (!_isCommandMode &&
                _parseResult != null &&
                _parseResult!.basarili) ...[
              // Duyulan kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: context.l10n.heard,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.54),
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: _recognizedText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tutar alanı
              TextField(
                controller: _tutarController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.amountTl,
                  labelStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: ColorConstants.kirmiziVurgu,
                  ),
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    color: ColorConstants.kirmiziVurgu,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // İsim alanı
              TextField(
                controller: _isimController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.expenseNameLabel,
                  labelStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: ColorConstants.kirmiziVurgu,
                  ),
                  prefixIcon: const Icon(
                    Icons.description,
                    color: ColorConstants.kirmiziVurgu,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Kategori seçici
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.category,
                      color: ColorConstants.kirmiziVurgu,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCategory.isNotEmpty
                            ? _selectedCategory
                            : null,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: widget.categoryIcons.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Row(
                              children: [
                                Icon(entry.value, size: 20),
                                const SizedBox(width: 8),
                                Text(entry.key),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            if (_controller != null) {
                              _controller!.setVoiceCategory(value);
                            } else {
                              _localSelectedCategory = value;
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Butonlar - sadece parse sonucu varsa göster
            if (!_isCommandMode &&
                _parseResult != null &&
                _parseResult!.basarili)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (_controller != null) {
                          _controller!.resetVoiceForm();
                        } else {
                          _localRecognizedText = '';
                          _localIsCommandMode = false;
                          _localParseResult = null;
                          setState(() {});
                        }
                        _startListening();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.retry),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorConstants.kirmiziVurgu,
                        side: const BorderSide(
                          color: ColorConstants.kirmiziVurgu,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canConfirm ? _confirm : null,
                      icon: const Icon(Icons.check),
                      label: Text(context.l10n.add),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.kirmiziVurgu,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
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
          context.l10n.micPreparing,
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
          label: Text(context.l10n.tryAgainAction),
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
                        ? ColorConstants.kirmiziVurgu
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: ColorConstants.kirmiziVurgu.withValues(
                                alpha: 0.4,
                              ),
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
                        : ColorConstants.kirmiziVurgu,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            _isListening
                ? context.l10n.micListening
                : context.l10n.tapToSpeakAgain,
            style: TextStyle(
              color: _isListening
                  ? ColorConstants.kirmiziVurgu
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                context.l10n.tapToStopMic,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

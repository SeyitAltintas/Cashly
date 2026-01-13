import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/speech/speech_service.dart';
import '../controllers/incomes_controller.dart';

/// Sesli gelir girişi için modal bottom sheet widget'ı
class IncomeVoiceInputSheet extends StatefulWidget {
  final Map<String, IconData> categoryIcons;
  final Function(String name, double amount, String category, DateTime date)
  onConfirm;
  final String? userId;
  final IncomesController? controller;

  const IncomeVoiceInputSheet({
    super.key,
    required this.categoryIcons,
    required this.onConfirm,
    this.userId,
    this.controller,
  });

  @override
  State<IncomeVoiceInputSheet> createState() => _IncomeVoiceInputSheetState();
}

class _IncomeVoiceInputSheetState extends State<IncomeVoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();

  // Controller veya yerel state
  IncomesController? _controller;
  bool _localIsListening = false;
  bool _localIsInitializing = true;
  bool _localHasError = false;
  String _localErrorMessage = '';
  String _localRecognizedText = '';
  SpeechParseResult? _localParseResult;
  String _localSelectedCategory = '';

  // Getter'lar
  bool get _isListening => _controller?.voiceIsListening ?? _localIsListening;
  bool get _isInitializing =>
      _controller?.voiceIsInitializing ?? _localIsInitializing;
  bool get _hasError => _controller?.voiceHasError ?? _localHasError;
  String get _errorMessage =>
      _controller?.voiceErrorMessage ?? _localErrorMessage;
  String get _recognizedText =>
      _controller?.voiceRecognizedText ?? _localRecognizedText;
  SpeechParseResult? get _parseResult =>
      _controller?.voiceParseResult ?? _localParseResult;
  String get _selectedCategory =>
      _controller?.voiceSelectedCategory ?? _localSelectedCategory;

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
            error: 'Mikrofon izni verilemedi veya cihaz desteklemiyor.',
          );
        } else {
          _localIsInitializing = false;
          _localHasError = true;
          _localErrorMessage =
              'Mikrofon izni verilemedi veya cihaz desteklemiyor.';
          setState(() {});
        }
      }
    }
  }

  Future<void> _startListening() async {
    await SystemSound.play(SystemSoundType.click);
    await HapticFeedback.lightImpact();

    // Listening state başlat
    if (_controller != null) {
      _controller!.startVoiceListening();
    } else {
      _localIsListening = true;
      _localRecognizedText = '';
      _localParseResult = null;
      _localHasError = false;
      setState(() {});
    }

    await _speechService.startListening(
      onResult: (text) {
        if (mounted) {
          // Gelir için parse et
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
            _localParseResult = parseResult;
            setState(() {});
          }
          // Parse sonucunu düzenleme alanlarına aktar
          if (parseResult.basarili) {
            _tutarController.text = parseResult.tutar!.toStringAsFixed(2);
            _isimController.text = parseResult.harcamaIsmi ?? text;
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

  @override
  void dispose() {
    _controller?.removeListener(_onStateChanged);
    _speechService.stopListening();
    _pulseController.dispose();
    _tutarController.dispose();
    _isimController.dispose();
    super.dispose();
  }

  void _confirmResult() {
    final tutar = double.tryParse(_tutarController.text) ?? 0;
    final isim = _isimController.text.trim();

    if (tutar <= 0 || isim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli tutar ve isim girin')),
      );
      return;
    }

    widget.onConfirm(isim, tutar, _selectedCategory, DateTime.now());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sürükle çubuğu
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, color: Colors.green.shade400, size: 28),
              const SizedBox(width: 8),
              Text(
                'Sesli Gelir Girişi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Durum göstergesi
          if (_isInitializing)
            _buildLoadingState()
          else if (_hasError)
            _buildErrorState()
          else if (_isListening)
            _buildListeningState()
          else if (_parseResult != null && _parseResult!.basarili)
            _buildResultForm()
          else
            _buildMicrophoneButton(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Hazırlanıyor...',
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
        Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
        const SizedBox(height: 16),
        Text(
          _errorMessage,
          style: TextStyle(color: Colors.red.shade400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _initSpeech(),
          icon: const Icon(Icons.refresh),
          label: const Text('Tekrar Dene'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildListeningState() {
    return Column(
      children: [
        // Animasyonlu mikrofon - tıklanabilir
        GestureDetector(
          onTap: () {
            _speechService.stopListening();
            if (_controller != null) {
              _controller!.stopVoiceListening();
            } else {
              _localIsListening = false;
              setState(() {});
            }
          },
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 40),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Dinliyorum...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.green.shade400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Durdurmak için mikrofona dokunun',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        if (_recognizedText.isNotEmpty) ...[
          const SizedBox(height: 16),
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
                    text: 'Duyulan: ',
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
        ],
      ],
    );
  }

  Widget _buildMicrophoneButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _startListening,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Mikrofona dokunun ve konuşun',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Örnek: "500 lira maaş"',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildResultForm() {
    return Column(
      children: [
        // "Duyulan" Kartı
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
                  text: 'Duyulan: ',
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Tutar (₺)',
            labelStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            floatingLabelStyle: const TextStyle(color: Colors.green),
            prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
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
                color: Colors.green.withValues(alpha: 0.5),
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Gelir Adı',
            labelStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            floatingLabelStyle: const TextStyle(color: Colors.green),
            prefixIcon: const Icon(Icons.description, color: Colors.green),
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
                color: Colors.green.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Kategori seçici
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.category, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  items: widget.categoryIcons.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(
                            entry.value,
                            size: 20,
                            color: Colors.green.shade400,
                          ),
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

        // Butonlar
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (_controller != null) {
                    _controller!.resetVoiceForm();
                  } else {
                    _localRecognizedText = '';
                    _localParseResult = null;
                    setState(() {});
                  }
                  _startListening();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Yeniden'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade400,
                  side: BorderSide(color: Colors.green.shade400),
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
                onPressed: _confirmResult,
                icon: const Icon(Icons.check),
                label: const Text('Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

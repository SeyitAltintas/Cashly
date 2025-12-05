import 'package:flutter/material.dart';
import '../../../../services/speech_service.dart';

/// Sesli harcama girişi için modal bottom sheet widget'ı
class VoiceInputSheet extends StatefulWidget {
  final List<String> categories;
  final Function(String name, double amount, String category) onConfirm;

  const VoiceInputSheet({
    super.key,
    required this.categories,
    required this.onConfirm,
  });

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();

  bool _isListening = false;
  bool _isInitializing = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _recognizedText = '';
  SpeechParseResult? _parseResult;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
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
      _recognizedText = '';
      _parseResult = null;
      _hasError = false;
    });

    await _speechService.startListening(
      onResult: (text) {
        if (mounted) {
          setState(() {
            _recognizedText = text;
            // Canlı olarak parse et
            _parseResult = _speechService.parseText(text, widget.categories);
          });
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

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  void _confirm() {
    if (_parseResult != null && _parseResult!.basarili) {
      widget.onConfirm(
        _parseResult!.harcamaIsmi ?? _parseResult!.rawText,
        _parseResult!.tutar!,
        _parseResult!.kategori ?? widget.categories.first,
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          // Başlık
          Text(
            'Sesli Harcama Girişi',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"100 lira market" gibi söyleyin',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),

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

          // Parse sonucu
          if (_parseResult != null && _parseResult!.basarili) ...[
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
                children: [
                  _buildResultRow(
                    'Tutar',
                    '${_parseResult!.tutar!.toStringAsFixed(2)} ₺',
                    Icons.currency_lira,
                  ),
                  const SizedBox(height: 8),
                  _buildResultRow(
                    'Kategori',
                    _parseResult!.kategori ?? 'Diğer',
                    Icons.category,
                  ),
                  if (_parseResult!.harcamaIsmi != null) ...[
                    const SizedBox(height: 8),
                    _buildResultRow(
                      'İsim',
                      _parseResult!.harcamaIsmi!,
                      Icons.edit,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Butonlar
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
                  onPressed: (_parseResult != null && _parseResult!.basarili)
                      ? _confirm
                      : null,
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
                  width: 100,
                  height: 100,
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
                    size: 50,
                    color: _isListening
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? 'Dinleniyor...' : 'Başlatmak için dokunun',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
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

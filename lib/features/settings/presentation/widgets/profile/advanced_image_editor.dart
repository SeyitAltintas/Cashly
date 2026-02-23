import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'editor_models.dart';

/// Gelişmiş profil resmi düzenleme ekranı
/// 6 sekmeli: Filtreler, Ayarlar, Dönüşüm, Metin, Emoji, Çerçeve
class AdvancedImageEditor extends StatefulWidget {
  final File imageFile;

  const AdvancedImageEditor({super.key, required this.imageFile});

  @override
  State<AdvancedImageEditor> createState() => _AdvancedImageEditorState();
}

class _AdvancedImageEditorState extends State<AdvancedImageEditor>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _imageKey = GlobalKey();
  bool _isSaving = false;

  // Metin düzenleme için controller
  final TextEditingController _textController = TextEditingController();

  // Tema renkleri
  static const Color _primaryColor = Color(0xFF075174);
  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _surfaceColor = Color(0xFF1A1A1A);
  static const Color _cardColor = Color(0xFF242424);

  // Editor state
  final EditorState _state = EditorState();

  // Seçili overlay
  String? _selectedOverlayId;

  // Undo/Redo stacks
  final List<EditorState> _undoStack = [];
  final List<EditorState> _redoStack = [];

  // Karşılaştırma modu (Option E)
  bool _showOriginal = false;

  // Döndürme animasyonu
  AnimationController? _rotAnimController;
  Animation<double>? _rotAnimation;
  double _animatedRotation = 0.0; // radyan cinsinden

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedOverlayId = null);
      }
    });

    // Döndürme animasyonu
    _rotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _rotAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _rotAnimController!, curve: Curves.easeOutCubic),
    );
    _rotAnimController!.addListener(() {
      setState(() => _animatedRotation = _rotAnimation!.value);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _rotAnimController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: Text(
          context.l10n.editPhoto,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primaryColor,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveEditedImage,
              child: Text(
                context.l10n.apply,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white, // Beyaz renk
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Önizleme alanı
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOverlayId = null;
                    });
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: RepaintBoundary(
                              key: _imageKey,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 320,
                                  height: 320,
                                  child: _showOriginal
                                      ? Image.file(
                                          widget.imageFile,
                                          fit: BoxFit.cover,
                                          width: 320,
                                          height: 320,
                                        )
                                      : _buildEditedImage(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Undo/Redo + Tümünü Sıfırla
                      _buildUndoRedoRow(),
                    ],
                  ),
                ),
                // Karşılaştırma ikonu (Option E)
                Positioned(
                  right: 16,
                  bottom: 44,
                  child: GestureDetector(
                    onLongPressStart: (_) =>
                        setState(() => _showOriginal = true),
                    onLongPressEnd: (_) =>
                        setState(() => _showOriginal = false),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _showOriginal
                            ? Icons.visibility
                            : Icons.visibility_outlined,
                        color: _showOriginal ? _primaryColor : Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Modern alt menü
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(color: _surfaceColor),
            child: Column(
              children: [
                // Scrollable icon + text tab seçici
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicator: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelPadding: EdgeInsets.zero,
                      tabAlignment: TabAlignment.start,
                      padding: EdgeInsets.zero,
                      tabs: [
                        _buildTab(Icons.filter_vintage, context.l10n.filters),
                        _buildTab(Icons.tune, context.l10n.adjustments),
                        _buildTab(Icons.crop_rotate, context.l10n.transform),
                        _buildTab(Icons.text_fields, context.l10n.text),
                        _buildTab(Icons.emoji_emotions, context.l10n.emoji),
                        _buildTab(Icons.auto_awesome, context.l10n.frame),
                      ],
                    ),
                  ),
                ),
                // Tab içerikleri
                SizedBox(
                  height: 260,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFiltersTab(),
                      _buildAdjustmentsTab(),
                      _buildTransformTab(),
                      _buildTextTab(),
                      _buildEmojiTab(),
                      _buildFrameTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Düzenlenmiş resmi oluştur
  Widget _buildEditedImage() {
    Widget image = Image.file(
      widget.imageFile,
      fit: BoxFit.cover,
      width: 320,
      height: 320,
    );

    // Filtre uygula (yoğunluk desteği ile)
    final filter = kFilterPresets[_state.selectedFilterIndex];
    if (filter.colorFilter != null) {
      if (_state.filterIntensity >= 100) {
        image = ColorFiltered(colorFilter: filter.colorFilter!, child: image);
      } else if (_state.filterIntensity > 0) {
        final original = image;
        image = Stack(
          fit: StackFit.expand,
          children: [
            original,
            Opacity(
              opacity: _state.filterIntensity / 100,
              child: ColorFiltered(
                colorFilter: filter.colorFilter!,
                child: original,
              ),
            ),
          ],
        );
      }
    }

    // Ayarlar uygula
    final adjustmentMatrix = _buildAdjustmentMatrix();
    if (adjustmentMatrix != null) {
      image = ColorFiltered(colorFilter: adjustmentMatrix, child: image);
    }

    // Dönüşümleri uygula (animasyonlu)
    if (_animatedRotation != 0) {
      image = Transform.rotate(angle: _animatedRotation, child: image);
    }

    if (_state.flipHorizontal || _state.flipVertical) {
      image = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _state.flipHorizontal ? -1.0 : 1.0,
          _state.flipVertical ? -1.0 : 1.0,
          1.0,
        ),
        child: image,
      );
    }

    // Stack içinde overlay'ları ekle
    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        // Vignette efekti
        if (_state.vignette > 0)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: _state.vignette / 100),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        // Metin overlay'ları
        ..._state.textOverlays.map((text) => _buildTextOverlayWidget(text)),
        // Sticker overlay'ları
        ..._state.stickerOverlays.map(
          (sticker) => _buildStickerOverlayWidget(sticker),
        ),
        // Çerçeve overlay
        if (_state.selectedFrameIndex != null && _state.selectedFrameIndex! > 0)
          _buildFrameOverlayWidget(),
      ],
    );
  }

  /// Metin overlay widget'ı - Pinch gesture ile boyut/döndürme (Option F)
  Widget _buildTextOverlayWidget(TextOverlay text) {
    final isSelected = _selectedOverlayId == text.id;

    return Positioned(
      left: text.position.dx * 320 - 50,
      top: text.position.dy * 320 - 20,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOverlayId = text.id;
          });
        },
        onScaleStart: (details) {
          _pushUndo();
          _lastScale = text.fontSize;
          _lastRotation = text.rotation;
        },
        onScaleUpdate: (details) {
          setState(() {
            // Pan (tek parmak sürükleme)
            if (details.pointerCount == 1) {
              text.position = Offset(
                (text.position.dx + details.focalPointDelta.dx / 320).clamp(
                  0.1,
                  0.9,
                ),
                (text.position.dy + details.focalPointDelta.dy / 320).clamp(
                  0.1,
                  0.9,
                ),
              );
            }
            // Pinch (iki parmak boyut + döndürme)
            if (details.pointerCount == 2) {
              text.fontSize = (_lastScale * details.scale).clamp(10.0, 80.0);
              text.rotation = _lastRotation + details.rotation;
            }
          });
        },
        child: Transform.rotate(
          angle: text.rotation,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: isSelected
                ? BoxDecoration(
                    border: Border.all(color: _primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              text.text,
              style: TextStyle(
                fontFamily: text.fontFamily,
                fontSize: text.fontSize,
                color: text.color,
                fontWeight: text.isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: text.isItalic ? FontStyle.italic : FontStyle.normal,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Pinch gesture için geçici değişkenler (Option F)
  double _lastScale = 1.0;
  double _lastRotation = 0.0;

  /// Sticker overlay widget'ı - Pinch gesture ile boyut/döndürme (Option F)
  Widget _buildStickerOverlayWidget(StickerOverlay sticker) {
    final isSelected = _selectedOverlayId == sticker.id;

    return Positioned(
      left: sticker.position.dx * 320 - sticker.size / 2,
      top: sticker.position.dy * 320 - sticker.size / 2,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOverlayId = sticker.id;
          });
        },
        onScaleStart: (details) {
          _pushUndo();
          _lastScale = sticker.size;
          _lastRotation = sticker.rotation;
        },
        onScaleUpdate: (details) {
          setState(() {
            // Pan (tek parmak sürükleme)
            if (details.pointerCount == 1) {
              sticker.position = Offset(
                (sticker.position.dx + details.focalPointDelta.dx / 320).clamp(
                  0.1,
                  0.9,
                ),
                (sticker.position.dy + details.focalPointDelta.dy / 320).clamp(
                  0.1,
                  0.9,
                ),
              );
            }
            // Pinch (iki parmak boyut + döndürme)
            if (details.pointerCount == 2) {
              sticker.size = (_lastScale * details.scale).clamp(16.0, 120.0);
              sticker.rotation = _lastRotation + details.rotation;
            }
          });
        },
        child: Transform.rotate(
          angle: sticker.rotation,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: isSelected
                ? BoxDecoration(
                    border: Border.all(color: _primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              sticker.emoji,
              style: TextStyle(fontSize: sticker.size),
            ),
          ),
        ),
      ),
    );
  }

  /// Çerçeve overlay widget'ı - frameBorderWidth desteği (Option G)
  Widget _buildFrameOverlayWidget() {
    final frame = kFramePresets[_state.selectedFrameIndex!];
    final borderWidth = _state.frameBorderWidth;

    if (frame.isGradient && frame.gradientColors != null) {
      // Gradient çerçeve - sadece kenar
      return Positioned.fill(
        child: CustomPaint(
          painter: _GradientBorderPainter(
            colors: frame.gradientColors!,
            borderWidth: borderWidth,
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: frame.borderColor, width: borderWidth),
        ),
      ),
    );
  }

  /// Ayar matrisini oluştur
  ColorFilter? _buildAdjustmentMatrix() {
    if (_state.brightness == 0 &&
        _state.contrast == 0 &&
        _state.saturation == 0 &&
        _state.temperature == 0 &&
        _state.tint == 0 &&
        _state.shadows == 0 &&
        _state.highlights == 0) {
      return null;
    }

    final b = _state.brightness * 2.55;
    final c = 1 + (_state.contrast / 100);
    final cOffset = 128 * (1 - c);

    final s = 1 + (_state.saturation / 100);
    const lumR = 0.3086;
    const lumG = 0.6094;
    const lumB = 0.0820;
    final sr = (1 - s) * lumR;
    final sg = (1 - s) * lumG;
    final sb = (1 - s) * lumB;

    final tempR = _state.temperature > 0 ? _state.temperature * 0.3 : 0.0;
    final tempB = _state.temperature < 0 ? -_state.temperature * 0.3 : 0.0;

    // Tint (yeşil ↔ magenta kayması)
    final tintR = -_state.tint * 0.12;
    final tintG = _state.tint * 0.25;
    final tintB = -_state.tint * 0.12;

    // Gölgeler ve Parlamalar
    final shadowOffset = _state.shadows * 0.4;
    final highlightOffset = -_state.highlights * 0.4;

    final matrix = <double>[
      c * (sr + s),
      c * sg,
      c * sb,
      0,
      b + cOffset + tempR + tintR + shadowOffset + highlightOffset,
      c * sr,
      c * (sg + s),
      c * sb,
      0,
      b + cOffset + tintG + shadowOffset + highlightOffset,
      c * sr,
      c * sg,
      c * (sb + s),
      0,
      b + cOffset + tempB + tintB + shadowOffset + highlightOffset,
      0,
      0,
      0,
      1,
      0,
    ];

    return ColorFilter.matrix(matrix);
  }

  // === TAB İÇERİKLERİ ===

  /// Filtreler sekmesi - Yoğunluk slider + grid
  Widget _buildFiltersTab() {
    return Column(
      children: [
        if (_state.selectedFilterIndex > 0) _buildFilterIntensitySlider(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 0,
              crossAxisSpacing: 4,
              childAspectRatio: 0.82,
            ),
            itemCount: kFilterPresets.length,
            itemBuilder: (context, index) {
              final filter = kFilterPresets[index];
              final isSelected = _state.selectedFilterIndex == index;

              return GestureDetector(
                onTap: () {
                  _pushUndo();
                  setState(() => _state.selectedFilterIndex = index);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? _primaryColor
                              : Colors.white.withValues(alpha: 0.2),
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: ColorFiltered(
                          colorFilter:
                              filter.colorFilter ??
                              const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.dst,
                              ),
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
                            width: 52,
                            height: 52,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filter.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: isSelected
                            ? _primaryColor
                            : Colors.white.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Filtre yoğunluk slider'ı
  Widget _buildFilterIntensitySlider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          const Icon(Icons.opacity, color: Colors.white54, size: 16),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            child: Text(
              context.l10n.intensity,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white70,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _primaryColor,
                inactiveTrackColor: Colors.white24,
                thumbColor: _primaryColor,
                overlayColor: _primaryColor.withValues(alpha: 0.2),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: _state.filterIntensity,
                min: 0,
                max: 100,
                onChangeStart: (_) => _pushUndo(),
                onChanged: (v) => setState(() => _state.filterIntensity = v),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${_state.filterIntensity.toInt()}%',
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white54,
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _state.filterIntensity != 100
                ? () {
                    _pushUndo();
                    setState(() => _state.filterIntensity = 100);
                  }
                : null,
            child: Icon(
              Icons.restart_alt_rounded,
              color: _state.filterIntensity != 100
                  ? _primaryColor
                  : Colors.white24,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Ayarlar sekmesi - Reset butonları ile
  Widget _buildAdjustmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildSliderWithReset(
            context.l10n.brightness,
            Icons.brightness_6,
            _state.brightness,
            (v) => setState(() => _state.brightness = v),
            () => setState(() => _state.brightness = 0),
          ),
          _buildSliderWithReset(
            context.l10n.contrast,
            Icons.contrast,
            _state.contrast,
            (v) => setState(() => _state.contrast = v),
            () => setState(() => _state.contrast = 0),
          ),
          _buildSliderWithReset(
            context.l10n.saturation,
            Icons.palette,
            _state.saturation,
            (v) => setState(() => _state.saturation = v),
            () => setState(() => _state.saturation = 0),
          ),
          _buildSliderWithReset(
            context.l10n.temperature,
            Icons.thermostat,
            _state.temperature,
            (v) => setState(() => _state.temperature = v),
            () => setState(() => _state.temperature = 0),
          ),
          _buildSliderWithReset(
            context.l10n.tint,
            Icons.color_lens,
            _state.tint,
            (v) => setState(() => _state.tint = v),
            () => setState(() => _state.tint = 0),
          ),
          _buildSliderWithReset(
            context.l10n.shadows,
            Icons.wb_shade,
            _state.shadows,
            (v) => setState(() => _state.shadows = v),
            () => setState(() => _state.shadows = 0),
          ),
          _buildSliderWithReset(
            context.l10n.highlights,
            Icons.wb_sunny,
            _state.highlights,
            (v) => setState(() => _state.highlights = v),
            () => setState(() => _state.highlights = 0),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderWithReset(
    String label,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
    VoidCallback onReset, {
    double min = -100,
    double max = 100,
  }) {
    final hasChange = value != 0 && value != min;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white70,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _primaryColor,
                inactiveTrackColor: Colors.white24,
                thumbColor: _primaryColor,
                overlayColor: _primaryColor.withValues(alpha: 0.2),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChangeStart: (_) => _pushUndo(),
                onChanged: onChanged,
              ),
            ),
          ),
          // Değer yazısı - Sola yakın
          SizedBox(
            width: 32,
            child: Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white54,
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          // Reset butonu - Sağda, mesafeli
          SizedBox(
            width: 24,
            height: 24,
            child: hasChange
                ? GestureDetector(
                    onTap: () {
                      _pushUndo();
                      onReset();
                    },
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 16,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Dönüşüm sekmesi
  Widget _buildTransformTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTransformButton(
              icon: Icons.rotate_left,
              label: context.l10n.rotateLeft,
              onTap: () {
                _pushUndo();
                _state.rotationAngle = (_state.rotationAngle - 90) % 360;
                final from = _animatedRotation;
                final to = from - math.pi / 2;
                _rotAnimation = Tween<double>(begin: from, end: to).animate(
                  CurvedAnimation(
                    parent: _rotAnimController!,
                    curve: Curves.easeOutCubic,
                  ),
                );
                _rotAnimController!.forward(from: 0);
              },
            ),
            _buildTransformButton(
              icon: Icons.rotate_right,
              label: context.l10n.rotateRight,
              onTap: () {
                _pushUndo();
                _state.rotationAngle = (_state.rotationAngle + 90) % 360;
                final from = _animatedRotation;
                final to = from + math.pi / 2;
                _rotAnimation = Tween<double>(begin: from, end: to).animate(
                  CurvedAnimation(
                    parent: _rotAnimController!,
                    curve: Curves.easeOutCubic,
                  ),
                );
                _rotAnimController!.forward(from: 0);
              },
            ),
            _buildTransformButton(
              icon: Icons.flip,
              label: context.l10n.horizontal,
              isActive: _state.flipHorizontal,
              onTap: () {
                _pushUndo();
                setState(() {
                  _state.flipHorizontal = !_state.flipHorizontal;
                });
              },
            ),
            _buildTransformButton(
              icon: Icons.flip,
              label: context.l10n.vertical,
              rotateIcon: true,
              isActive: _state.flipVertical,
              onTap: () {
                _pushUndo();
                setState(() {
                  _state.flipVertical = !_state.flipVertical;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransformButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool rotateIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? _primaryColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? _primaryColor
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Transform.rotate(
              angle: rotateIcon ? math.pi / 2 : 0,
              child: Icon(
                icon,
                color: isActive ? _primaryColor : Colors.white70,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              color: isActive ? _primaryColor : Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Metin sekmesi - Dialog olmadan inline düzenleme
  Widget _buildTextTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Metin ekleme alanı - inline
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: context.l10n.typeText,
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addNewTextFromController(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addNewTextFromController,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Seçili metin ayarları
          if (_selectedOverlayId != null && _getSelectedTextOverlay() != null)
            _buildTextEditControls(),
          // Metin listesi (dikey grid, satırda max 2)
          if (_state.textOverlays.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 3.5,
                ),
                itemCount: _state.textOverlays.length,
                itemBuilder: (context, index) {
                  final text = _state.textOverlays[index];
                  final isSelected = _selectedOverlayId == text.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedOverlayId = text.id),
                    onLongPress: () => _deleteTextOverlay(text.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primaryColor.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _primaryColor
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          text.text.length > 12
                              ? '${text.text.substring(0, 12)}...'
                              : text.text,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: isSelected ? _primaryColor : Colors.white70,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _addNewTextFromController() {
    if (_textController.text.isNotEmpty) {
      _pushUndo();
      setState(() {
        final newText = TextOverlay(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _textController.text,
        );
        _state.textOverlays.add(newText);
        _selectedOverlayId = newText.id;
        _textController.clear();
      });
    }
  }

  TextOverlay? _getSelectedTextOverlay() {
    try {
      return _state.textOverlays.firstWhere((t) => t.id == _selectedOverlayId);
    } catch (_) {
      return null;
    }
  }

  /// Metin düzenleme kontrolleri - Gelişmiş (Option D)
  Widget _buildTextEditControls() {
    final text = _getSelectedTextOverlay();
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          // Üst satır: Renkler + Bold/Italic/Sil
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Geniş renk paleti
              ...[
                Colors.white,
                Colors.black,
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.amber,
                Colors.pink,
                _primaryColor,
              ].map(
                (color) => GestureDetector(
                  onTap: () {
                    _pushUndo();
                    setState(() => text.color = color);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: text.color == color
                            ? _primaryColor
                            : Colors.white.withValues(alpha: 0.3),
                        width: text.color == color ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bold toggle
              GestureDetector(
                onTap: () {
                  _pushUndo();
                  setState(() => text.isBold = !text.isBold);
                },
                child: Icon(
                  Icons.format_bold,
                  color: text.isBold ? _primaryColor : Colors.white54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 4),
              // Italic toggle (Option D)
              GestureDetector(
                onTap: () {
                  _pushUndo();
                  setState(() => text.isItalic = !text.isItalic);
                },
                child: Icon(
                  Icons.format_italic,
                  color: text.isItalic ? _primaryColor : Colors.white54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 4),
              // Sil
              GestureDetector(
                onTap: () => _deleteTextOverlay(text.id),
                child: const Icon(Icons.delete, color: Colors.red, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Alt satır: Font boyutu slider + Font seçici
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.text_fields, color: Colors.white54, size: 14),
                const SizedBox(width: 4),
                // Font boyutu slider (Option D)
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _primaryColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: _primaryColor,
                      overlayColor: _primaryColor.withValues(alpha: 0.2),
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 4,
                      ),
                    ),
                    child: Slider(
                      value: text.fontSize,
                      min: 10,
                      max: 80,
                      onChangeStart: (_) => _pushUndo(),
                      onChanged: (v) => setState(() => text.fontSize = v),
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${text.fontSize.toInt()}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white54,
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 6),
                // Font ailesi seçici (Option D)
                ..._buildFontSelector(text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Font seçici - küçük yatay butonlar (Option D)
  List<Widget> _buildFontSelector(TextOverlay text) {
    const fonts = ['Inter', 'Roboto', 'Georgia', 'Courier'];
    return fonts.map((font) {
      final isActive = text.fontFamily == font;
      return GestureDetector(
        onTap: () {
          _pushUndo();
          setState(() => text.fontFamily = font);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 3),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isActive
                ? _primaryColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive
                  ? _primaryColor
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            font.length > 3 ? font.substring(0, 3) : font,
            style: TextStyle(
              fontFamily: font,
              color: isActive ? _primaryColor : Colors.white54,
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _deleteTextOverlay(String id) {
    _pushUndo();
    setState(() {
      _state.textOverlays.removeWhere((t) => t.id == id);
      if (_selectedOverlayId == id) _selectedOverlayId = null;
    });
  }

  /// Emoji sekmesi - emoji_picker_flutter ile
  Widget _buildEmojiTab() {
    return Column(
      children: [
        // Seçili emoji ayarları
        if (_selectedOverlayId != null && _getSelectedStickerOverlay() != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  context.l10n.sizeLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _primaryColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: _primaryColor,
                      overlayColor: _primaryColor.withValues(alpha: 0.2),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: _getSelectedStickerOverlay()!.size,
                      min: 16,
                      max: 120,
                      onChangeStart: (_) => _pushUndo(),
                      onChanged: (v) => setState(() {
                        _getSelectedStickerOverlay()!.size = v;
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _deleteStickerOverlay(_selectedOverlayId!),
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ],
            ),
          ),
        // Emoji picker - Dark theme
        Expanded(
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              _addSticker(emoji.emoji);
            },
            config: const Config(
              height: 140,
              checkPlatformCompatibility: true,
              emojiViewConfig: EmojiViewConfig(
                columns: 8,
                emojiSizeMax: 28,
                backgroundColor: _surfaceColor,
              ),
              categoryViewConfig: CategoryViewConfig(
                backgroundColor: _surfaceColor,
                indicatorColor: _primaryColor,
                iconColorSelected: _primaryColor,
                iconColor: Colors.white54,
              ),
              bottomActionBarConfig: BottomActionBarConfig(enabled: false),
              searchViewConfig: SearchViewConfig(
                backgroundColor: _surfaceColor,
                buttonIconColor: Colors.white54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  StickerOverlay? _getSelectedStickerOverlay() {
    try {
      return _state.stickerOverlays.firstWhere(
        (s) => s.id == _selectedOverlayId,
      );
    } catch (_) {
      return null;
    }
  }

  void _addSticker(String emoji) {
    _pushUndo();
    setState(() {
      final newSticker = StickerOverlay(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        emoji: emoji,
      );
      _state.stickerOverlays.add(newSticker);
      _selectedOverlayId = newSticker.id;
    });
  }

  void _deleteStickerOverlay(String id) {
    _pushUndo();
    setState(() {
      _state.stickerOverlays.removeWhere((s) => s.id == id);
      if (_selectedOverlayId == id) _selectedOverlayId = null;
    });
  }

  /// Çerçeve sekmesi - Kalınlık slider'ı ile (Option G)
  Widget _buildFrameTab() {
    return Column(
      children: [
        // Kalınlık slider'ı (seçili çerçeve varsa)
        if (_state.selectedFrameIndex != null && _state.selectedFrameIndex! > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.line_weight, color: Colors.white54, size: 16),
                const SizedBox(width: 6),
                SizedBox(
                  width: 56,
                  child: Text(
                    context.l10n.thickness,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _primaryColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: _primaryColor,
                      overlayColor: _primaryColor.withValues(alpha: 0.2),
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                      ),
                    ),
                    child: Slider(
                      value: _state.frameBorderWidth,
                      min: 2,
                      max: 24,
                      onChangeStart: (_) => _pushUndo(),
                      onChanged: (v) =>
                          setState(() => _state.frameBorderWidth = v),
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${_state.frameBorderWidth.toInt()}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        // Çerçeve listesi (dikey grid)
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 2,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemCount: kFramePresets.length,
            itemBuilder: (context, index) {
              final frame = kFramePresets[index];
              final isSelected = _state.selectedFrameIndex == index;

              return GestureDetector(
                onTap: () {
                  _pushUndo();
                  setState(() => _state.selectedFrameIndex = index);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                        border: frame.isGradient && frame.gradientColors != null
                            ? null
                            : Border.all(
                                color: frame.borderColor,
                                width: frame.borderWidth > 0 ? 3 : 1,
                              ),
                        gradient:
                            frame.isGradient && frame.gradientColors != null
                            ? SweepGradient(colors: frame.gradientColors!)
                            : null,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[700],
                          border: isSelected
                              ? Border.all(color: _primaryColor, width: 2)
                              : null,
                        ),
                        child: ClipOval(
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
                            width: 44,
                            height: 44,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _localizedFrameName(frame.name),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: isSelected
                            ? _primaryColor
                            : Colors.white.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Frame isimlerini lokalize et
  String _localizedFrameName(String name) {
    final l10n = context.l10n;
    const frameKeys = {
      'Yok': 'frameNone',
      'Beyaz': 'frameWhite',
      'Siyah': 'frameBlack',
      'Polaroid': 'framePolaroid',
      'Altın': 'frameGold',
      'Gümüş': 'frameSilver',
      'Neon': 'frameNeon',
      'Neon Pembe': 'frameNeonPink',
      'Okyanus': 'frameOcean',
      'Günbatımı': 'frameSunset',
      'Retro': 'frameRetro',
      'Vintage': 'frameVintage',
      'Mint': 'frameMint',
      'Lavanta': 'frameLavender',
      'Rose Gold': 'frameRoseGold',
      'Bronz': 'frameBronze',
      'Buz': 'frameIce',
      'Orman': 'frameForest',
      'Mercan': 'frameCoral',
      'Gece': 'frameNight',
      'Şampanya': 'frameChampagne',
      'Yakut': 'frameRuby',
    };
    final key = frameKeys[name];
    if (key == null) return name;
    switch (key) {
      case 'frameNone':
        return l10n.frameNone;
      case 'frameWhite':
        return l10n.frameWhite;
      case 'frameBlack':
        return l10n.frameBlack;
      case 'framePolaroid':
        return l10n.framePolaroid;
      case 'frameGold':
        return l10n.frameGold;
      case 'frameSilver':
        return l10n.frameSilver;
      case 'frameNeon':
        return l10n.frameNeon;
      case 'frameNeonPink':
        return l10n.frameNeonPink;
      case 'frameOcean':
        return l10n.frameOcean;
      case 'frameSunset':
        return l10n.frameSunset;
      case 'frameRetro':
        return l10n.frameRetro;
      case 'frameVintage':
        return l10n.frameVintage;
      case 'frameMint':
        return l10n.frameMint;
      case 'frameLavender':
        return l10n.frameLavender;
      case 'frameRoseGold':
        return l10n.frameRoseGold;
      case 'frameBronze':
        return l10n.frameBronze;
      case 'frameIce':
        return l10n.frameIce;
      case 'frameForest':
        return l10n.frameForest;
      case 'frameCoral':
        return l10n.frameCoral;
      case 'frameNight':
        return l10n.frameNight;
      case 'frameChampagne':
        return l10n.frameChampagne;
      case 'frameRuby':
        return l10n.frameRuby;
      default:
        return name;
    }
  }

  // === ACTIONS ===

  void _resetAll() {
    _undoStack.clear();
    _redoStack.clear();
    setState(() {
      _state.reset();
      _selectedOverlayId = null;
      _textController.clear();
      _animatedRotation = 0.0;
    });
  }

  void _pushUndo() {
    _undoStack.add(_state.clone());
    _redoStack.clear();
    if (_undoStack.length > 30) _undoStack.removeAt(0);
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    _redoStack.add(_state.clone());
    final snapshot = _undoStack.removeLast();
    setState(() {
      _state.restoreFrom(snapshot);
      _selectedOverlayId = null;
      _animatedRotation = _state.rotationAngle * math.pi / 180;
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    _undoStack.add(_state.clone());
    final snapshot = _redoStack.removeLast();
    setState(() {
      _state.restoreFrom(snapshot);
      _selectedOverlayId = null;
      _animatedRotation = _state.rotationAngle * math.pi / 180;
    });
  }

  /// Undo/Redo + Tümünü Sıfırla satırı
  Widget _buildUndoRedoRow() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 20),
          _buildUndoRedoButton(
            icon: Icons.undo_rounded,
            label: context.l10n.undo,
            onTap: _undo,
            isEnabled: _undoStack.isNotEmpty,
          ),
          const SizedBox(width: 12),
          _buildUndoRedoButton(
            icon: Icons.redo_rounded,
            label: context.l10n.redo,
            onTap: _redo,
            isEnabled: _redoStack.isNotEmpty,
          ),
          const Spacer(),
          GestureDetector(
            onTap: _resetAll,
            child: Text(
              context.l10n.resetAll,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Undo/Redo buton widget'ı
  Widget _buildUndoRedoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? _primaryColor : Colors.white38,
              size: 16,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isEnabled ? Colors.white70 : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEditedImage() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      if (!_state.hasChanges) {
        if (mounted) Navigator.pop(context, widget.imageFile);
        return;
      }

      final boundary =
          _imageKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        if (mounted) Navigator.pop(context, widget.imageFile);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        if (mounted) Navigator.pop(context, widget.imageFile);
        return;
      }

      final bytes = byteData.buffer.asUint8List();

      final directory = widget.imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final editedPath = '${directory.path}/profile_edited_$timestamp.png';
      final editedFile = File(editedPath);
      await editedFile.writeAsBytes(bytes);

      if (mounted) Navigator.pop(context, editedFile);
    } catch (e) {
      if (mounted) Navigator.pop(context, widget.imageFile);
    }
  }
}

/// Gradient çerçeve çizen CustomPainter
class _GradientBorderPainter extends CustomPainter {
  final List<Color> colors;
  final double borderWidth;

  _GradientBorderPainter({required this.colors, required this.borderWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (borderWidth / 2);

    final gradient = SweepGradient(colors: colors);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.borderWidth != borderWidth;
  }
}

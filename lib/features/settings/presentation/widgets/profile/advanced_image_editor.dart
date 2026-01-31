import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
    with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: const Text(
          'Fotoğraf Düzenle',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
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
              child: const Text(
                'Uygula',
                style: TextStyle(
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOverlayId = null;
                });
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: RepaintBoundary(
                    key: _imageKey,
                    child: ClipOval(
                      child: SizedBox(
                        width: 320,
                        height: 320,
                        child: _buildEditedImage(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Modern alt menü
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(color: _surfaceColor),
            child: Column(
              children: [
                // Tümünü Sıfırla - Sağa yaslı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _resetAll,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Tümünü Sıfırla',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      tabs: [
                        _buildTab(Icons.filter_vintage, 'Filtreler'),
                        _buildTab(Icons.tune, 'Ayarlar'),
                        _buildTab(Icons.crop_rotate, 'Dönüşüm'),
                        _buildTab(Icons.text_fields, 'Metin'),
                        _buildTab(Icons.emoji_emotions, 'Emoji'),
                        _buildTab(Icons.auto_awesome, 'Çerçeve'),
                      ],
                    ),
                  ),
                ),
                // Tab içerikleri
                SizedBox(
                  height: 200,
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

    // Filtre uygula
    final filter = kFilterPresets[_state.selectedFilterIndex];
    if (filter.colorFilter != null) {
      image = ColorFiltered(colorFilter: filter.colorFilter!, child: image);
    }

    // Ayarlar uygula
    final adjustmentMatrix = _buildAdjustmentMatrix();
    if (adjustmentMatrix != null) {
      image = ColorFiltered(colorFilter: adjustmentMatrix, child: image);
    }

    // Dönüşümleri uygula
    if (_state.rotationAngle != 0) {
      image = Transform.rotate(
        angle: _state.rotationAngle * math.pi / 180,
        child: image,
      );
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

  /// Metin overlay widget'ı
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
        onPanUpdate: (details) {
          setState(() {
            text.position = Offset(
              (text.position.dx + details.delta.dx / 320).clamp(0.1, 0.9),
              (text.position.dy + details.delta.dy / 320).clamp(0.1, 0.9),
            );
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

  /// Sticker overlay widget'ı
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
        onPanUpdate: (details) {
          setState(() {
            sticker.position = Offset(
              (sticker.position.dx + details.delta.dx / 320).clamp(0.1, 0.9),
              (sticker.position.dy + details.delta.dy / 320).clamp(0.1, 0.9),
            );
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

  /// Çerçeve overlay widget'ı
  Widget _buildFrameOverlayWidget() {
    final frame = kFramePresets[_state.selectedFrameIndex!];

    if (frame.isGradient && frame.gradientColors != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.transparent,
            width: frame.borderWidth,
          ),
          gradient: SweepGradient(colors: frame.gradientColors!),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: frame.borderColor, width: frame.borderWidth),
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

    final matrix = <double>[
      c * (sr + s),
      c * sg,
      c * sb,
      0,
      b + cOffset + tempR,
      c * sr,
      c * (sg + s),
      c * sb,
      0,
      b + cOffset,
      c * sr,
      c * sg,
      c * (sb + s),
      0,
      b + cOffset + tempB,
      0,
      0,
      0,
      1,
      0,
    ];

    return ColorFilter.matrix(matrix);
  }

  // === TAB İÇERİKLERİ ===

  /// Filtreler sekmesi
  Widget _buildFiltersTab() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: kFilterPresets.length,
      itemBuilder: (context, index) {
        final filter = kFilterPresets[index];
        final isSelected = _state.selectedFilterIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _state.selectedFilterIndex = index),
          child: Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
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
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(filter.emoji, style: const TextStyle(fontSize: 14)),
                Text(
                  filter.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isSelected
                        ? _primaryColor
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Ayarlar sekmesi - Reset butonları ile
  Widget _buildAdjustmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildSliderWithReset(
            'Parlaklık',
            Icons.brightness_6,
            _state.brightness,
            (v) => setState(() => _state.brightness = v),
            () => setState(() => _state.brightness = 0),
          ),
          _buildSliderWithReset(
            'Kontrast',
            Icons.contrast,
            _state.contrast,
            (v) => setState(() => _state.contrast = v),
            () => setState(() => _state.contrast = 0),
          ),
          _buildSliderWithReset(
            'Doygunluk',
            Icons.palette,
            _state.saturation,
            (v) => setState(() => _state.saturation = v),
            () => setState(() => _state.saturation = 0),
          ),
          _buildSliderWithReset(
            'Sıcaklık',
            Icons.thermostat,
            _state.temperature,
            (v) => setState(() => _state.temperature = v),
            () => setState(() => _state.temperature = 0),
          ),
          _buildSliderWithReset(
            'Vignette',
            Icons.vignette,
            _state.vignette,
            (v) => setState(() => _state.vignette = v),
            () => setState(() => _state.vignette = 0),
            min: 0,
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
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white70,
                fontSize: 11,
              ),
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
                    onTap: onReset,
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
              label: 'Sola',
              onTap: () => setState(() {
                _state.rotationAngle = (_state.rotationAngle - 90) % 360;
              }),
            ),
            _buildTransformButton(
              icon: Icons.rotate_right,
              label: 'Sağa',
              onTap: () => setState(() {
                _state.rotationAngle = (_state.rotationAngle + 90) % 360;
              }),
            ),
            _buildTransformButton(
              icon: Icons.flip,
              label: 'Yatay',
              isActive: _state.flipHorizontal,
              onTap: () => setState(() {
                _state.flipHorizontal = !_state.flipHorizontal;
              }),
            ),
            _buildTransformButton(
              icon: Icons.flip,
              label: 'Dikey',
              rotateIcon: true,
              isActive: _state.flipVertical,
              onTap: () => setState(() {
                _state.flipVertical = !_state.flipVertical;
              }),
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
                      hintText: 'Metin yazın...',
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
          // Metin listesi
          if (_state.textOverlays.isNotEmpty)
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _state.textOverlays.length,
                itemBuilder: (context, index) {
                  final text = _state.textOverlays[index];
                  final isSelected = _selectedOverlayId == text.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedOverlayId = text.id),
                    onLongPress: () => _deleteTextOverlay(text.id),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
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
                      child: Text(
                        text.text.length > 10
                            ? '${text.text.substring(0, 10)}...'
                            : text.text,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: isSelected ? _primaryColor : Colors.white70,
                          fontSize: 11,
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

  Widget _buildTextEditControls() {
    final text = _getSelectedTextOverlay();
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Renk seçici
          ...[
            Colors.white,
            Colors.black,
            Colors.red,
            Colors.blue,
            _primaryColor,
          ].map(
            (color) => GestureDetector(
              onTap: () => setState(() => text.color = color),
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 3),
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
          const SizedBox(width: 12),
          // Bold toggle
          GestureDetector(
            onTap: () => setState(() => text.isBold = !text.isBold),
            child: Icon(
              Icons.format_bold,
              color: text.isBold ? _primaryColor : Colors.white54,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          // Sil
          GestureDetector(
            onTap: () => _deleteTextOverlay(text.id),
            child: const Icon(Icons.delete, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  void _deleteTextOverlay(String id) {
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
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Boyut:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: _getSelectedStickerOverlay()!.size,
                    min: 24,
                    max: 80,
                    activeColor: _primaryColor,
                    onChanged: (v) => setState(() {
                      _getSelectedStickerOverlay()!.size = v;
                    }),
                  ),
                ),
                GestureDetector(
                  onTap: () => _deleteStickerOverlay(_selectedOverlayId!),
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ],
            ),
          ),
        // Emoji picker - Basitleştirilmiş config
        Expanded(
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              _addSticker(emoji.emoji);
            },
            config: Config(
              height: 140,
              checkPlatformCompatibility: true,
              emojiViewConfig: EmojiViewConfig(
                columns: 8,
                emojiSizeMax:
                    28 *
                    (Theme.of(context).platform == TargetPlatform.iOS
                        ? 1.2
                        : 1.0),
                noRecents: const Text(
                  'Henüz emoji yok',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
              categoryViewConfig: const CategoryViewConfig(),
              bottomActionBarConfig: const BottomActionBarConfig(
                enabled: false,
              ),
              searchViewConfig: const SearchViewConfig(),
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
    setState(() {
      _state.stickerOverlays.removeWhere((s) => s.id == id);
      if (_selectedOverlayId == id) _selectedOverlayId = null;
    });
  }

  /// Çerçeve sekmesi - Yeniden tasarlanmış
  Widget _buildFrameTab() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: kFramePresets.length,
      itemBuilder: (context, index) {
        final frame = kFramePresets[index];
        final isSelected = _state.selectedFrameIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _state.selectedFrameIndex = index),
          child: Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                    border: frame.isGradient && frame.gradientColors != null
                        ? null
                        : Border.all(
                            color: frame.borderColor,
                            width: frame.borderWidth > 0 ? 4 : 1,
                          ),
                    gradient: frame.isGradient && frame.gradientColors != null
                        ? SweepGradient(colors: frame.gradientColors!)
                        : null,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
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
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  frame.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isSelected
                        ? _primaryColor
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // === ACTIONS ===

  void _resetAll() {
    setState(() {
      _state.reset();
      _selectedOverlayId = null;
      _textController.clear();
    });
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

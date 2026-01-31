import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'editor_models.dart';

/// Gelişmiş profil resmi düzenleme ekranı
/// 6 sekmeli: Filtreler, Ayarlar, Dönüşüm, Metin, Sticker, Çerçeve
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text('Fotoğraf Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_state.hasChanges)
            TextButton(
              onPressed: _resetAll,
              child: const Text(
                'Sıfırla',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF00D293),
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
                  color: Color(0xFF00D293),
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
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF00D293),
              labelColor: const Color(0xFF00D293),
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.auto_awesome, size: 18),
                  text: 'Filtreler',
                ),
                Tab(icon: Icon(Icons.tune, size: 18), text: 'Ayarlar'),
                Tab(icon: Icon(Icons.crop_rotate, size: 18), text: 'Dönüşüm'),
                Tab(icon: Icon(Icons.text_fields, size: 18), text: 'Metin'),
                Tab(
                  icon: Icon(Icons.emoji_emotions, size: 18),
                  text: 'Sticker',
                ),
                Tab(icon: Icon(Icons.filter_frames, size: 18), text: 'Çerçeve'),
              ],
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
                _buildStickerTab(),
                _buildFrameTab(),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
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
                    border: Border.all(
                      color: const Color(0xFF00D293),
                      width: 2,
                    ),
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
                    border: Border.all(
                      color: const Color(0xFF00D293),
                      width: 2,
                    ),
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
                          ? const Color(0xFF00D293)
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
                    color: isSelected
                        ? const Color(0xFF00D293)
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

  /// Ayarlar sekmesi
  Widget _buildAdjustmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildSlider(
            'Parlaklık',
            Icons.brightness_6,
            _state.brightness,
            (v) => setState(() => _state.brightness = v),
          ),
          _buildSlider(
            'Kontrast',
            Icons.contrast,
            _state.contrast,
            (v) => setState(() => _state.contrast = v),
          ),
          _buildSlider(
            'Doygunluk',
            Icons.palette,
            _state.saturation,
            (v) => setState(() => _state.saturation = v),
          ),
          _buildSlider(
            'Sıcaklık',
            Icons.thermostat,
            _state.temperature,
            (v) => setState(() => _state.temperature = v),
          ),
          _buildSlider(
            'Vignette',
            Icons.vignette,
            _state.vignette,
            (v) => setState(() => _state.vignette = v),
            min: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    IconData icon,
    double value,
    ValueChanged<double> onChanged, {
    double min = -100,
    double max = 100,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 6),
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF00D293),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFF00D293),
                overlayColor: const Color(0xFF00D293).withValues(alpha: 0.2),
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
          SizedBox(
            width: 30,
            child: Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.right,
            ),
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
                  ? const Color(0xFF00D293).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? const Color(0xFF00D293)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Transform.rotate(
              angle: rotateIcon ? math.pi / 2 : 0,
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF00D293) : Colors.white70,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF00D293) : Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Metin sekmesi
  Widget _buildTextTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Yeni metin ekle butonu
          ElevatedButton.icon(
            onPressed: _addNewText,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Metin Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D293),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00D293).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00D293)
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        text.text.length > 10
                            ? '${text.text.substring(0, 10)}...'
                            : text.text,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF00D293)
                              : Colors.white70,
                          fontSize: 12,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Renk seçici
        ...[
          Colors.white,
          Colors.black,
          Colors.red,
          Colors.blue,
          const Color(0xFF00D293),
        ].map(
          (color) => GestureDetector(
            onTap: () => setState(() => text.color = color),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: text.color == color
                      ? const Color(0xFF00D293)
                      : Colors.white.withValues(alpha: 0.3),
                  width: text.color == color ? 2 : 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Bold toggle
        IconButton(
          onPressed: () => setState(() => text.isBold = !text.isBold),
          icon: Icon(
            Icons.format_bold,
            color: text.isBold ? const Color(0xFF00D293) : Colors.white54,
          ),
          iconSize: 20,
        ),
        // Sil
        IconButton(
          onPressed: () => _deleteTextOverlay(text.id),
          icon: const Icon(Icons.delete, color: Colors.red),
          iconSize: 20,
        ),
      ],
    );
  }

  void _addNewText() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Metin Ekle',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Metninizi yazın...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF00D293)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    final newText = TextOverlay(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      text: controller.text,
                    );
                    _state.textOverlays.add(newText);
                    _selectedOverlayId = newText.id;
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D293),
              ),
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteTextOverlay(String id) {
    setState(() {
      _state.textOverlays.removeWhere((t) => t.id == id);
      if (_selectedOverlayId == id) _selectedOverlayId = null;
    });
  }

  /// Sticker sekmesi
  Widget _buildStickerTab() {
    return Column(
      children: [
        // Seçili sticker ayarları
        if (_selectedOverlayId != null && _getSelectedStickerOverlay() != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Boyut slider
                const Text(
                  'Boyut:',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: _getSelectedStickerOverlay()!.size,
                    min: 24,
                    max: 80,
                    activeColor: const Color(0xFF00D293),
                    onChanged: (v) => setState(() {
                      _getSelectedStickerOverlay()!.size = v;
                    }),
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteStickerOverlay(_selectedOverlayId!),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ],
            ),
          ),
        // Sticker grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: kStickerEmojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _addSticker(kStickerEmojis[index]),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      kStickerEmojis[index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
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

  /// Çerçeve sekmesi
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
                          ? Border.all(color: const Color(0xFF00D293), width: 2)
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
                    color: isSelected
                        ? const Color(0xFF00D293)
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

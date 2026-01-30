import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Gelişmiş profil resmi düzenleme ekranı
/// Filtreler, ayarlar (parlaklık, kontrast vb.) ve dönüşüm araçları içerir
class ImageFilterScreen extends StatefulWidget {
  final File imageFile;

  const ImageFilterScreen({super.key, required this.imageFile});

  @override
  State<ImageFilterScreen> createState() => _ImageFilterScreenState();
}

class _ImageFilterScreenState extends State<ImageFilterScreen>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Seçili filtre
  int _selectedFilterIndex = 0;

  // Ayar değerleri (-100 ile +100 arası, 0 = nötr)
  double _brightness = 0;
  double _contrast = 0;
  double _saturation = 0;
  double _temperature = 0;

  // Dönüşüm değerleri
  int _rotationAngle = 0; // 0, 90, 180, 270
  bool _flipHorizontal = false;
  bool _flipVertical = false;

  // Efekt değerleri
  double _vignette = 0;
  double _blur = 0;
  double _grain = 0;

  // UI state
  final GlobalKey _imageKey = GlobalKey();
  bool _isSaving = false;

  // Filtre tanımları
  final List<ImageFilter> _filters = [
    ImageFilter(name: 'Normal', matrix: null),
    ImageFilter(
      name: 'S/B',
      matrix: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
    ),
    ImageFilter(
      name: 'Sepia',
      matrix: const ColorFilter.matrix(<double>[
        0.393,
        0.769,
        0.189,
        0,
        0,
        0.349,
        0.686,
        0.168,
        0,
        0,
        0.272,
        0.534,
        0.131,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
    ),
    ImageFilter(
      name: 'Vivid',
      matrix: const ColorFilter.matrix(<double>[
        1.3,
        0,
        0,
        0,
        0,
        0,
        1.3,
        0,
        0,
        0,
        0,
        0,
        1.3,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
    ),
    ImageFilter(
      name: 'Cool',
      matrix: const ColorFilter.matrix(<double>[
        0.9,
        0,
        0,
        0,
        0,
        0,
        0.95,
        0,
        0,
        0,
        0,
        0,
        1.2,
        0,
        20,
        0,
        0,
        0,
        1,
        0,
      ]),
    ),
    ImageFilter(
      name: 'Warm',
      matrix: const ColorFilter.matrix(<double>[
        1.2,
        0,
        0,
        0,
        15,
        0,
        1.0,
        0,
        0,
        0,
        0,
        0,
        0.85,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
    ),
    ImageFilter(
      name: 'Fade',
      matrix: const ColorFilter.matrix(<double>[
        1.0,
        0,
        0,
        0,
        30,
        0,
        1.0,
        0,
        0,
        30,
        0,
        0,
        1.0,
        0,
        30,
        0,
        0,
        0,
        0.9,
        0,
      ]),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RepaintBoundary(
                  key: _imageKey,
                  child: ClipOval(child: _buildEditedImage(size: 320)),
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
              indicatorColor: const Color(0xFF00D293),
              labelColor: const Color(0xFF00D293),
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.auto_awesome, size: 20),
                  text: 'Filtreler',
                ),
                Tab(icon: Icon(Icons.tune, size: 20), text: 'Ayarlar'),
                Tab(icon: Icon(Icons.crop_rotate, size: 20), text: 'Dönüşüm'),
                Tab(icon: Icon(Icons.blur_on, size: 20), text: 'Efektler'),
              ],
            ),
          ),
          // Tab içerikleri
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFiltersTab(),
                _buildAdjustmentsTab(),
                _buildTransformTab(),
                _buildEffectsTab(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Düzenlenmiş resmi oluştur
  Widget _buildEditedImage({double? size}) {
    Widget image = Image.file(
      widget.imageFile,
      fit: BoxFit.cover,
      width: size,
      height: size,
    );

    // Filtre uygula
    final filterMatrix = _filters[_selectedFilterIndex].matrix;
    if (filterMatrix != null) {
      image = ColorFiltered(colorFilter: filterMatrix, child: image);
    }

    // Ayarlar uygula
    final adjustmentMatrix = _buildAdjustmentMatrix();
    if (adjustmentMatrix != null) {
      image = ColorFiltered(colorFilter: adjustmentMatrix, child: image);
    }

    // Dönüşümleri uygula - rotation
    if (_rotationAngle != 0) {
      image = Transform.rotate(
        angle: _rotationAngle * math.pi / 180,
        child: image,
      );
    }

    // Flip transformları
    if (_flipHorizontal || _flipVertical) {
      image = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _flipHorizontal ? -1.0 : 1.0,
          _flipVertical ? -1.0 : 1.0,
          1.0,
        ),
        child: image,
      );
    }

    // Vignette efekti
    if (_vignette > 0) {
      image = Stack(
        children: [
          image,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: _vignette / 100),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return image;
  }

  /// Ayar matrisini oluştur
  ColorFilter? _buildAdjustmentMatrix() {
    if (_brightness == 0 &&
        _contrast == 0 &&
        _saturation == 0 &&
        _temperature == 0) {
      return null;
    }

    // Parlaklık: -100 → +100, değer ekleme
    final b = _brightness * 2.55; // -255 ile +255 arası

    // Kontrast: 0.5 ile 2.0 arası çarpan
    final c = 1 + (_contrast / 100);
    final cOffset = 128 * (1 - c);

    // Doygunluk: 0 ile 2 arası çarpan
    final s = 1 + (_saturation / 100);
    const lumR = 0.3086;
    const lumG = 0.6094;
    const lumB = 0.0820;
    final sr = (1 - s) * lumR;
    final sg = (1 - s) * lumG;
    final sb = (1 - s) * lumB;

    // Sıcaklık
    final tempR = _temperature > 0 ? _temperature * 0.3 : 0.0;
    final tempB = _temperature < 0 ? -_temperature * 0.3 : 0.0;

    // Matris hesapla
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

  /// Filtreler sekmesi
  Widget _buildFiltersTab() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _filters.length,
      itemBuilder: (context, index) {
        final filter = _filters[index];
        final isSelected = _selectedFilterIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _selectedFilterIndex = index),
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
                          filter.matrix ??
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
                const SizedBox(height: 6),
                Text(
                  filter.name,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF00D293)
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
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
          _buildSlider('Parlaklık', Icons.brightness_6, _brightness, (v) {
            setState(() => _brightness = v);
          }),
          _buildSlider('Kontrast', Icons.contrast, _contrast, (v) {
            setState(() => _contrast = v);
          }),
          _buildSlider('Doygunluk', Icons.palette, _saturation, (v) {
            setState(() => _saturation = v);
          }),
          _buildSlider('Sıcaklık', Icons.thermostat, _temperature, (v) {
            setState(() => _temperature = v);
          }),
        ],
      ),
    );
  }

  /// Slider widget
  Widget _buildSlider(
    String label,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF00D293),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFF00D293),
                overlayColor: const Color(0xFF00D293).withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value,
                min: -100,
                max: 100,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 11),
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
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTransformButton(
              icon: Icons.rotate_left,
              label: 'Sola Döndür',
              onTap: () => setState(() {
                _rotationAngle = (_rotationAngle - 90) % 360;
              }),
            ),
            _buildTransformButton(
              icon: Icons.rotate_right,
              label: 'Sağa Döndür',
              onTap: () => setState(() {
                _rotationAngle = (_rotationAngle + 90) % 360;
              }),
            ),
            _buildTransformButton(
              icon: Icons.flip,
              label: 'Yatay Çevir',
              isActive: _flipHorizontal,
              onTap: () => setState(() {
                _flipHorizontal = !_flipHorizontal;
              }),
            ),
            _buildTransformButton(
              icon: Icons.flip,
              label: 'Dikey Çevir',
              rotateIcon: true,
              isActive: _flipVertical,
              onTap: () => setState(() {
                _flipVertical = !_flipVertical;
              }),
            ),
            _buildTransformButton(
              icon: Icons.refresh,
              label: 'Sıfırla',
              onTap: () => setState(() {
                _rotationAngle = 0;
                _flipHorizontal = false;
                _flipVertical = false;
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Dönüşüm butonu
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Efektler sekmesi
  Widget _buildEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildEffectSlider('Vignette', Icons.vignette, _vignette, (v) {
            setState(() => _vignette = v);
          }),
          _buildEffectSlider('Blur', Icons.blur_on, _blur, (v) {
            setState(() => _blur = v);
          }),
          _buildEffectSlider('Grain', Icons.grain, _grain, (v) {
            setState(() => _grain = v);
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _resetAllEffects,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Tüm Efektleri Sıfırla'),
            style: TextButton.styleFrom(foregroundColor: Colors.white54),
          ),
        ],
      ),
    );
  }

  /// Efekt slider
  Widget _buildEffectSlider(
    String label,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF00D293),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFF00D293),
                overlayColor: const Color(0xFF00D293).withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Tüm efektleri sıfırla
  void _resetAllEffects() {
    setState(() {
      _vignette = 0;
      _blur = 0;
      _grain = 0;
      _brightness = 0;
      _contrast = 0;
      _saturation = 0;
      _temperature = 0;
      _rotationAngle = 0;
      _flipHorizontal = false;
      _flipVertical = false;
      _selectedFilterIndex = 0;
    });
  }

  /// Düzenlenmiş resmi kaydet
  Future<void> _saveEditedImage() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Hiçbir değişiklik yapılmadıysa orijinal dosyayı döndür
      if (_selectedFilterIndex == 0 &&
          _brightness == 0 &&
          _contrast == 0 &&
          _saturation == 0 &&
          _temperature == 0 &&
          _rotationAngle == 0 &&
          !_flipHorizontal &&
          !_flipVertical &&
          _vignette == 0) {
        if (mounted) Navigator.pop(context, widget.imageFile);
        return;
      }

      // Düzenlenmiş resmi yakala
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

      // Yeni dosya oluştur
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

/// Filtre model sınıfı
class ImageFilter {
  final String name;
  final ColorFilter? matrix;

  const ImageFilter({required this.name, this.matrix});
}

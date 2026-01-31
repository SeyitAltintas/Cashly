import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/// Isolate'de çalışacak resim işleme parametreleri
class _ImageTransformParams {
  final Uint8List imageData;
  final int rotation;
  final double fineRotation;
  final bool flipH;
  final bool flipV;

  _ImageTransformParams({
    required this.imageData,
    required this.rotation,
    required this.fineRotation,
    required this.flipH,
    required this.flipV,
  });
}

/// Isolate'de resim dönüştürme işlemi
Uint8List? _transformImageIsolate(_ImageTransformParams params) {
  try {
    img.Image? image = img.decodeImage(params.imageData);
    if (image == null) return null;

    // Toplam rotasyon (90° döndürme + fine rotation)
    final totalRotation = params.rotation + params.fineRotation;
    if (totalRotation != 0) {
      image = img.copyRotate(image, angle: totalRotation);
    }

    // Flip uygula
    if (params.flipH) {
      image = img.flipHorizontal(image);
    }
    if (params.flipV) {
      image = img.flipVertical(image);
    }

    return Uint8List.fromList(img.encodePng(image));
  } catch (e) {
    return null;
  }
}

/// Özelleştirilebilir profil resmi kırpma ekranı
/// crop_your_image paketi ile tam kontrol sağlar
class ImageCropScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropScreen({super.key, required this.imageFile});

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final _cropController = CropController();
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _isCropping = false;
  int _rotationDegrees = 0;
  bool _showGrid = false; // Varsayılan olarak kapalı
  bool _flipHorizontal = false;
  bool _flipVertical = false;
  double _fineRotation = 0.0; // -180 ile +180 arası, 1° adımlarla

  // Resmi yeniden yüklemek için key
  UniqueKey _cropKey = UniqueKey();

  // Tema renkleri
  static const Color _primaryColor = Color(0xFF075174);
  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _surfaceColor = Color(0xFF1A1A1A);
  static const Color _cardColor = Color(0xFF242424);

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    setState(() {
      _imageData = bytes;
      _isLoading = false;
    });
  }

  /// Görsel döndürme (anlık, resim işlemesi yok)
  void _rotateImage(int degrees) {
    setState(() {
      _rotationDegrees = (_rotationDegrees + degrees) % 360;
    });
  }

  /// Görsel çevirme (anlık, resim işlemesi yok)
  void _flipImage({bool horizontal = false, bool vertical = false}) {
    setState(() {
      if (horizontal) _flipHorizontal = !_flipHorizontal;
      if (vertical) _flipVertical = !_flipVertical;
    });
  }

  /// Tüm değişiklikleri sıfırla (döndürme, çevirme, ayarlar, resim pozisyonu)
  void _resetAll() {
    setState(() {
      // Dönüşümleri sıfırla
      _rotationDegrees = 0;
      _fineRotation = 0.0;
      _flipHorizontal = false;
      _flipVertical = false;
      // Ayarları sıfırla
      _showGrid = false;
      // Resmi varsayılan boyuta getirmek için Crop widget'ını yeniden oluştur
      _cropKey = UniqueKey();
    });
  }

  Future<void> _onCrop() async {
    if (_isCropping) return;
    setState(() => _isCropping = true);
    _cropController.crop();
  }

  void _handleCropResult(CropResult result) {
    switch (result) {
      case CropSuccess(:final croppedImage):
        _saveCroppedImage(croppedImage);
      case CropFailure(:final cause):
        setState(() => _isCropping = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Kırpma hatası: $cause')));
        }
    }
  }

  Future<void> _saveCroppedImage(Uint8List croppedData) async {
    try {
      Uint8List finalData = croppedData;

      // Eğer döndürme veya çevirme varsa uygula
      if (_rotationDegrees != 0 ||
          _fineRotation != 0 ||
          _flipHorizontal ||
          _flipVertical) {
        final transformedData = await compute(
          _transformImageIsolate,
          _ImageTransformParams(
            imageData: croppedData,
            rotation: _rotationDegrees,
            fineRotation: _fineRotation,
            flipH: _flipHorizontal,
            flipV: _flipVertical,
          ),
        );
        if (transformedData != null) {
          finalData = transformedData;
        }
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final croppedPath = '${directory.path}/cropped_$timestamp.png';
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(finalData);

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      setState(() => _isCropping = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kaydetme hatası: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: const Text(
          'Fotoğrafı Kırp',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isCropping)
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
              onPressed: (_isLoading || _imageData == null) ? null : _onCrop,
              child: Text(
                'Devam',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: (_isLoading || _imageData == null)
                      ? Colors.white38
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Kırpma alanı
          Expanded(
            child: _isLoading || _imageData == null
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  )
                : ClipRect(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(
                          (_rotationDegrees + _fineRotation) * math.pi / 180,
                        )
                        ..multiply(
                          Matrix4.diagonal3Values(
                            _flipHorizontal ? -1.0 : 1.0,
                            _flipVertical ? -1.0 : 1.0,
                            1.0,
                          ),
                        ),
                      child: Crop(
                        key: _cropKey,
                        controller: _cropController,
                        image: _imageData!,
                        aspectRatio: 1,
                        withCircleUi: true,
                        interactive: true,
                        fixCropRect: true,
                        baseColor: _backgroundColor,
                        maskColor: Colors.black.withValues(alpha: 0.75),
                        cornerDotBuilder: (size, edgeAlignment) =>
                            const SizedBox.shrink(),
                        overlayBuilder: _showGrid
                            ? (context, rect) => ClipOval(
                                child: CustomPaint(
                                  size: Size(rect.width, rect.height),
                                  painter: _GridPainter(
                                    gridColor: Colors.white.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        onCropped: _handleCropResult,
                      ),
                    ),
                  ),
          ),
          // Tümünü Sıfırla - Sheet dışında, sağa yaslı
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _resetAll,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
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
          // Modern alt menü - Yeniden tasarlanmış
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fine Rotation Slider
                _buildSliderRow(
                  icon: Icons.rotate_right,
                  label: 'Döndürme',
                  value: _fineRotation,
                  min: -180,
                  max: 180,
                  divisions: 360,
                  valueLabel: '${_fineRotation.round()}°',
                  onChanged: (v) => setState(() => _fineRotation = v),
                ),
                const SizedBox(height: 12),
                // Buton satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(
                      icon: Icons.rotate_left,
                      label: '90° Sol',
                      onTap: () => _rotateImage(-90),
                    ),
                    _buildIconButton(
                      icon: Icons.rotate_right,
                      label: '90° Sağ',
                      onTap: () => _rotateImage(90),
                    ),
                    _buildIconButton(
                      icon: Icons.flip,
                      label: 'Yatay',
                      onTap: () => _flipImage(horizontal: true),
                      isActive: _flipHorizontal,
                    ),
                    _buildIconButton(
                      icon: Icons.flip,
                      label: 'Dikey',
                      rotateIcon: true,
                      onTap: () => _flipImage(vertical: true),
                      isActive: _flipVertical,
                    ),
                    _buildIconButton(
                      icon: _showGrid ? Icons.grid_on : Icons.grid_off,
                      label: 'Grid',
                      onTap: () => setState(() => _showGrid = !_showGrid),
                      isActive: _showGrid,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dikey düzende ikon butonu - ikon üstte, etiket altta
  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool rotateIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: _primaryColor, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: rotateIcon ? math.pi / 2 : 0,
              child: Icon(
                icon,
                color: isActive ? _primaryColor : Colors.white70,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isActive ? _primaryColor : Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Slider satırı - ikon, etiket, slider ve değer göstergesi
  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            valueLabel,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white54,
              fontSize: 11,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// overlayBuilder için grid çizen painter
/// crop alanının boyutlarına göre çalışır
class _GridPainter extends CustomPainter {
  final Color gridColor;

  _GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // 3x3 grid çizgilerini çiz
    final gridSpacingX = size.width / 3;
    final gridSpacingY = size.height / 3;

    // Dikey çizgiler
    for (int i = 1; i < 3; i++) {
      final x = gridSpacingX * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Yatay çizgiler
    for (int i = 1; i < 3; i++) {
      final y = gridSpacingY * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

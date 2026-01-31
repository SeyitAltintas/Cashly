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
  final bool flipH;
  final bool flipV;

  _ImageTransformParams({
    required this.imageData,
    required this.rotation,
    required this.flipH,
    required this.flipV,
  });
}

/// Isolate'de resim dönüştürme işlemi
Uint8List? _transformImageIsolate(_ImageTransformParams params) {
  try {
    img.Image? image = img.decodeImage(params.imageData);
    if (image == null) return null;

    // Rotasyon uygula
    if (params.rotation == 90) {
      image = img.copyRotate(image, angle: 90);
    } else if (params.rotation == 180) {
      image = img.copyRotate(image, angle: 180);
    } else if (params.rotation == 270) {
      image = img.copyRotate(image, angle: 270);
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

class _ImageCropScreenState extends State<ImageCropScreen>
    with SingleTickerProviderStateMixin {
  final _cropController = CropController();
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _isCropping = false;
  int _rotationDegrees = 0;
  bool _showGrid = true;
  bool _flipHorizontal = false;
  bool _flipVertical = false;
  
  // Resmi yeniden yüklemek için key
  UniqueKey _cropKey = UniqueKey();

  late TabController _tabController;

  // Tema renkleri
  static const Color _primaryColor = Color(0xFF075174);
  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _surfaceColor = Color(0xFF1A1A1A);
  static const Color _cardColor = Color(0xFF242424);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadImage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _resetTransforms() {
    setState(() {
      _rotationDegrees = 0;
      _flipHorizontal = false;
      _flipVertical = false;
    });
  }

  /// Tüm değişiklikleri sıfırla (döndürme, çevirme, ayarlar, resim pozisyonu)
  void _resetAll() {
    setState(() {
      // Dönüşümleri sıfırla
      _rotationDegrees = 0;
      _flipHorizontal = false;
      _flipVertical = false;
      // Ayarları sıfırla
      _showGrid = true;
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
      if (_rotationDegrees != 0 || _flipHorizontal || _flipVertical) {
        final transformedData = await compute(
          _transformImageIsolate,
          _ImageTransformParams(
            imageData: croppedData,
            rotation: _rotationDegrees,
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
              onPressed: _onCrop,
              child: const Text(
                'Devam',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: _primaryColor,
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
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateZ(_rotationDegrees * math.pi / 180)
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
                      // Dairesel alan sabit, kullanıcı sadece resmi hareket ettirir
                      interactive: true,
                      // Kırpma alanının boyutunu sabitlemek için fixArea kullan
                      fixCropRect: true,
                      baseColor: _backgroundColor,
                      maskColor: Colors.black.withValues(alpha: 0.75),
                      // Köşe noktalarını gizle (boş widget)
                      cornerDotBuilder: (size, edgeAlignment) =>
                          const SizedBox.shrink(),
                      // Grid overlay - crop alanı ile senkronize
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
          // Modern alt menü
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(color: _surfaceColor),
            child: Column(
              children: [
                // Tümünü Sıfırla butonu
                GestureDetector(
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
                // Pill-style tab seçici
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(height: 36, text: 'Döndür'),
                      Tab(height: 36, text: 'Çevir'),
                      Tab(height: 36, text: 'Ayarlar'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tab içerikleri
                SizedBox(
                  height: 80,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRotateTab(),
                      _buildFlipTab(),
                      _buildSettingsTab(),
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

  /// Döndürme sekmesi
  Widget _buildRotateTab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.rotate_left,
          label: '90° Sol',
          onTap: () => _rotateImage(-90),
        ),
        _buildActionButton(
          icon: Icons.rotate_right,
          label: '90° Sağ',
          onTap: () => _rotateImage(90),
        ),
        _buildActionButton(
          icon: Icons.refresh,
          label: 'Sıfırla',
          onTap: _resetTransforms,
          isActive: _rotationDegrees != 0 || _flipHorizontal || _flipVertical,
        ),
      ],
    );
  }

  /// Çevirme sekmesi
  Widget _buildFlipTab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.flip,
          label: 'Yatay',
          onTap: () => _flipImage(horizontal: true),
          isActive: _flipHorizontal,
        ),
        _buildActionButton(
          icon: Icons.flip,
          label: 'Dikey',
          rotateIcon: true,
          onTap: () => _flipImage(vertical: true),
          isActive: _flipVertical,
        ),
      ],
    );
  }

  /// Ayarlar sekmesi
  Widget _buildSettingsTab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: _showGrid ? Icons.grid_on : Icons.grid_off,
          label: 'Grid',
          onTap: () => setState(() => _showGrid = !_showGrid),
          isActive: _showGrid,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool rotateIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? _primaryColor : _cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: rotateIcon ? math.pi / 2 : 0,
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.white70,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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

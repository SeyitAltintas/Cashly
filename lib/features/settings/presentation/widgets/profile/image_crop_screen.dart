import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  } catch (e) {
    return null;
  }
}

/// Snap noktaları - slider mıknatıs efekti için
const _snapAngles = [
  0.0,
  45.0,
  90.0,
  135.0,
  180.0,
  -45.0,
  -90.0,
  -135.0,
  -180.0,
];
const _snapThreshold = 3.0; // ±3° tolerans

/// Undo/Redo için state snapshot'ı
class _CropStateSnapshot {
  final int rotationDegrees;
  final double animatedRotation;
  final double fineRotation;
  final bool flipHorizontal;
  final bool flipVertical;
  final bool showGrid;

  const _CropStateSnapshot({
    required this.rotationDegrees,
    required this.animatedRotation,
    required this.fineRotation,
    required this.flipHorizontal,
    required this.flipVertical,
    required this.showGrid,
  });
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
    with TickerProviderStateMixin {
  final _cropController = CropController();
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _isCropping = false;
  bool _isCropReady = false;
  int _rotationDegrees = 0;
  bool _showGrid = false;
  bool _flipHorizontal = false;
  bool _flipVertical = false;
  double _fineRotation = 0.0;
  bool _showOriginal = false;

  // Resmi yeniden yüklemek için key
  UniqueKey _cropKey = UniqueKey();

  // Döndürme animasyonu
  late final AnimationController _rotationAnimController;
  late Animation<double> _rotationAnimation;
  double _animatedRotation = 0.0;

  // Zoom göstergesi
  double _zoomLevel = 1.0;
  bool _showZoomBadge = false;
  Timer? _zoomBadgeTimer;

  // Haptic - önceki slider değeri (snap ve 0° geçiş tespiti için)
  double _previousSliderValue = 0.0;

  // Undo/Redo stacks
  final List<_CropStateSnapshot> _undoStack = [];
  final List<_CropStateSnapshot> _redoStack = [];

  // Tema renkleri
  static const Color _primaryColor = Color(0xFF075174);
  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _surfaceColor = Color(0xFF1A1A1A);
  static const Color _cardColor = Color(0xFF242424);

  @override
  void initState() {
    super.initState();
    _loadImage();

    // Döndürme animasyon controller'ı
    _rotationAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _rotationAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _rotationAnimController.addListener(() {
      setState(() {
        _animatedRotation = _rotationAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _rotationAnimController.dispose();
    _zoomBadgeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    setState(() {
      _imageData = bytes;
      _isLoading = false;
    });
  }

  /// Görsel döndürme — animasyonlu
  void _rotateImage(int degrees) {
    _pushUndo();
    HapticFeedback.mediumImpact();

    final from = _animatedRotation;
    final to = from + degrees.toDouble();

    _rotationAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(
        parent: _rotationAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _rotationAnimController.forward(from: 0);

    setState(() {
      _rotationDegrees = (_rotationDegrees + degrees) % 360;
    });
  }

  /// Görsel çevirme
  void _flipImage({bool horizontal = false, bool vertical = false}) {
    _pushUndo();
    HapticFeedback.lightImpact();
    setState(() {
      if (horizontal) _flipHorizontal = !_flipHorizontal;
      if (vertical) _flipVertical = !_flipVertical;
    });
  }

  /// Slider değer değişimi — snap + haptic
  void _onSliderChanged(double rawValue) {
    double snapped = rawValue;

    // Snap noktalarına mıknatısla
    for (final snapAngle in _snapAngles) {
      if ((rawValue - snapAngle).abs() <= _snapThreshold) {
        snapped = snapAngle;
        break;
      }
    }

    // Haptic feedback: snap noktasına geçiş
    final wasSnapped = _isSnapped(_previousSliderValue);
    final isNowSnapped = _isSnapped(snapped);

    if (!wasSnapped && isNowSnapped) {
      // Snap noktasına girdi
      if (snapped == 0.0) {
        HapticFeedback.mediumImpact(); // 0° geçişinde güçlü
      } else {
        HapticFeedback.selectionClick(); // Diğer snap noktalarında hafif
      }
    }

    _previousSliderValue = snapped;
    setState(() => _fineRotation = snapped);
  }

  bool _isSnapped(double value) {
    return _snapAngles.any((snap) => (value - snap).abs() < 0.5);
  }

  /// Mevcut state'in snapshot'ını al
  _CropStateSnapshot get _currentSnapshot => _CropStateSnapshot(
    rotationDegrees: _rotationDegrees,
    animatedRotation: _animatedRotation,
    fineRotation: _fineRotation,
    flipHorizontal: _flipHorizontal,
    flipVertical: _flipVertical,
    showGrid: _showGrid,
  );

  /// Undo stack'ine mevcut durumu kaydet
  void _pushUndo() {
    _undoStack.add(_currentSnapshot);
    _redoStack.clear();
    if (_undoStack.length > 30) _undoStack.removeAt(0);
  }

  /// Geri al
  void _undo() {
    if (_undoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    _redoStack.add(_currentSnapshot);
    final snapshot = _undoStack.removeLast();
    _restoreSnapshot(snapshot);
  }

  /// İleri al
  void _redo() {
    if (_redoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    _undoStack.add(_currentSnapshot);
    final snapshot = _redoStack.removeLast();
    _restoreSnapshot(snapshot);
  }

  /// Snapshot'tan durumu geri yükle
  void _restoreSnapshot(_CropStateSnapshot snapshot) {
    final from = _animatedRotation;
    final to = snapshot.animatedRotation;
    if (from != to) {
      _rotationAnimation = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(
          parent: _rotationAnimController,
          curve: Curves.easeOutCubic,
        ),
      );
      _rotationAnimController.forward(from: 0);
    }

    setState(() {
      _rotationDegrees = snapshot.rotationDegrees;
      _fineRotation = snapshot.fineRotation;
      _previousSliderValue = snapshot.fineRotation;
      _flipHorizontal = snapshot.flipHorizontal;
      _flipVertical = snapshot.flipVertical;
      _showGrid = snapshot.showGrid;
    });
  }

  /// willUpdateScale callback — Crop widget'ı zoom değiştirdiğinde çağrılır
  bool _onWillUpdateScale(double newScale) {
    if (newScale < 1.0 || newScale > 10.0) return false;
    setState(() {
      _zoomLevel = newScale;
      _showZoomBadge = true;
    });
    _zoomBadgeTimer?.cancel();
    _zoomBadgeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showZoomBadge = false);
    });
    return true;
  }

  /// Çift dokunma ile zoom sıfırlama
  void _resetZoom() {
    HapticFeedback.lightImpact();
    setState(() {
      _zoomLevel = 1.0;
      _showZoomBadge = true;
    });
    // Kararma olmadan sıfırla
    if (_imageData != null) {
      _cropController.image = _imageData!;
    }
    _zoomBadgeTimer?.cancel();
    _zoomBadgeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showZoomBadge = false);
    });
  }

  /// Tüm değişiklikleri sıfırla
  void _resetAll() {
    _undoStack.clear();
    _redoStack.clear();
    HapticFeedback.mediumImpact();

    // Döndürme animasyonunu sıfırla
    final from = _animatedRotation;
    _rotationAnimation = Tween<double>(begin: from, end: 0).animate(
      CurvedAnimation(
        parent: _rotationAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _rotationAnimController.forward(from: 0);

    setState(() {
      _rotationDegrees = 0;
      _fineRotation = 0.0;
      _previousSliderValue = 0.0;
      _flipHorizontal = false;
      _flipVertical = false;
      _showGrid = false;
      _zoomLevel = 1.0;
    });

    // Crop widget'ını yeniden oluşturmak yerine controller üzerinden sıfırla
    // Bu sayede resim tekrar parse edilmez ve kararma olmaz
    if (_imageData != null) {
      _cropController.image = _imageData!;
    }
  }

  Future<void> _onCrop() async {
    if (_isCropping) return;
    if (_imageData == null) return;
    HapticFeedback.heavyImpact();
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
      final croppedPath = '${directory.path}/cropped_$timestamp.jpg';
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

  /// Toplam görsel döndürme açısı (animasyonlu 90° + fine rotation)
  double get _totalVisualRotation {
    if (_rotationAnimController.isAnimating) {
      return (_animatedRotation + _fineRotation) * math.pi / 180;
    }
    return (_rotationDegrees + _fineRotation) * math.pi / 180;
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
          style: TextStyle(
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
          else if (_isCropReady)
            TextButton(
              onPressed: _onCrop,
              child: const Text(
                'Devam',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Kırpma alanı — zoom göstergesi ile
          Expanded(
            child: _isLoading || _imageData == null
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  )
                : Stack(
                    children: [
                      // Kırpma widget'ı — çift dokunma ile zoom sıfırlama
                      GestureDetector(
                        onDoubleTap: _resetZoom,
                        child: ClipRect(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: _showOriginal
                                ? Matrix4.identity()
                                : (Matrix4.identity()
                                    ..rotateZ(_totalVisualRotation)
                                    ..multiply(
                                      Matrix4.diagonal3Values(
                                        _flipHorizontal ? -1.0 : 1.0,
                                        _flipVertical ? -1.0 : 1.0,
                                        1.0,
                                      ),
                                    )),
                            child: Crop(
                              key: _cropKey,
                              controller: _cropController,
                              image: _imageData!,
                              aspectRatio: 1,
                              initialRectBuilder:
                                  InitialRectBuilder.withSizeAndRatio(
                                    size: 0.85,
                                  ),
                              withCircleUi: true,
                              interactive: true,
                              fixCropRect: true,
                              baseColor: _backgroundColor,
                              maskColor: Colors.black.withValues(alpha: 0.85),
                              willUpdateScale: _onWillUpdateScale,
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
                              onStatusChanged: (status) {
                                if (status == CropStatus.ready) {
                                  setState(() => _isCropReady = true);
                                }
                              },
                              onCropped: _handleCropResult,
                            ),
                          ),
                        ),
                      ),

                      // Zoom badge — sağ üst köşe
                      Positioned(
                        top: 12,
                        right: 12,
                        child: AnimatedOpacity(
                          opacity: _showZoomBadge ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_zoomLevel.toStringAsFixed(1)}x',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Modern alt menü
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                // Undo/Redo + Tümünü Sıfırla
                _buildUndoRedoRow(),
                const SizedBox(height: 8),
                // Fine Rotation Slider - snap + haptic
                _buildSliderRow(
                  icon: Icons.rotate_right,
                  label: 'Döndürme',
                  value: _fineRotation,
                  min: -180,
                  max: 180,
                  divisions: 360,
                  valueLabel: '${_fineRotation.round()}°',
                  onChanged: _onSliderChanged,
                  onChangeStart: (_) => _pushUndo(),
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
                      onTap: () {
                        _pushUndo();
                        HapticFeedback.selectionClick();
                        setState(() => _showGrid = !_showGrid);
                      },
                      isActive: _showGrid,
                    ),
                    _buildCompareButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dikey düzende ikon butonu
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
          border: Border.all(
            color: isActive ? _primaryColor : Colors.transparent,
            width: 1.5,
          ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Karşılaştırma butonu
  Widget _buildCompareButton() {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _showOriginal = true);
      },
      onTapUp: (_) => setState(() => _showOriginal = false),
      onTapCancel: () => setState(() => _showOriginal = false),
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _showOriginal ? _cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _showOriginal ? _primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.compare,
              color: _showOriginal ? _primaryColor : Colors.white70,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              'Karşılaştır',
              style: TextStyle(
                fontFamily: 'Inter',
                color: _showOriginal ? _primaryColor : Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Undo/Redo + Tümünü Sıfırla satırı
  Widget _buildUndoRedoRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          _buildUndoRedoButton(
            icon: Icons.undo_rounded,
            label: 'Geri Al',
            onTap: _undo,
            isEnabled: _undoStack.isNotEmpty,
          ),
          const SizedBox(width: 12),
          _buildUndoRedoButton(
            icon: Icons.redo_rounded,
            label: 'İleri Al',
            onTap: _redo,
            isEnabled: _redoStack.isNotEmpty,
          ),
          const Spacer(),
          GestureDetector(
            onTap: _resetAll,
            child: Text(
              'Tümünü Sıfırla',
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

  /// Slider satırı — snap göstergeli
  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeStart,
  }) {
    final isAtSnap = _isSnapped(value);

    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white70,
            fontSize: 10,
          ),
          maxLines: 1,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _primaryColor,
              inactiveTrackColor: Colors.white24,
              thumbColor: isAtSnap ? Colors.white : _primaryColor,
              overlayColor: _primaryColor.withValues(alpha: 0.2),
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: isAtSnap ? 7 : 6,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChangeStart: onChangeStart,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            valueLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              color: isAtSnap ? Colors.white70 : Colors.white54,
              fontSize: 10,
              fontWeight: isAtSnap ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(0);
          },
          child: Icon(
            Icons.restart_alt_rounded,
            color: value != 0 ? _primaryColor : Colors.white24,
            size: 18,
          ),
        ),
      ],
    );
  }
}

/// overlayBuilder için grid çizen painter
class _GridPainter extends CustomPainter {
  final Color gridColor;

  _GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final gridSpacingX = size.width / 3;
    final gridSpacingY = size.height / 3;

    for (int i = 1; i < 3; i++) {
      final x = gridSpacingX * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 1; i < 3; i++) {
      final y = gridSpacingY * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';

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
  int _rotationTurns = 0;

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

  void _rotateLeft() {
    setState(() {
      _rotationTurns = (_rotationTurns - 1) % 4;
    });
  }

  void _rotateRight() {
    setState(() {
      _rotationTurns = (_rotationTurns + 1) % 4;
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
      // Kırpılmış resmi geçici dosyaya kaydet
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final croppedPath = '${directory.path}/cropped_$timestamp.png';
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(croppedData);

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
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text('Fotoğrafı Kırp'),
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
                    color: Color(0xFF00D293),
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
          // Kırpma alanı
          Expanded(
            child: _isLoading || _imageData == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00D293)),
                  )
                : RotatedBox(
                    quarterTurns: _rotationTurns,
                    child: Crop(
                      controller: _cropController,
                      image: _imageData!,
                      aspectRatio: 1,
                      withCircleUi: true,
                      baseColor: const Color(0xFF0D0D0D),
                      maskColor: Colors.black.withValues(alpha: 0.7),
                      cornerDotBuilder: (size, edgeAlignment) => Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D293),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                      onCropped: _handleCropResult,
                    ),
                  ),
          ),
          // Alt kontrol çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.rotate_left,
                  label: 'Sola Döndür',
                  onTap: _rotateLeft,
                ),
                _buildControlButton(
                  icon: Icons.rotate_right,
                  label: 'Sağa Döndür',
                  onTap: _rotateRight,
                ),
                _buildControlButton(
                  icon: Icons.crop_square,
                  label: 'Sıfırla',
                  onTap: () {
                    setState(() => _rotationTurns = 0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: Colors.white70, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

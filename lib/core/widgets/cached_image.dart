import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_cache_service.dart';
import 'package:http/http.dart' as http;

/// Önbellekli görsel widget'ı
/// Network görselleri için otomatik cache yönetimi sağlar.
class CachedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  final ImageCacheService _cacheService = ImageCacheService();
  ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Önce cache'den bak
      final cachedBytes = await _cacheService.get(widget.imageUrl);

      if (cachedBytes != null) {
        if (mounted) {
          setState(() {
            _imageProvider = MemoryImage(cachedBytes);
            _isLoading = false;
          });
        }
        return;
      }

      // Cache'de yoksa network'ten yükle
      if (widget.imageUrl.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.imageUrl));

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          // Cache'e kaydet
          await _cacheService.put(widget.imageUrl, bytes);

          if (mounted) {
            setState(() {
              _imageProvider = MemoryImage(bytes);
              _isLoading = false;
            });
          }
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      } else {
        // Lokal dosya
        final file = File(widget.imageUrl);
        if (await file.exists()) {
          if (mounted) {
            setState(() {
              _imageProvider = FileImage(file);
              _isLoading = false;
            });
          }
        } else {
          throw Exception('File not found');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isLoading) {
      child =
          widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.withValues(alpha: 0.2),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    } else if (_hasError || _imageProvider == null) {
      child =
          widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.withValues(alpha: 0.2),
            child: Icon(
              Icons.broken_image,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          );
    } else {
      child = Image(
        image: _imageProvider!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    return child;
  }
}

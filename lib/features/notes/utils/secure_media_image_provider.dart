import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/core/di/injection_container.dart';

class SecureMediaImageProvider extends ImageProvider<SecureMediaImageProvider> {
  const SecureMediaImageProvider(this.mediaId);

  final String mediaId;

  @override
  Future<SecureMediaImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<SecureMediaImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(SecureMediaImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: key.mediaId,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('MediaId: $mediaId'),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(SecureMediaImageProvider key, ImageDecoderCallback decode) async {
    final repo = getIt<NoteRepository>();
    
    // Yalnızca kimliği doğrulanmış kullanıcıda çözülebilir!
    final bytes = await repo.getSecureMedia(key.mediaId);
    
    if (bytes == null) {
      throw Exception('Gizli medya bulunamadı veya kilitli: ${key.mediaId}');
    }
    
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is SecureMediaImageProvider && other.mediaId == mediaId;
  }

  @override
  int get hashCode => mediaId.hashCode;
}

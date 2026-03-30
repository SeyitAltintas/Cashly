import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ImageUtils {
  static ImageProvider getProfileImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/image/default_avatar.png'); // Fallback, though UI usually handles null check
    }

    if (path.startsWith('data:image')) {
      final base64Str = path.split(',').last;
      return MemoryImage(base64Decode(base64Str));
    } else if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('lib/') || path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }
}

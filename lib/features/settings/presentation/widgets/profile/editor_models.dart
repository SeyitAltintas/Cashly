import 'package:flutter/material.dart';

/// Filtre preset tanımları
class FilterPreset {
  final String name;
  final String emoji;
  final ColorFilter? colorFilter;

  const FilterPreset({
    required this.name,
    required this.emoji,
    this.colorFilter,
  });
}

/// Metin overlay modeli
class TextOverlay {
  final String id;
  String text;
  Offset position;
  double fontSize;
  Color color;
  String fontFamily;
  bool isBold;
  bool isItalic;
  double rotation;

  TextOverlay({
    required this.id,
    required this.text,
    this.position = const Offset(0.5, 0.5),
    this.fontSize = 24,
    this.color = Colors.white,
    this.fontFamily = 'Inter',
    this.isBold = false,
    this.isItalic = false,
    this.rotation = 0,
  });

  TextOverlay copyWith({
    String? text,
    Offset? position,
    double? fontSize,
    Color? color,
    String? fontFamily,
    bool? isBold,
    bool? isItalic,
    double? rotation,
  }) {
    return TextOverlay(
      id: id,
      text: text ?? this.text,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      rotation: rotation ?? this.rotation,
    );
  }
}

/// Sticker overlay modeli
class StickerOverlay {
  final String id;
  String emoji;
  Offset position;
  double size;
  double rotation;

  StickerOverlay({
    required this.id,
    required this.emoji,
    this.position = const Offset(0.5, 0.5),
    this.size = 48,
    this.rotation = 0,
  });

  StickerOverlay copyWith({
    String? emoji,
    Offset? position,
    double? size,
    double? rotation,
  }) {
    return StickerOverlay(
      id: id,
      emoji: emoji ?? this.emoji,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }
}

/// Çerçeve overlay modeli
class FrameOverlay {
  final String name;
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final List<Color>? gradientColors;
  final bool isGradient;

  const FrameOverlay({
    required this.name,
    required this.borderColor,
    this.borderWidth = 8,
    this.cornerRadius = 0,
    this.gradientColors,
    this.isGradient = false,
  });
}

/// Editor durumu
class EditorState {
  // Filtre
  int selectedFilterIndex;

  // Ayarlar
  double brightness;
  double contrast;
  double saturation;
  double temperature;
  double tint;
  double shadows;
  double highlights;
  double sharpness;

  // Dönüşüm
  int rotationAngle;
  bool flipHorizontal;
  bool flipVertical;

  // Efektler
  double vignette;

  // Overlays
  List<TextOverlay> textOverlays;
  List<StickerOverlay> stickerOverlays;
  int? selectedFrameIndex;

  EditorState({
    this.selectedFilterIndex = 0,
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.temperature = 0,
    this.tint = 0,
    this.shadows = 0,
    this.highlights = 0,
    this.sharpness = 0,
    this.rotationAngle = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.vignette = 0,
    List<TextOverlay>? textOverlays,
    List<StickerOverlay>? stickerOverlays,
    this.selectedFrameIndex,
  }) : textOverlays = textOverlays ?? [],
       stickerOverlays = stickerOverlays ?? [];

  bool get hasChanges =>
      selectedFilterIndex != 0 ||
      brightness != 0 ||
      contrast != 0 ||
      saturation != 0 ||
      temperature != 0 ||
      tint != 0 ||
      shadows != 0 ||
      highlights != 0 ||
      sharpness != 0 ||
      rotationAngle != 0 ||
      flipHorizontal ||
      flipVertical ||
      vignette != 0 ||
      textOverlays.isNotEmpty ||
      stickerOverlays.isNotEmpty ||
      selectedFrameIndex != null;

  void reset() {
    selectedFilterIndex = 0;
    brightness = 0;
    contrast = 0;
    saturation = 0;
    temperature = 0;
    tint = 0;
    shadows = 0;
    highlights = 0;
    sharpness = 0;
    rotationAngle = 0;
    flipHorizontal = false;
    flipVertical = false;
    vignette = 0;
    textOverlays.clear();
    stickerOverlays.clear();
    selectedFrameIndex = null;
  }
}

/// Önceden tanımlı filtreler
final List<FilterPreset> kFilterPresets = [
  const FilterPreset(name: 'Normal', emoji: '🎨', colorFilter: null),
  const FilterPreset(
    name: 'S/B',
    emoji: '⚫',
    colorFilter: ColorFilter.matrix(<double>[
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
  const FilterPreset(
    name: 'Sepia',
    emoji: '🟤',
    colorFilter: ColorFilter.matrix(<double>[
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
  const FilterPreset(
    name: 'Vintage',
    emoji: '📷',
    colorFilter: ColorFilter.matrix(<double>[
      0.9,
      0.1,
      0,
      0,
      20,
      0,
      0.9,
      0.1,
      0,
      10,
      0,
      0.1,
      0.8,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Vivid',
    emoji: '🌈',
    colorFilter: ColorFilter.matrix(<double>[
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
  const FilterPreset(
    name: 'Cool',
    emoji: '❄️',
    colorFilter: ColorFilter.matrix(<double>[
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
  const FilterPreset(
    name: 'Warm',
    emoji: '🔥',
    colorFilter: ColorFilter.matrix(<double>[
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
  const FilterPreset(
    name: 'Fade',
    emoji: '🌫️',
    colorFilter: ColorFilter.matrix(<double>[
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
  const FilterPreset(
    name: 'Chrome',
    emoji: '✨',
    colorFilter: ColorFilter.matrix(<double>[
      1.2,
      -0.1,
      -0.1,
      0,
      0,
      -0.1,
      1.2,
      -0.1,
      0,
      0,
      -0.1,
      -0.1,
      1.2,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Clarendon',
    emoji: '🎭',
    colorFilter: ColorFilter.matrix(<double>[
      1.2,
      0,
      0,
      0,
      10,
      0,
      1.1,
      0,
      0,
      5,
      0,
      0,
      1.3,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Gingham',
    emoji: '🏡',
    colorFilter: ColorFilter.matrix(<double>[
      0.9,
      0.1,
      0,
      0,
      20,
      0.1,
      0.9,
      0,
      0,
      20,
      0,
      0,
      0.9,
      0.1,
      20,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Juno',
    emoji: '🌅',
    colorFilter: ColorFilter.matrix(<double>[
      1.1,
      0,
      0,
      0,
      20,
      0,
      1.0,
      0,
      0,
      0,
      0,
      0,
      0.9,
      0,
      -20,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Lark',
    emoji: '🐦',
    colorFilter: ColorFilter.matrix(<double>[
      1.0,
      0.1,
      0.1,
      0,
      0,
      0,
      1.1,
      0,
      0,
      10,
      0,
      0.1,
      1.0,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Moon',
    emoji: '🌙',
    colorFilter: ColorFilter.matrix(<double>[
      0.25,
      0.5,
      0.25,
      0,
      30,
      0.25,
      0.5,
      0.25,
      0,
      30,
      0.25,
      0.5,
      0.25,
      0,
      30,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Nashville',
    emoji: '🎸',
    colorFilter: ColorFilter.matrix(<double>[
      1.2,
      0.1,
      0,
      0,
      30,
      0,
      1.0,
      0,
      0,
      0,
      0,
      0,
      0.8,
      0,
      20,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  // === YENİ FİLTRELER ===
  const FilterPreset(
    name: 'Dramatic',
    emoji: '🎭',
    colorFilter: ColorFilter.matrix(<double>[
      1.3,
      0,
      0,
      0,
      -20,
      0,
      1.3,
      0,
      0,
      -20,
      0,
      0,
      1.3,
      0,
      -20,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Noir',
    emoji: '🖤',
    colorFilter: ColorFilter.matrix(<double>[
      0.3,
      0.6,
      0.1,
      0,
      -10,
      0.3,
      0.6,
      0.1,
      0,
      -10,
      0.3,
      0.6,
      0.1,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Cyberpunk',
    emoji: '🌃',
    colorFilter: ColorFilter.matrix(<double>[
      1.2,
      0,
      0.3,
      0,
      0,
      0,
      0.9,
      0.2,
      0,
      0,
      0.3,
      0,
      1.3,
      0,
      20,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Sunset',
    emoji: '🌅',
    colorFilter: ColorFilter.matrix(<double>[
      1.3,
      0.1,
      0,
      0,
      15,
      0,
      1.0,
      0,
      0,
      5,
      0,
      0,
      0.8,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Ocean',
    emoji: '🌊',
    colorFilter: ColorFilter.matrix(<double>[
      0.8,
      0,
      0,
      0,
      0,
      0,
      1.0,
      0.1,
      0,
      10,
      0,
      0.1,
      1.3,
      0,
      30,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Forest',
    emoji: '🌲',
    colorFilter: ColorFilter.matrix(<double>[
      0.9,
      0.1,
      0,
      0,
      0,
      0.1,
      1.2,
      0.1,
      0,
      10,
      0,
      0.1,
      0.9,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Dreamy',
    emoji: '💭',
    colorFilter: ColorFilter.matrix(<double>[
      1.0,
      0.1,
      0.1,
      0,
      30,
      0.1,
      1.0,
      0.1,
      0,
      30,
      0.1,
      0.1,
      1.0,
      0,
      30,
      0,
      0,
      0,
      0.95,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Retro 80',
    emoji: '📼',
    colorFilter: ColorFilter.matrix(<double>[
      1.1,
      0,
      0.2,
      0,
      10,
      0,
      1.0,
      0.1,
      0,
      0,
      0.3,
      0,
      0.9,
      0,
      20,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Matte',
    emoji: '🎞️',
    colorFilter: ColorFilter.matrix(<double>[
      1.0,
      0,
      0,
      0,
      15,
      0,
      1.0,
      0,
      0,
      15,
      0,
      0,
      1.0,
      0,
      15,
      0,
      0,
      0,
      0.9,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Hi Contrast',
    emoji: '⚡',
    colorFilter: ColorFilter.matrix(<double>[
      1.5,
      0,
      0,
      0,
      -40,
      0,
      1.5,
      0,
      0,
      -40,
      0,
      0,
      1.5,
      0,
      -40,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Lowlight',
    emoji: '🌙',
    colorFilter: ColorFilter.matrix(<double>[
      1.1,
      0,
      0,
      0,
      20,
      0,
      1.1,
      0,
      0,
      15,
      0,
      0,
      1.2,
      0,
      25,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Pastel',
    emoji: '🎀',
    colorFilter: ColorFilter.matrix(<double>[
      0.9,
      0.1,
      0.1,
      0,
      40,
      0.1,
      0.9,
      0.1,
      0,
      40,
      0.1,
      0.1,
      0.9,
      0,
      40,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Bronze',
    emoji: '🥉',
    colorFilter: ColorFilter.matrix(<double>[
      1.1,
      0.2,
      0,
      0,
      10,
      0.1,
      0.9,
      0.1,
      0,
      5,
      0,
      0.1,
      0.7,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Arctic',
    emoji: '❄️',
    colorFilter: ColorFilter.matrix(<double>[
      0.9,
      0,
      0.1,
      0,
      10,
      0,
      1.0,
      0.1,
      0,
      15,
      0.1,
      0.1,
      1.2,
      0,
      30,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Autumn',
    emoji: '🍂',
    colorFilter: ColorFilter.matrix(<double>[
      1.2,
      0.2,
      0,
      0,
      20,
      0,
      0.95,
      0.1,
      0,
      5,
      0,
      0,
      0.8,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
  const FilterPreset(
    name: 'Invert',
    emoji: '🔄',
    colorFilter: ColorFilter.matrix(<double>[
      -1,
      0,
      0,
      0,
      255,
      0,
      -1,
      0,
      0,
      255,
      0,
      0,
      -1,
      0,
      255,
      0,
      0,
      0,
      1,
      0,
    ]),
  ),
];

/// Önceden tanımlı sticker'lar
const List<String> kStickerEmojis = [
  '😀',
  '😍',
  '🥳',
  '😎',
  '🤩',
  '😇',
  '❤️',
  '💕',
  '💖',
  '💗',
  '💓',
  '💜',
  '⭐',
  '🌟',
  '✨',
  '💫',
  '🌈',
  '☀️',
  '🎉',
  '🎊',
  '🎁',
  '🎈',
  '🎀',
  '🎯',
  '🔥',
  '💯',
  '👑',
  '💎',
  '🏆',
  '🎭',
  '🌸',
  '🌺',
  '🌻',
  '🌹',
  '🌷',
  '💐',
  '🦋',
  '🐝',
  '🐞',
  '🌿',
  '🍀',
  '🌴',
];

/// Önceden tanımlı çerçeveler
final List<FrameOverlay> kFramePresets = [
  const FrameOverlay(
    name: 'Yok',
    borderColor: Colors.transparent,
    borderWidth: 0,
  ),
  const FrameOverlay(name: 'Beyaz', borderColor: Colors.white, borderWidth: 8),
  const FrameOverlay(name: 'Siyah', borderColor: Colors.black, borderWidth: 8),
  // Polaroid - Geniş beyaz alt kenar efekti
  const FrameOverlay(
    name: 'Polaroid',
    borderColor: Color(0xFFFAFAFA),
    borderWidth: 14,
  ),
  const FrameOverlay(
    name: 'Altın',
    borderColor: Color(0xFFFFD700),
    borderWidth: 10,
    gradientColors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
    isGradient: true,
  ),
  const FrameOverlay(
    name: 'Gümüş',
    borderColor: Color(0xFFC0C0C0),
    borderWidth: 10,
    gradientColors: [Color(0xFFC0C0C0), Color(0xFFE8E8E8), Color(0xFFC0C0C0)],
    isGradient: true,
  ),
  const FrameOverlay(
    name: 'Neon',
    borderColor: Color(0xFF00D293),
    borderWidth: 6,
    gradientColors: [Color(0xFF00D293), Color(0xFF00BFFF), Color(0xFF00D293)],
    isGradient: true,
  ),
  // Neon Pink
  const FrameOverlay(
    name: 'Neon Pembe',
    borderColor: Color(0xFFFF1493),
    borderWidth: 6,
    gradientColors: [Color(0xFFFF1493), Color(0xFFFF69B4), Color(0xFFFF1493)],
    isGradient: true,
  ),
  // Ocean - Deniz mavisi tonları
  const FrameOverlay(
    name: 'Okyanus',
    borderColor: Color(0xFF006994),
    borderWidth: 8,
    gradientColors: [Color(0xFF006994), Color(0xFF40E0D0), Color(0xFF006994)],
    isGradient: true,
  ),
  // Sunset - Gün batımı tonları
  const FrameOverlay(
    name: 'Günbatımı',
    borderColor: Color(0xFFFF4500),
    borderWidth: 8,
    gradientColors: [
      Color(0xFFFF4500),
      Color(0xFFFF8C00),
      Color(0xFFFFD700),
      Color(0xFFFF8C00),
      Color(0xFFFF4500),
    ],
    isGradient: true,
  ),
  const FrameOverlay(
    name: 'Retro',
    borderColor: Color(0xFF8B4513),
    borderWidth: 12,
    cornerRadius: 0,
  ),
  // Vintage - Eski foto efekti
  const FrameOverlay(
    name: 'Vintage',
    borderColor: Color(0xFFD2B48C),
    borderWidth: 10,
  ),
  const FrameOverlay(
    name: 'Gökkuşağı',
    borderColor: Colors.red,
    borderWidth: 8,
    gradientColors: [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
    ],
    isGradient: true,
  ),
  // Mint - Soft mint yeşili
  const FrameOverlay(
    name: 'Mint',
    borderColor: Color(0xFF98FB98),
    borderWidth: 8,
  ),
  // Lavender - Lavanta tonu
  const FrameOverlay(
    name: 'Lavanta',
    borderColor: Color(0xFFE6E6FA),
    borderWidth: 8,
    gradientColors: [Color(0xFFE6E6FA), Color(0xFFDDA0DD), Color(0xFFE6E6FA)],
    isGradient: true,
  ),
];

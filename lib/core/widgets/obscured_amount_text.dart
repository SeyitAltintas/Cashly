import 'dart:ui';
import 'package:flutter/material.dart';

/// Bakiye ve tutarları blur (Glassmorphism) efektiyle gizleyen yardımcı widget
class ObscuredAmountText extends StatelessWidget {
  final String text;
  final bool isObscured;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ObscuredAmountText(
    this.text, {
    super.key,
    required this.isObscured,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    if (!isObscured) {
      return Text(text, style: style, textAlign: textAlign);
    }

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}

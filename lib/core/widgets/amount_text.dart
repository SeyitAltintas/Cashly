import 'package:flutter/material.dart';

/// Para miktarlarında kuruş kısmını (ondalık) ve para birimini küçülten yardımcı widget.
/// Örn: "1.500,00 ₺" metnini alıp "1.500" kısmını normal, ",00 ₺" kısmını küçük yazar.
class AmountText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double smallTextScale;
  final double smallTextOpacity;

  const AmountText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.smallTextScale = 0.70,
    this.smallTextOpacity = 0.65,
  });

  @override
  Widget build(BuildContext context) {
    // Virgül veya nokta indeksini bul (sondan arıyoruz ki binlik ayracı olmasın)
    final commaIndex = text.lastIndexOf(',');
    final dotIndex = text.lastIndexOf('.');
    
    // Sondan sonrasını kuruş olarak kabul et (Son 6 karakter içindeyse)
    int decimalIndex = -1;
    if (commaIndex > dotIndex && commaIndex > text.length - 7) {
      decimalIndex = commaIndex;
    } else if (dotIndex > commaIndex && dotIndex > text.length - 7) {
      decimalIndex = dotIndex;
    }

    final defaultStyle = style ?? DefaultTextStyle.of(context).style;

    // Eğer ondalık kısım bulunamadıysa metni doğrudan döndür
    if (decimalIndex == -1) {
      return Text(text, style: defaultStyle, textAlign: textAlign);
    }

    final mainPart = text.substring(0, decimalIndex);
    final decimalPart = text.substring(decimalIndex);

    final smallStyle = defaultStyle.copyWith(
      fontSize: (defaultStyle.fontSize ?? 14) * smallTextScale,
      color: defaultStyle.color?.withValues(alpha: smallTextOpacity),
    );

    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      text: TextSpan(
        style: defaultStyle,
        children: [
          TextSpan(text: mainPart),
          TextSpan(text: decimalPart, style: smallStyle),
        ],
      ),
    );
  }
}

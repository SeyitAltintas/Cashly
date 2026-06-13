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
    // Ondalık kısım ve para birimini bul (Örn: ",00", ",00 ₺", ".50 $")
    // \d{2} -> tam olarak 2 hane kuruş. 
    // (?!\d) -> Ardından başka rakam gelmemeli (binlik ayırıcıları elemek için, Örn: 61.137'deki .13)
    // (?:\s?[₺\$€£])? -> Opsiyonel para birimi.
    final regex = RegExp(r'[.,]\d{2}(?!\d)(?:\s?[₺\$€£])?');
    final matches = regex.allMatches(text);

    final defaultStyle = style ?? DefaultTextStyle.of(context).style;

    // Eğer ondalık kısım bulunamadıysa metni doğrudan döndür
    if (matches.isEmpty) {
      return Text(text, style: defaultStyle, textAlign: textAlign);
    }

    final match = matches.last;

    final decimalIndex = match.start;
    final mainPart = text.substring(0, decimalIndex);
    final decimalPart = match.group(0)!;
    final suffixPart = text.substring(match.end);

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
          if (suffixPart.isNotEmpty) TextSpan(text: suffixPart),
        ],
      ),
    );
  }
}

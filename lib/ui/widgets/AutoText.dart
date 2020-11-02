import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';

class AutoText extends StatelessWidget {
  final String text;
  final bool softWrap;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextOverflow overflow;
  final Color color;
  final double fontSize;
  final int maxLines;
  final TextStyle style;
  final FontWeight fontWeight;

  AutoText(this.text,
      {this.softWrap = true,
      this.textAlign = TextAlign.right,
      this.textDirection = TextDirection.rtl,
      this.color,
      this.overflow = TextOverflow.fade,
      this.maxLines,
      this.style,
      this.fontWeight,
      this.fontSize});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text ?? "",
      softWrap: softWrap,
      textAlign: textAlign,
      textDirection: textDirection,
      overflow: overflow,
      maxLines: maxLines,
      style: style ??
          TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
    );
  }
}

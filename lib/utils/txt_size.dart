import 'package:flutter/material.dart';

Size getTxtSize(String txt, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: txt, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

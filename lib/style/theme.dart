import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';

class WakTheme {
  static final wakTheme = ThemeData(
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: WakColor.grey100,
    dividerTheme: const DividerThemeData(
      space: 13,
      thickness: 1,
      indent: 3,
      endIndent: 3,
      color: WakColor.grey200,
    ),
  );
}

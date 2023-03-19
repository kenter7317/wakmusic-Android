import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';

Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (_, child) => Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: WakColor.dark.withOpacity(0.25),
              blurRadius: 20,
            ),
          ],
        ),
        child: child,
      ),
    ),
    child: child,
  );
}
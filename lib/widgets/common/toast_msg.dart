import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

class ToastMsg extends StatelessWidget {
  const ToastMsg({
    super.key,
    required this.msg,
    this.size = 40,
  });

  final String msg;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WakColor.grey900.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          msg,
          style: WakText.txt14L.copyWith(color: WakColor.grey25),
          maxLines: (size != 40) ? size ~/ 40 : null,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

class ToastMsg extends StatelessWidget {
  const ToastMsg({super.key, required this.msg});
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WakColor.grey900.withOpacity(0.8),
          borderRadius: BorderRadius.circular(90),
        ),
        child: Text(
          msg,
          style: WakText.txt14L.copyWith(color: WakColor.grey25),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
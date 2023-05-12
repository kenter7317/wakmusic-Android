import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/style/colors.dart';

class TextWithDot extends StatelessWidget {
  const TextWithDot({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/icons/ic_16_dot.svg',
          width: 16,
          height: 16,
        ),
        Expanded(
          child: Text(
            text,
            style: WakText.txt12L.copyWith(color: WakColor.grey500),
            maxLines: 5,
          ),
        )
      ],
    );
  }
}

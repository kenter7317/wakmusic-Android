import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

class Item extends StatelessWidget {
  const Item({super.key, this.onTap, required this.text});
  final void Function()? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 61,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: WakColor.grey200),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: WakText.txt16M.copyWith(color: WakColor.grey900),
              ),
            ),
            const SizedBox(width: 16),
            SvgPicture.asset(
              'assets/icons/ic_24_arrow_right.svg',
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

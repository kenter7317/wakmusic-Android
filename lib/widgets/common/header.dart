import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    this.isBtnLeft = true,
    this.onTap,
    required this.headerTxt,
  });
  final bool isBtnLeft;
  final void Function()? onTap;
  final String headerTxt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: (isBtnLeft) ? 20 : null,
            right: (isBtnLeft) ? null : 20,
            child: GestureDetector(
              onTap: () {
                if (onTap != null) onTap!();
                Navigator.pop(context);
              },
              child: SvgPicture.asset(
                'assets/icons/ic_32_${(isBtnLeft) ? 'arrow_left' : 'close_header'}.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
          Center(
            child: Text(
              headerTxt,
              style: WakText.txt16M.copyWith(color: WakColor.grey900),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

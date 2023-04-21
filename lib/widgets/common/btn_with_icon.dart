import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

enum BtnSizeType {
  big(60, 12, 24),
  small(52, 8, 32);

  const BtnSizeType(this.height, this.borderRadius, this.iconSize);
  final double height;
  final double borderRadius;
  final double iconSize;
}

class BtnWithIcon extends StatelessWidget {
  const BtnWithIcon({
    super.key,
    required this.onTap,
    required this.type,
    required this.iconName,
    required this.btnText,
  });
  final void Function() onTap;
  final BtnSizeType type;
  final String iconName;
  final String btnText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: type.height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          border: Border.all(color: WakColor.grey200.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(type.borderRadius),
        ),
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 31),
              child: SvgPicture.asset(
                'assets/icons/$iconName.svg',
                width: type.iconSize,
                height: type.iconSize,
              ),
            ),
            Center(
              child: Text(
                btnText,
                style: ((type == BtnSizeType.big) ? WakText.txt16M : WakText.txt14MH).copyWith(color: WakColor.grey900),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

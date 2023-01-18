import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayBtns extends StatelessWidget {
  const PlayBtns({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          _buildBtn(
            context,
            iconName: 'ic_32_play_all',
            btnName: '전체재생',
            onTap: () {
              /* play all the songs */
            },
          ),
          const SizedBox(width: 8),
          _buildBtn(
            context,
            iconName: 'ic_32_random_900',
            btnName: '랜덤재생',
            onTap: () {
              /* play all the songs with shuffle */
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(BuildContext context, {required String iconName, required String btnName, required void Function()? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            border: Border.all(color: WakColor.grey200.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Spacer(flex: 4),
              SvgPicture.asset(
                'assets/icons/$iconName.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 4),
              Text(
                btnName,
                style: WakText.txt14MH.copyWith(color: WakColor.grey900),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
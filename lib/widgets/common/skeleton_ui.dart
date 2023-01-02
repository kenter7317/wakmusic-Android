import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonText extends StatelessWidget {
  const SkeletonText({super.key, required this.wakTxtStyle, this.width});
  final TextStyle wakTxtStyle;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: WakColor.grey200,
      highlightColor: WakColor.grey100,
      child: SizedBox(
        width: width,
        height: wakTxtStyle.fontSize! * wakTxtStyle.height!,
        child: Center(
          child: Container(
            height: wakTxtStyle.fontSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: WakColor.grey200,
            ),
          ),
        ),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, required this.child});
  final Widget child; // child should not be transparent

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: WakColor.grey200,
      highlightColor: WakColor.grey100,
      child: child,
    );
  }
}
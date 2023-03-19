import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

enum BtnType {
  edit(Colors.transparent, WakColor.grey300, WakColor.grey400, '편집'),
  done(Colors.transparent, WakColor.lightBlue, WakColor.lightBlue, '완료'),
  cancel(Colors.white, WakColor.grey200, WakColor.grey400, '취소');

  const BtnType(this.bgColor, this.borderColor, this.txtColor, this.btnText);
  final Color bgColor;
  final Color borderColor;
  final Color txtColor;
  final String btnText;
}

class EditBtn extends StatelessWidget {
  const EditBtn({super.key, required this.type, this.btnText});
  final BtnType type;
  final String? btnText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: type.bgColor,
        border: Border.all(color: type.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        btnText ?? type.btnText,
        style: WakText.txt12B.copyWith(color: type.txtColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

enum PopUpType { txtOneBtn, txtTwoBtn, contentBtn }

class PopUp extends StatelessWidget {
  const PopUp(
      {super.key, required this.type, this.msg, this.negFunc, this.posFunc});
  final PopUpType type;
  final String? msg;
  final void Function()? negFunc;
  final void Function()? posFunc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (type != PopUpType.contentBtn)
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(40, 60, 40, 32),
                  child: Text(
                    msg ?? '',
                    maxLines: 2,
                    style: WakText.txt18M.copyWith(color: WakColor.grey900),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: WakColor.grey900,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                ),
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (type != PopUpType.txtOneBtn)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    if (negFunc != null) negFunc!();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: WakColor.grey400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        type == PopUpType.contentBtn ? '다시보지 않기' : '취소',
                        style: WakText.txt18M.copyWith(color: WakColor.grey25),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (posFunc != null) posFunc!();
                Navigator.pop(context);
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: WakColor.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    type == PopUpType.contentBtn ? '닫기' : '확인',
                    style: WakText.txt18M.copyWith(color: WakColor.grey25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

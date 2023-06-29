import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

enum PopUpType {
  txtOneBtn('', '확인'),
  txtTwoBtn('취소', '확인'),
  contentBtn('다시보지 않기', '닫기');

  const PopUpType(this.negText, this.posText);

  final String negText, posText;
}

class PopUp extends StatelessWidget {
  const PopUp({
    super.key,
    required this.type,
    this.msg,
    this.negText,
    this.posText,
    this.negFunc,
    this.posFunc,
  });

  final PopUpType type;
  final String? msg, negText, posText;
  final void Function()? negFunc;
  final void Function()? posFunc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (type != PopUpType.contentBtn)
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 60, 40, 32),
              child: Text(
                msg ?? '',
                maxLines: 10,
                style: WakText.txt18M,
                textAlign: TextAlign.center,
              ),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Container(
                color: WakColor.grey900,
                child: ExtendedImage.network(
                  '${API.static.url}/notice/$msg',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (type != PopUpType.txtOneBtn)
                  _buildButton(
                      context, negFunc, false, negText ?? type.negText),
                if (type != PopUpType.txtOneBtn) const SizedBox(width: 8),
                _buildButton(context, posFunc, true, posText ?? type.posText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, void Function()? onTap, bool result,
      String btnText) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context, result);
          if (onTap != null) onTap();
        },
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (result) ? WakColor.lightBlue : WakColor.grey400,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            btnText,
            style: WakText.txt18M.copyWith(color: WakColor.grey25),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

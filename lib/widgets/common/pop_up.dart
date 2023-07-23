import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:wakmusic/models_v2/notice.dart';
import 'package:wakmusic/screens/notice/notice_detail_view.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/utils/status_nav_color.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';

enum PopUpType {
  txtOneBtn('', '확인'),
  txtTwoBtn('취소', '확인'),
  contentBtn('다시보지 않기', '닫기');

  const PopUpType(this.negText, this.posText);

  final String negText, posText;
}

class PopUp extends StatefulWidget {
  const PopUp({
    super.key,
    required this.type,
    this.msg,
    this.negText,
    this.posText,
    this.negFunc,
    this.posFunc,
    this.notices,
  });

  final PopUpType type;
  final String? msg, negText, posText;
  final void Function()? negFunc;
  final void Function()? posFunc;
  final List<Notice>? notices;

  @override
  State<PopUp> createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  late double width;
  int noticeIdx = 1;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
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
          if (widget.type != PopUpType.contentBtn || widget.notices == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 60, 40, 32),
              child: Text(
                widget.msg ?? '',
                maxLines: 10,
                style: WakText.txt18M,
                textAlign: TextAlign.center,
              ),
            )
          else
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  SizedBox(
                    height: width,
                    child: ScrollSnapList(
                      itemCount: widget.notices!.length,
                      itemBuilder: (context, idx) =>
                          _buildNotice(context, widget.notices![idx]),
                      itemSize: width,
                      onItemFocus: (idx) {
                        setState(() {
                          noticeIdx = idx + 1;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 10,
                    child: Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: WakColor.grey900.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.5),
                      ),
                      child: Text(
                        '$noticeIdx/${widget.notices!.length}',
                        style: WakText.txt14MH.copyWith(color: WakColor.grey25),
                      ),
                    ),
                  )
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (widget.type != PopUpType.txtOneBtn)
                  _buildButton(context, widget.negFunc, false,
                      widget.negText ?? widget.type.negText),
                if (widget.type != PopUpType.txtOneBtn)
                  const SizedBox(width: 8),
                _buildButton(context, widget.posFunc, true,
                    widget.posText ?? widget.type.posText),
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

  Widget _buildNotice(BuildContext context, Notice notice) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .push(
              pageRouteBuilder(
                page: NoticeDetailView(notice: notice),
                scope: null,
                offset: const Offset(0.0, 1.0),
              ),
            )
            .whenComplete(
              () => statusNavColor(context, ScreenType.etc),
            );
      },
      child: Container(
        color: WakColor.grey900,
        child: ExtendedImage.network(
          '${API.static.url}/notice/${notice.thumbnail}',
          width: width,
          height: width,
        ),
      ),
    );
  }
}

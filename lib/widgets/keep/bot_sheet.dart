import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:wakmusic/widgets/common/edit_btn.dart';
import 'package:wakmusic/widgets/common/toast_msg.dart';

enum BotSheetType {
  createList('플레이리스트 만들기', '플레이리스트 제목', '플레이리스트 생성'),
  editList('플레이리스트 수정하기', '플레이리스트 제목', '플레이리스트 수정'),
  loadList('플레이리스트 가져오기', '플레이리스트 코드', '가져오기'),
  shareList('플레이리스트 공유하기', '플레이리스트 코드', '확인'),
  selProfile('프로필을 선택해주세요', '', '완료');

  const BotSheetType(this.title, this.formTitle, this.btnText);
  final String title;
  final String formTitle;
  final String btnText;
}

enum FormType {
  none(WakColor.grey200, ''),
  error(WakColor.pink, '오류 메시지 노출'),
  enable(WakColor.blue, '사용할 수 있는 제목입니다.');

  const FormType(this.color, this.errorMsg);
  final Color color;
  final String errorMsg;
}

class BotSheet extends StatefulWidget {
  const BotSheet({super.key, required this.type, this.func, this.initialValue});
  final BotSheetType type;
  final void Function()? func;
  final String? initialValue;

  @override
  State<BotSheet> createState() => _BotSheetState();
}

class _BotSheetState extends State<BotSheet> {
  final int _maxLength = 12;
  FormType _type = FormType.none;
  int _profileIdx = 0;
  late final TextEditingController _fieldText;

  @override
  void initState() {
    super.initState();
    _fieldText = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.type.title,
                  style: WakText.txt18M.copyWith(color: WakColor.grey900),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 40),
                  child: (widget.type != BotSheetType.selProfile)
                    ? _buildPlaylistSheet(context)
                    : _buildProfileSheet(context),
                ),
                GestureDetector(
                  onTap: () {
                    if (_type == FormType.enable) {
                      if (widget.func != null) widget.func!();
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (_type == FormType.enable) ? WakColor.lightBlue : WakColor.grey300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.type.btnText,
                      style: WakText.txt18M.copyWith(color: WakColor.grey25),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistSheet(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.type.formTitle,
          style: WakText.txt16L.copyWith(color: WakColor.grey400),
        ),
        const SizedBox(height: 4),
        () {
          switch (widget.type) {
            case BotSheetType.createList:
            case BotSheetType.editList:
              return _buildCreateForm(context);
            case BotSheetType.loadList:
              return _buildLoadForm(context);
            case BotSheetType.shareList:
              return _buildShareForm(context);
            default:
              return Container();
          }
        }(),
      ],
    );
  }

  Widget _buildBaseForm(BuildContext context,
    {required UnderlineInputBorder border, required String hintText,
    int? maxLength, required void Function(String)? onChanged}) {
    return TextFormField(
      controller: _fieldText,
      style: WakText.txt20M.copyWith(height: 1.0, color: WakColor.grey800),
      cursorColor: WakColor.grey900,
      maxLength: maxLength,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: border,
        focusedBorder: border,
        enabledBorder: border,
        hintText: hintText,
        hintStyle: WakText.txt20M.copyWith(color: WakColor.grey400),
        suffixIcon: (_fieldText.text != '')
          ? GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                _fieldText.clear();
                setState(() => _type = FormType.none);
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 16, 0, 16),
                child: EditBtn(type: BtnType.cancel),
              ),
            )
          : null,
      ),
    );
  }

  Widget _buildCreateForm(BuildContext context) {
    return Column(
      children: [
        _buildBaseForm(
          context,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: _type.color),
          ),
          hintText: '플레이리스트 제목을 입력하세요.',
          maxLength: _maxLength,
          onChanged: (value) {
            setState(() {
              if (value.isEmpty || value == widget.initialValue) {
                _type = FormType.none;
              } else if (value == 'test') { /* error condition */
                _type = FormType.error;
              } else {
                _type = FormType.enable;
              }
            });
          }
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                _type.errorMsg,
                style: WakText.txt12L.copyWith(color: _type.color),
              ),
            ),
            Text(
              '${_fieldText.text.length}자',
              style: WakText.txt12L.copyWith(color: WakColor.lightBlue),
              textAlign: TextAlign.right,
            ),
            Text(
              '/$_maxLength자',
              style: WakText.txt12L.copyWith(color: WakColor.grey500),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadForm(BuildContext context) {
    return Column(
      children: [
        _buildBaseForm(
          context,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: FormType.none.color),
          ),
          hintText: '코드를 입력해주세요.',
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                _type = FormType.none;
              } else {
                _type = FormType.enable;
              }
            });
          }
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/ic_16_dot.svg',
              width: 16,
              height: 16,
            ),
            Expanded(
              child: Text(
                '플레이리스트 코드로 플레이리스트를 가져올 수 있습니다.',
                style: WakText.txt12L.copyWith(color: WakColor.grey500),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildShareForm(BuildContext context) {
    _type = FormType.enable;
    return Column(
      children: [
        TextFormField(
          initialValue: widget.initialValue,
          readOnly: true,
          enableInteractiveSelection: false,
          style: WakText.txt20M.copyWith(color: WakColor.grey800),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: FormType.none.color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: FormType.none.color),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: FormType.none.color),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.initialValue));
                showToastWidget(
                  context: context,
                  position: const StyledToastPosition(
                    align: Alignment.bottomCenter,
                    offset: 56,
                  ),
                  animation: StyledToastAnimation.slideFromBottomFade,
                  reverseAnimation: StyledToastAnimation.fade,
                  const ToastMsg(msg: '복사가 완료되었습니다.'),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 0, 12),
                child: SvgPicture.asset(
                  'assets/icons/ic_32_copy.svg',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(maxWidth: 40),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/ic_16_dot.svg',
              width: 16,
              height: 16,
            ),
            Text(
              '플레이리스트 코드로 플레이리스트를 공유할 수 있습니다.',
              style: WakText.txt12L.copyWith(color: WakColor.grey500),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildProfileSheet(BuildContext context) {
    _type = FormType.enable;
    return Column(
      children: [
        Row(
          children: List.generate(
            7,
            (idx) {
              if (idx % 2 == 0){
                return _buildProfile(context, idx ~/ 2);
              } else {
                return const SizedBox(width: 10);
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            7,
            (idx) {
              if (idx % 2 == 0){
                return _buildProfile(context, 4 + idx ~/ 2);
              } else {
                return const SizedBox(width: 10);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context, int idx) {
    List<String> profile = [
      '팬치',
      '이파리',
      '둘기',
      '박쥐',
      '세균단',
      '고라니',
      '주폭도',
      '똥강아지'
    ];
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _profileIdx = idx),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (_profileIdx == idx) ? WakColor.lightBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Image.asset('assets/images/img_76_${profile[idx]}.png'),
        ),
      ),
    );
  }
}


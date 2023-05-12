import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/common/text_with_dot.dart';
import 'package:wakmusic/widgets/show_modal.dart';
import 'package:url_launcher/url_launcher.dart';

enum ContactAbout {
  bug('버그 제보', 2),
  feature('기능 제안', 2),
  addSong('노래 추가', 4),
  editSong('노래 수정', 4),
  chart('주간차트 영상', 1),
  select('문의하기', 0);

  const ContactAbout(this.btnName, this.checkN);
  final String btnName;
  final int checkN;
}

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  ContactAbout _about = ContactAbout.select;
  bool _enable = false;
  int _selectIdx = -1;
  final int _maxFields = 4;
  late final List<TextEditingController> _fieldTexts;
  late final List<ScrollController> _scrolls;
  late final List<FocusNode> _focusNodes;
  late final List<bool> _checkList;

  @override
  void initState() {
    super.initState();
    _fieldTexts = List.generate(_maxFields, (_) => TextEditingController());
    _scrolls = List.generate(_maxFields, (_) => ScrollController());
    _focusNodes = List.generate(
        _maxFields,
        (idx) => FocusNode()
          ..addListener(() {
            if (!_focusNodes[idx].hasFocus) {
              String text = '';
              for (String line in _fieldTexts[idx].text.split('\n')) {
                if (line.replaceAll(' ', '').isEmpty) continue;
                text += '$line\n';
              }
              if (text.endsWith('\n')) {
                text = text.substring(0, text.length - 1);
              }
              _fieldTexts[idx].text = text;
            }
          }));
    _checkList = List.filled(_maxFields, false);
  }

  @override
  void dispose() {
    for (int i = 0; i < _maxFields; i++) {
      _fieldTexts[i].dispose();
      _scrolls[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<ContactAbout, Widget> widgetMap = {
      ContactAbout.bug: _buildBug(),
      ContactAbout.feature: _buildFeature(),
      ContactAbout.addSong: _buildSong(true),
      ContactAbout.editSong: _buildSong(false),
      ContactAbout.chart: _buildChart(),
      ContactAbout.select: _buildSelect(),
    };
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              for (int i = 0; i < _maxFields; i++) {
                _focusNodes[i].unfocus();
              }
            });
          },
          child: Column(
            children: [
              Header(
                type: HeaderType.close,
                headerTxt: _about.btnName,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: widgetMap[_about]!,
                  ),
                ),
              ),
              _buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelect() {
    final int length = ContactAbout.values.length;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 것 관련해서 문의주셨나요?',
            style: WakText.txt20M.copyWith(color: WakColor.grey900),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48.0 * ((length + 1) ~/ 2) + 8.0 * ((length - 1) ~/ 2),
            child: GridView.builder(
              itemCount: length - 1,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 48,
              ),
              itemBuilder: (_, idx) => (_selectIdx == idx)
                  ? GestureDetector(
                      onTap: () => setState(() {
                        _enable = false;
                        _selectIdx = ContactAbout.values.length - 1;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: WakColor.blue),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: WakColor.dark.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                ContactAbout.values.elementAt(idx).btnName,
                                style: WakText.txt16M
                                    .copyWith(color: WakColor.blue),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              'assets/icons/ic_24_checkbox.svg',
                              width: 24,
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => setState(() {
                        _enable = true;
                        _selectIdx = idx;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          border: Border.all(color: WakColor.grey200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ContactAbout.values.elementAt(idx).btnName,
                          style:
                              WakText.txt16L.copyWith(color: WakColor.grey900),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBug() {
    return Column();
  }

  Widget _buildFeature() {
    return Column();
  }

  Widget _buildSong(bool isAdd) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          color: WakColor.grey100,
          child: (isAdd)
              ? Column(
                  children: [
                    const TextWithDot(
                        text:
                            '이세돌 분들이 부르신걸 이파리분들이 개인소장용으로 일부공개한 영상을 올리길 원하시면 ‘은수저’님에게 왁물원 채팅으로 부탁드립니다.'),
                    const SizedBox(height: 4),
                    const TextWithDot(
                        text: '왁뮤에 들어갈 수 있는 기준을 충족하는지 꼭 확인하시고 추가 요청해 주세요.'),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                              'https://whimsical.com/E3GQxrTaafVVBrhm55BNBS'),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '왁뮤 노래 포함 기준',
                            style:
                                WakText.txt12MH.copyWith(color: WakColor.blue),
                          ),
                          SvgPicture.asset(
                            'assets/icons/ic_16_arrow_right.svg',
                            width: 16,
                            height: 16,
                            color: WakColor.blue,
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : const TextWithDot(text: '조회수가 이상한 경우는 반응 영상이 포함되어 있을 수 있습니다.'),
        ),
        _buildForm(
          formIdx: 0,
          title: '아티스트',
        ),
        _buildForm(
          formIdx: 1,
          title: '노래 제목',
        ),
        _buildForm(
          formIdx: 2,
          title: '유튜브 링크',
        ),
        _buildForm(
          formIdx: 3,
          title: '내용',
          hasMaxLine: false,
          maxHeight: 104,
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Column(
      children: [
        _buildForm(
          formIdx: 0,
          title: '문의하실 내용을 적어주세요.',
          hasMaxLine: false,
        ),
      ],
    );
  }

  Widget _buildForm({
    required int formIdx,
    String? title,
    bool hasMaxLine = true,
    double maxHeight = 152,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              style: WakText.txt18M.copyWith(color: WakColor.grey900),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Scrollbar(
                thickness: hasMaxLine ? 0 : null,
                child: TextFormField(
                  controller: _fieldTexts[formIdx],
                  focusNode: _focusNodes[formIdx],
                  textInputAction: (hasMaxLine)
                      ? ((formIdx == _about.checkN - 1)
                          ? TextInputAction.done
                          : TextInputAction.next)
                      : TextInputAction.newline,
                  style: WakText.txt16M.copyWith(color: WakColor.grey600),
                  cursorColor: WakColor.grey900,
                  maxLines: (hasMaxLine) ? 1 : null,
                  autofocus: (formIdx == 0),
                  onTap: () {
                    setState(() {
                      _focusNodes[formIdx].requestFocus();
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _checkList[formIdx] = value.isNotEmpty;
                      _enable = _checkList
                          .sublist(0, _about.checkN)
                          .every((check) => check);
                    });
                  },
                  onFieldSubmitted: (value) {
                    setState(() {
                      _focusNodes[formIdx].unfocus();
                      if (formIdx < _about.checkN - 1) {
                        _focusNodes[formIdx + 1].requestFocus();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '내 답변',
                    hintStyle: WakText.txt16M.copyWith(color: WakColor.grey400),
                  ),
                ),
              ),
            ),
          ),
          Divider(
            indent: 0,
            endIndent: 0,
            color: (_focusNodes[formIdx].hasFocus)
                ? WakColor.blue
                : WakColor.grey200,
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    if (_about == ContactAbout.select) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            if (_enable) {
              setState(() {
                _about = ContactAbout.values.elementAt(_selectIdx);
                for (int i = 0; i < _maxFields; i++) {
                  _fieldTexts[i].clear();
                }
                _checkList.fillRange(0, _maxFields, false);
                _enable = false;
              });
            }
          },
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (_enable) ? WakColor.lightBlue : WakColor.grey300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '다음',
              style: WakText.txt18M.copyWith(color: WakColor.grey25),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _about = ContactAbout.select;
                  _enable = true;
                });
              },
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: WakColor.grey400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '이전',
                  style: WakText.txt18M.copyWith(color: WakColor.grey25),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                if (_enable) {
                  showModal(
                    context: context,
                    builder: (_) => PopUp(
                      type: PopUpType.txtTwoBtn,
                      msg: '작성하신 내용으로 등록하시겠습니까?',
                      posFunc: () => showModal(
                        context: context,
                        builder: (_) => const PopUp(
                          type: PopUpType.txtOneBtn,
                          msg: '문의가 등록되었습니다.\n도움을 주셔서 감사합니다.',
                        ),
                      ).whenComplete(() {
                        // send inquiry
                        for (int i = 0; i < _maxFields; i++) {
                          print('${i}th field: "${_fieldTexts[i].text}"');
                        }
                        Navigator.pop(context);
                      }),
                    ),
                  );
                }
              },
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (_enable) ? WakColor.lightBlue : WakColor.grey300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '완료',
                  style: WakText.txt18M.copyWith(color: WakColor.grey25),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

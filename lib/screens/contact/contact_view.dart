import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/amplifyconfiguration.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/text_with_dot.dart';
import 'package:wakmusic/widgets/common/toast_msg.dart';
import 'package:wakmusic/widgets/show_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:mime/mime.dart';

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
  static late int _selectIdx;
  final int _maxFields = 4;
  late List<File> _files;
  late List<Future<Uint8List?>?> _thumbnails;
  late final List<TextEditingController> _fieldTexts;
  late final List<ScrollController> _scrolls;
  late final List<FocusNode> _focusNodes;
  late final List<bool> _checkList;

  @override
  void initState() {
    Amplify.isConfigured;
    // Amplify.configure('{}');
    Amplify.configure(amplifyconfig);
    super.initState();
    _selectIdx = -1;
    _files = [];
    _thumbnails = [];
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
    for (int i = 0; i < _files.length; i++) {
      _files[i].deleteSync();
    }
    _thumbnails.clear();
    for (int i = 0; i < _maxFields; i++) {
      _fieldTexts[i].dispose();
      _scrolls[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  Future<void> attach() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.media);
    FilePickerStatus.done;
    if (result != null) {
      File file = File(result.files.single.path!);
      final storedSize = _files.isNotEmpty
          ? _files.map((f) => f.lengthSync()).reduce((o, n) => o + n)
          : 0;
      if ((file.lengthSync() + storedSize) / (1024 * 1024) > 100) {
        showToastWidget(
          context: context,
          position: const StyledToastPosition(
            align: Alignment.bottomCenter,
            offset: 56,
          ),
          animation: StyledToastAnimation.slideFromBottomFade,
          reverseAnimation: StyledToastAnimation.fade,
          const ToastMsg(msg: '최대 파일 크기는 100MB입니다.'),
        );
        return;
      }
      setState(() {
        if (lookupMimeType(file.path)?.startsWith('image/') ?? false) {
          _thumbnails.add(null);
        } else {
          _thumbnails.add(VideoThumbnail.thumbnailData(video: file.path));
        }
        _files.add(file);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: () {
                      switch (_about) {
                        case ContactAbout.bug:
                          return _buildBug();
                        case ContactAbout.feature:
                          return _buildFeature();
                        case ContactAbout.addSong:
                          return _buildSong(true);
                        case ContactAbout.editSong:
                          return _buildSong(false);
                        case ContactAbout.chart:
                          return _buildChart();
                        case ContactAbout.select:
                          return _buildSelect();
                      }
                    }(),
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
              itemBuilder: (_, idx) {
                bool isSelected = (_selectIdx == idx);
                return _buildCheckButton(
                  onTap: () => setState(() {
                    _enable = !isSelected;
                    _selectIdx = (isSelected) ? -1 : idx;
                  }),
                  isSelected: isSelected,
                  btnText: ContactAbout.values.elementAt(idx).btnName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBug() {
    List<String> nickname = ['알려주기', '비공개', '가입안함'];
    return Column(
      children: [
        _buildForm(
          formIdx: 0,
          title: '겪으신 버그에 대해 설명해 주세요.',
          hasMaxLine: false,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '버그와 관련된 사진이나 영상을 첨부해 주세요.',
                  style: WakText.txt18M.copyWith(color: WakColor.grey900),
                  maxLines: 5,
                ),
              ),
              if (_files.isNotEmpty)
                Container(
                  height: 92,
                  padding: const EdgeInsets.only(top: 12),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _files.length,
                    itemBuilder: (context, idx) => Stack(
                      children: [
                        _buildImage(idx),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _files.removeAt(idx);
                              _thumbnails.removeAt(idx);
                            }),
                            child: SvgPicture.asset(
                              'assets/icons/ic_24_close_900.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 4),
                  ),
                ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    if (_files.length == 5) {
                      setState(() {
                        for (int i = 0; i < _maxFields; i++) {
                          _focusNodes[i].unfocus();
                        }
                      });
                      showToastWidget(
                        context: context,
                        position: const StyledToastPosition(
                          align: Alignment.bottomCenter,
                          offset: 56,
                        ),
                        animation: StyledToastAnimation.slideFromBottomFade,
                        reverseAnimation: StyledToastAnimation.fade,
                        const ToastMsg(msg: '최대 5개까지 첨부 가능합니다.'),
                      );
                    } else {
                      attach();
                    }
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(color: WakColor.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Spacer(flex: 23),
                        SvgPicture.asset(
                          'assets/icons/ic_32_camera.svg',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '첨부하기',
                          style: WakText.txt16M.copyWith(color: WakColor.blue),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(flex: 26),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '왁물원 닉네임을 알려주세요.',
                style: WakText.txt18M.copyWith(color: WakColor.grey900),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  int? choice = await showModal(
                        context: context,
                        builder: (_) => ChoiceModal(
                          choices: nickname,
                          initialChoice: _selectIdx,
                        ),
                      ) ??
                      _selectIdx;
                  if (_selectIdx != choice) {
                    setState(() {
                      _selectIdx = choice;
                      _fieldTexts[1].text =
                          (_selectIdx > 0) ? nickname[_selectIdx] : '';
                      _checkList[1] = (_selectIdx > 0);
                      _enable = _checkList
                          .sublist(0, _about.checkN)
                          .every((check) => check);
                    });
                  }
                },
                child: Container(
                  height: 52,
                  padding:
                      const EdgeInsets.symmetric(vertical: 13, horizontal: 11),
                  decoration: BoxDecoration(
                    border: Border.all(color: WakColor.grey200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: (_selectIdx == -1)
                            ? Text(
                                '선택',
                                style: WakText.txt16M
                                    .copyWith(color: WakColor.grey400),
                              )
                            : Text(
                                nickname[_selectIdx],
                                style: WakText.txt16M
                                    .copyWith(color: WakColor.grey900),
                              ),
                      ),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/icons/ic_24_arrow_bottom.svg',
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectIdx == 0) _buildForm(formIdx: 1),
              const SizedBox(height: 12),
              const TextWithDot(text: '닉네임을 알려주시면 피드백을 받으시는 데 도움이 됩니다.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(int idx) {
    if (_thumbnails[idx] == null) {
      return ExtendedImage.file(
        _files[idx],
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        shape: BoxShape.rectangle,
        border: Border.all(color: WakColor.grey100),
        borderRadius: BorderRadius.circular(8),
      );
    }
    Widget skeletonBox = SkeletonBox(
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: WakColor.grey200,
          border: Border.all(color: WakColor.grey100),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    return FutureBuilder(
      future: _thumbnails[idx],
      builder: (_, snapshot) => (snapshot.hasData)
          ? ExtendedImage.memory(
              snapshot.data!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              shape: BoxShape.rectangle,
              border: Border.all(color: WakColor.grey100),
              borderRadius: BorderRadius.circular(8),
              loadStateChanged: (state) {
                if (state.extendedImageLoadState != LoadState.completed) {
                  return skeletonBox;
                }
                return null;
              },
            )
          : skeletonBox,
    );
  }

  Widget _buildFeature() {
    return Column(
      children: [
        _buildForm(
          formIdx: 0,
          title: '제안해 주고 싶은 기능에 대해 설명해 주세요.',
          hasMaxLine: false,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '어떤 플랫폼과 관련된 기능인가요?',
                style: WakText.txt18M.copyWith(color: WakColor.grey900),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: GridView.builder(
                  itemCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 48,
                  ),
                  itemBuilder: (_, idx) {
                    bool isSelected = (_selectIdx == idx);
                    List<String> btnTexts = ['모바일 앱', 'PC 웹'];
                    return _buildCheckButton(
                      onTap: () => setState(() {
                        _fieldTexts[1].text = (isSelected) ? '' : btnTexts[idx];
                        _checkList[1] = !isSelected;
                        _enable = _checkList
                            .sublist(0, _about.checkN)
                            .every((check) => check);
                        _selectIdx = (isSelected) ? -1 : idx;
                      }),
                      isSelected: isSelected,
                      btnText: btnTexts[idx],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
      padding: EdgeInsets.all((title != null) ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              style: WakText.txt18M.copyWith(color: WakColor.grey900),
              maxLines: 5,
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

  Widget _buildCheckButton({
    void Function()? onTap,
    required bool isSelected,
    required String btnText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: (isSelected)
          ? Container(
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
                      btnText,
                      style: WakText.txt16M.copyWith(color: WakColor.blue),
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
            )
          : Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                border: Border.all(color: WakColor.grey200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                btnText,
                style: WakText.txt16L.copyWith(color: WakColor.grey900),
              ),
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
                _selectIdx = -1;
                _files = [];
                _thumbnails = [];
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
                  _selectIdx = ContactAbout.values.indexOf(_about);
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
                      posFunc: () async {
                        showModal(
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
                        });
                      },
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

class ChoiceModal extends StatelessWidget {
  const ChoiceModal({
    super.key,
    required this.choices,
    required this.initialChoice,
  });
  final List<String> choices;
  final int initialChoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
      child: Container(
        height: 228,
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: List.generate(
            3,
            (idx) {
              bool isSelected = (initialChoice == idx);
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, idx);
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        choices[idx],
                        style: (isSelected)
                            ? WakText.txt18M.copyWith(color: WakColor.grey900)
                            : WakText.txt18L.copyWith(color: WakColor.grey900),
                      ),
                      if (isSelected)
                        SvgPicture.asset(
                          'assets/icons/ic_24_checkbox.svg',
                          width: 24,
                          height: 24,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

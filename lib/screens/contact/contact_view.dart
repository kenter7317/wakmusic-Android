import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';

enum ContactAbout {
  bug('버그 제보'),
  feature('기능 제안'),
  addSong('노래 추가'),
  editSong('노래 수정'),
  chart('주간차트 영상'),
  select('문의하기');

  const ContactAbout(this.btnName);
  final String btnName;
}

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  ContactAbout _about = ContactAbout.select;
  bool _enable = false;
  int _selectIdx = ContactAbout.values.length - 1;

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
    return DismissibleView(
      onDismissed: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Header(
                type: HeaderType.close,
                headerTxt: _about.btnName,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 것 관련해서 문의주셨나요?',
          style: WakText.txt20M.copyWith(color: WakColor.grey900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48.0 * ((length + 1) ~/ 2) + 8.0 * (length ~/ 2),
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
                      height: 48,
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
                      height: 48,
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
    );
  }

  Widget _buildBug() {
    return Column();
  }

  Widget _buildFeature() {
    return Column();
  }

  Widget _buildSong(bool isAdd) {
    return Column();
  }

  Widget _buildChart() {
    return Column();
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
                  // call api
                  Navigator.pop(context);
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

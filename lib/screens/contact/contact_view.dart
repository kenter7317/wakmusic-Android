import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mailto/mailto.dart' show Mailto;
import 'package:provider/provider.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/utils/mail.dart';
import 'package:wakmusic/widgets/common/header.dart';
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
  static int _selectIdx = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildSelect(),
                ),
              ),
            ),
            _buildButton(),
          ],
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
            style: WakText.txt20M,
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
                return GestureDetector(
                  onTap: () => setState(() {
                    _enable = !isSelected;
                    _selectIdx = (isSelected) ? -1 : idx;
                  }),
                  child: _buildCheckButton(
                    isSelected: isSelected,
                    btnText: ContactAbout.values.elementAt(idx).btnName,
                  ),
                );
              },
            ),
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
    if (isSelected) {
      return Container(
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
      );
    }

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: WakColor.grey200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        btnText,
        style: WakText.txt16L,
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {
          if (_enable) {
            setState(() {
              _about = ContactAbout.values.elementAt(_selectIdx);
              _selectIdx = -1;
            });
            _submit(context.read<KeepViewModel>());
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

  Future<void> _submit(KeepViewModel viewModel) async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    String body = mail(
      _about,
      await viewModel.version,
      deviceInfo.model,
      deviceInfo.version.release,
      deviceInfo.version.sdkInt,
      viewModel.user.displayName,
    );

    final mailto = Mailto(
      to: [email],
      subject: _about.btnName,
      body: body,
    );

    launchUrl(Uri.parse('$mailto')).whenComplete(() => Navigator.pop(context));
  }
}

@Deprecated('suggest :: s3 -> mailto')
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
                        style: (isSelected) ? WakText.txt18M : WakText.txt18L,
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

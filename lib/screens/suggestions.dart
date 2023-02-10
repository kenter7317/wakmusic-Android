import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/screens/faq/faq_view.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/keep/policy.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';

class Suggestions extends StatelessWidget {
  const Suggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return DismissibleView(
      onDismissed: () => Navigator.pop(context),
      child: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double botPadding = WidgetsBinding.instance.window.viewPadding.bottom / WidgetsBinding.instance.window.devicePixelRatio;
    double height = MediaQuery.of(context).size.height - statusBarHeight - botPadding;
    double blankFactor;
    if (height >= 572) {
      blankFactor = 732 - height;
    } else {
      blankFactor = 160;
    }
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const Header(headerTxt: '건의사항'),
          Container(
            height: 196 + 32,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                _buildBtn(context, () { }, '버그 제보'),
                const SizedBox(height: 8),
                _buildBtn(context, () { }, '노래 추가, 수정 요청'),
                const SizedBox(height: 8),
                _buildBtn(
                  context, 
                  () { 
                    Navigator.push(
                      context,
                      pageRouteBuilder(page: const FAQView()),
                    );
                  }, 
                  '자주 묻는 질문'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_16_dot.svg',
                  width: 16,
                  height: 16,
                ),
                Expanded(
                  child: Text(
                    '왁타버스 뮤직 팀에 속한 모든 팀원들은 부아내비 (부려먹는 게 아니라 내가 비빈거다)라는 모토를 가슴에 새기고 일하고 있습니다.',
                    style: WakText.txt12L.copyWith(color: WakColor.grey500),
                    maxLines: 5,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 180 - blankFactor),
          const Policy(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBtn(BuildContext context, void Function()? onTap, String btnName) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          border: Border.all(color: WakColor.grey200.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          btnName,
          style: WakText.txt16M.copyWith(color: WakColor.grey900),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
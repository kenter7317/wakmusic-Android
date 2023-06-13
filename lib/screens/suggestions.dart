import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models_v2/scope.dart';
import 'package:wakmusic/repository/user_repo.dart';
import 'package:wakmusic/screens/contact/contact_view.dart';
import 'package:wakmusic/screens/faq/faq_view.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/screens/notice/notice_view.dart';
import 'package:wakmusic/screens/service_info/service_info_view.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/btn_with_icon.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/edit_btn.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/common/text_with_dot.dart';
import 'package:wakmusic/widgets/common/exitable.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';
import 'package:wakmusic/widgets/show_modal.dart';

class Suggestions extends StatelessWidget {
  const Suggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return DismissibleView(
      onDismissed: () {
        ExitScope.remove = ExitScope.suggestion;
        Navigator.pop(context);
      },
      child: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return Exitable(
      scopes: const [ExitScope.suggestion],
      onExitable: (scope) {
        if (scope == ExitScope.suggestion) {
          ExitScope.remove = ExitScope.suggestion;
          Navigator.pop(context);
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        ExitScope.remove = ExitScope.suggestion;
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                        'assets/icons/ic_32_arrow_left.svg',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '건의사항',
                      style: WakText.txt16M,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 20,
                    child: GestureDetector(
                      onTap: () async {
                        List<String> msgList = [
                          '회원탈퇴 신청을 하시겠습니까?',
                          '정말 탈퇴하시겠습니까?',
                          '회원탈퇴가 완료되었습니다.\n이용해 주셔서 감사합니다.'
                        ];
                        for (int i = 0; i < 3; i++) {
                          if (i == 2) {
                            final repo = UserRepository();
                            repo.removeUser(viewModel.user.platform);
                            viewModel.updateLoginStatus(LoginStatus.before);
                          }
                          bool? result = await showModal(
                            context: context,
                            builder: (_) => PopUp(
                              type: (i == 2)
                                  ? PopUpType.txtOneBtn
                                  : PopUpType.txtTwoBtn,
                              msg: msgList[i],
                            ),
                          ).whenComplete(() {
                            if (i == 2) Navigator.pop(context);
                          });
                          if (result != true) return;
                        }
                      },
                      child: const EditBtn(type: BtnType.edit, btnText: '회원탈퇴'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
                    height: 68 * 4 + 24,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      children: [
                        BtnWithIcon(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                              pageRouteBuilder(
                                page: const ContactView(),
                                offset: const Offset(0, 1),
                              ),
                            );
                          },
                          type: BtnSizeType.big,
                          iconName: 'ic_24_question',
                          btnText: '문의하기',
                        ),
                        const SizedBox(height: 8),
                        BtnWithIcon(
                          onTap: () {
                            Navigator.push(
                              context,
                              pageRouteBuilder(page: const FAQView()),
                            );
                          },
                          type: BtnSizeType.big,
                          iconName: 'ic_24_qna',
                          btnText: '자주 묻는 질문',
                        ),
                        const SizedBox(height: 8),
                        BtnWithIcon(
                          onTap: () {
                            Navigator.push(
                              context,
                              pageRouteBuilder(page: const NoticeView()),
                            );
                          },
                          type: BtnSizeType.big,
                          iconName: 'ic_24_noti',
                          btnText: '공지사항',
                        ),
                        const SizedBox(height: 8),
                        BtnWithIcon(
                          onTap: () {
                            Navigator.push(
                              context,
                              pageRouteBuilder(page: const ServiceInfoView()),
                            );
                          },
                          type: BtnSizeType.big,
                          iconName: 'ic_24_document_off',
                          btnText: '서비스 정보',
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: TextWithDot(
                        text:
                            '왁타버스 뮤직 팀에 속한 모든 팀원들은 부아내비 (부려먹는 게 아니라 내가 비빈거다)라는 모토를 가슴에 새기고 일하고 있습니다.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

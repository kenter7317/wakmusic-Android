import 'package:flutter/material.dart';
import 'package:wakmusic/models/faq.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/screens/faq/faq_view_model.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/tab_view.dart';

class FAQView extends StatelessWidget {
  const FAQView({super.key});

  @override
  Widget build(BuildContext context) {
    FAQViewModel viewModel = Provider.of<FAQViewModel>(context);
    return DismissibleView(
      onDismissed: () {
        viewModel.collapseAll();
        Navigator.pop(context);
      },
      child: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    FAQViewModel viewModel = Provider.of<FAQViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        viewModel.collapseAll();
        return true;
      },
      child: SafeArea(
        child: Column(
          children: [
            Header(onTap: () => viewModel.collapseAll(), headerTxt: '자주 묻는 질문'),
            Expanded(
              child: TabView(
                type: TabType.minTab,
                tabBarList: viewModel.categories,
                tabViewList: List.generate(
                  viewModel.categories.length,
                  (idx) => _buildTab(context, viewModel.categories[idx]),
                ),
                physics: const ClampingScrollPhysics(),
                listener: () => viewModel.collapseAll(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String category) {
    FAQViewModel viewModel = Provider.of<FAQViewModel>(context);
    List<FAQ> faqList = viewModel.faqLists[category]!;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: faqList.length,
      itemBuilder: (_, idx) => GestureDetector(
        onTap: () => viewModel.onTap(faqList[idx]),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 11),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: WakColor.grey200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faqList[idx].category,
                          style: WakText.txt12L.copyWith(color: WakColor.grey500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          faqList[idx].question,
                          style: WakText.txt16M.copyWith(color: WakColor.grey900),
                          maxLines: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedRotation(
                    turns: (faqList[idx].isExpanded) ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    child: SvgPicture.asset(
                      'assets/icons/ic_24_arrow_bottom.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.bottomCenter,
                heightFactor: (faqList[idx].isExpanded) ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  color: WakColor.grey200,
                  child: Text(
                    faqList[idx].description,
                    style: WakText.txt14MH.copyWith(color: WakColor.grey900),
                    maxLines: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

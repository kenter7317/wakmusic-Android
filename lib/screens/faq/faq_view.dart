import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/models_v2/faq.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/screens/faq/faq_view_model.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/tab_view.dart';
import 'package:wakmusic/widgets/common/exitable.dart';

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
      child: Scaffold(body: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    FAQViewModel viewModel = Provider.of<FAQViewModel>(context);
    return Exitable(
      scopes: const [ExitScope.openedPageRouteBuilder],
      onExitable: (scope) {
        if (scope == ExitScope.openedPageRouteBuilder) {
          viewModel.collapseAll();
          ExitScope.remove = ExitScope.openedPageRouteBuilder;
          Navigator.pop(context);
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            Header(
              type: HeaderType.back,
              onTap: () => viewModel.collapseAll(),
              headerTxt: '자주 묻는 질문',
            ),
            Expanded(
              child: FutureBuilder<void>(
                future: viewModel.getFAQ(),
                builder: (_, __) {
                  if (viewModel.categories.isEmpty) {
                    return TabSkeletonView(
                      type: TabType.minTab,
                      tabLength: 5,
                      tabViewList:
                          List.generate(5, (_) => _buildTab(context, null)),
                      physics: const ClampingScrollPhysics(),
                    );
                  }
                  return TabView(
                    type: TabType.minTab,
                    tabBarList: viewModel.categories.map((e) => e.name).toList(),
                    tabViewList: viewModel.categories
                        .map((e) => _buildTab(context, e))
                        .toList(),
                    physics: const ClampingScrollPhysics(),
                    listener: () => viewModel.collapseAll(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, Category? category) {
    if (category == null) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (_, __) => Container(
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
                    SkeletonText(wakTxtStyle: WakText.txt12L, width: 47),
                    const SizedBox(height: 2),
                    SkeletonText(wakTxtStyle: WakText.txt16M),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SkeletonBox(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: WakColor.grey200,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    FAQViewModel viewModel = Provider.of<FAQViewModel>(context);
    List<FAQ?> faqList = viewModel.faqLists[category]!;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: faqList.length,
      itemBuilder: (_, idx) {
        return GestureDetector(
          onTap: () => viewModel.onTap(faqList[idx]!),
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
                            faqList[idx]!.category.name,
                            style: WakText.txt12L
                                .copyWith(color: WakColor.grey500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            faqList[idx]!.question,
                            style: WakText.txt16M,
                            maxLines: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    AnimatedRotation(
                      turns: (faqList[idx]!.isExpanded) ? 0.5 : 0,
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
                  heightFactor: (faqList[idx]!.isExpanded) ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    color: WakColor.grey200,
                    child: Text(
                      faqList[idx]!.description,
                      style: WakText.txt14MH,
                      maxLines: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

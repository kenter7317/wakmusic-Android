import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wakmusic/models/notice.dart';
import 'package:wakmusic/screens/notice/notice_detail_view.dart';
import 'package:wakmusic/screens/notice/notice_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';

class NoticeView extends StatelessWidget {
  const NoticeView({super.key});

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
    NoticeViewModel viewModel = Provider.of<NoticeViewModel>(context);
    return SafeArea(
      child: Column(
        children: [
          const Header(
            type: HeaderType.back,
            headerTxt: '공지사항',
          ),
          Expanded(
            child: FutureBuilder<List<Notice>>(
              future: viewModel.noticeList,
              builder: (_, snapshot) => ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data?.length ?? 5,
                itemBuilder: (context, idx) =>
                    _buildNotice(context, snapshot.data?[idx]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice(BuildContext context, Notice? notice) {
    if (notice == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 60, 11),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: WakColor.grey200),
          ),
        ),
        child: Column(
          children: [
            SkeletonText(wakTxtStyle: WakText.txt16M),
            const SizedBox(height: 2),
            SizedBox(
              height: 18,
              child: Row(
                children: [
                  SkeletonText(wakTxtStyle: WakText.txt12L, width: 45),
                  const VerticalDivider(),
                  SkeletonText(wakTxtStyle: WakText.txt12L, width: 30),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          pageRouteBuilder(
            page: NoticeDetailView(notice: notice),
            offset: const Offset(0.0, 1.0),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 60, 11),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: WakColor.grey200),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: WakText.txt16M.copyWith(color: WakColor.grey900),
              maxLines: 10,
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 18,
              child: Row(
                children: [
                  Text(
                    DateFormat('yy.MM.dd').format(notice.createAt),
                    style: WakText.txt12L.copyWith(color: WakColor.grey500),
                  ),
                  const VerticalDivider(),
                  Text(
                    DateFormat('HH:mm').format(notice.createAt),
                    style: WakText.txt12L.copyWith(color: WakColor.grey500),
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

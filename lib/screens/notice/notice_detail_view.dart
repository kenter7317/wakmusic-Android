import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wakmusic/models_v2/notice.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';

class NoticeDetailView extends StatelessWidget {
  const NoticeDetailView({super.key, required this.notice});
  final Notice notice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Header(
              type: HeaderType.close,
              headerTxt: '공지사항',
            ),
            Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return true;
                },
                child: ListView(
                  children: [
                    _buildTitle(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        notice.mainText,
                        style:
                            WakText.txt14MH.copyWith(color: WakColor.grey900),
                        maxLines: 40,
                      ),
                    ),
                  ]
                      .followedBy(notice.images.map(
                        (image) => Padding(
                          padding: EdgeInsets.only(
                              bottom: (image != notice.images.last) ? 20 : 0),
                          child: ExtendedImage.network(
                            '${API.static.url}/notice/$image',
                            fit: BoxFit.cover,
                            loadStateChanged: (state) {
                              if (state.extendedImageLoadState !=
                                  LoadState.completed) {
                                return SkeletonBox(
                                  child: AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child:
                                          Container(color: WakColor.grey200)),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 60, 20),
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
            style: WakText.txt18M,
            maxLines: 20,
          ),
          const SizedBox(height: 3),
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
    );
  }
}

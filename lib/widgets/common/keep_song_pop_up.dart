import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/btn_with_icon.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/header.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/keep/bot_sheet.dart';
import 'package:wakmusic/widgets/keep/playlist_tile.dart';
import 'package:wakmusic/widgets/show_modal.dart';

class KeepSongPopUp extends StatelessWidget {
  const KeepSongPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return DismissibleView(
      onDismissed: () => Navigator.pop(context),
      direction: DismissiblePageDismissDirection.down,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Header(
                type: HeaderType.down,
                headerTxt: '보관함에 담기',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
                child: Row(
                  children: [
                    Text(
                      '담을곡',
                      style: WakText.txt14MH.copyWith(color: WakColor.grey900),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '00곡',
                      style: WakText.txt14MH.copyWith(color: WakColor.lightBlue),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: BtnWithIcon(
                  onTap: () async {
                    viewModel.createList(await showModal(
                      context: context,
                      builder: (_) => const BotSheet(
                        type: BotSheetType.createList,
                      ),
                    ));
                  },
                  type: BtnSizeType.small,
                  iconName: 'playadd_900',
                  btnText: '새 리스트 만들기',
                ),
              ),
              Expanded(
                child: (viewModel.playlists.isEmpty)
                  ? const ErrorInfo(errorMsg: '내 리스트가 없습니다.')
                  : ListView.builder(
                      itemCount: viewModel.playlists.length,
                      itemBuilder: (_, idx) => PlaylistTile(
                        playlist: viewModel.playlists[idx],
                        tileType: TileType.baseTile,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_playlist_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/edit_btn.dart';
import 'package:wakmusic/widgets/common/tab_view.dart';
import 'package:wakmusic/widgets/common/exitable.dart';

class KeepTabView extends StatefulWidget {
  const KeepTabView({
    super.key,
    required this.type,
    required this.tabBarList,
    required this.tabViewList,
    required this.onPause,
  });
  final TabType type;
  final List<String> tabBarList;
  final List<Widget> tabViewList;
  final Future<bool> Function()? onPause;

  @override
  State<KeepTabView> createState() => _KeepTabViewState();
}

class _KeepTabViewState extends State<KeepTabView>
    with TickerProviderStateMixin {
  late final int _length;
  late TabController _controller;
  int _prevIdx = 0;
  bool _play = false;

  @override
  void initState() {
    super.initState();
    _length = widget.tabBarList.length;
    _controller = TabController(length: _length, vsync: this);
    _controller.addListener(() {
      if (_controller.previousIndex != _controller.index) {
        if (widget.onPause != null && !_play) {
          _controller.index = _prevIdx;
        }
        _prevIdx = _controller.index;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    SelectPlaylistProvider selectedPlaylist =
        Provider.of<SelectPlaylistProvider>(context);
    SelectSongProvider selectedLike = Provider.of<SelectSongProvider>(context);
    NavProvider navProvider = Provider.of<NavProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    return Exitable(
      scopes: const [
        ExitScope.editMode,
        ExitScope.selectedSong,
        ExitScope.selectedPlaylist,
      ],
      onExitable: (scope) {
        if (scope == ExitScope.editMode) {
          ExitScope.remove = ExitScope.editMode;
          ExitScope.remove = ExitScope.selectedSong;
          ExitScope.remove = ExitScope.selectedPlaylist;
          if (_controller.index == 0) {
            viewModel.applyPlaylists(true);
            selectedPlaylist.clearList();
          } else {
            viewModel.applyLikes(true);
            selectedLike.clearList();
          }
          if (audioProvider.isEmpty) {
            navProvider.subSwitchForce(false);
          } else {
            navProvider.subChange(1);
          }
        }
      },
      child: DefaultTabController(
        length: _length,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 52,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: WakColor.grey200),
                    ),
                  ),
                ),
                TabBar(
                  controller: _controller,
                  indicatorColor: WakColor.lightBlue,
                  labelStyle: WakText.txt16B,
                  unselectedLabelStyle: WakText.txt16M,
                  labelColor: WakColor.grey900,
                  unselectedLabelColor: WakColor.grey400,
                  overlayColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  indicatorSize: widget.type.indicatorSize,
                  labelPadding: widget.type.labelPadding,
                  padding: widget.type.padding,
                  isScrollable: widget.type.isScrollable,
                  onTap: (idx) async {
                    if (widget.onPause == null &&
                        viewModel.playlists.isEmpty != viewModel.likes.isEmpty)
                      setState(() {});
                    if (widget.onPause != null && idx != _controller.index) {
                      if (await widget.onPause!()) {
                        _play = true;
                        _controller.index = idx;
                        _play = false;
                      }
                    }
                    if (audioProvider.isEmpty) {
                      navProvider.subSwitchForce(false);
                    } else {
                      navProvider.subChange(1);
                    }
                  },
                  tabs: List.generate(
                    _length,
                    (idx) => Container(
                      height: 34,
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                      child: Text(
                        widget.tabBarList[idx],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                if ((viewModel.playlists.isNotEmpty &&
                        _controller.index == 0) ||
                    (viewModel.likes.isNotEmpty && _controller.index == 1))
                  Positioned(
                    top: 19,
                    right: 20,
                    child: (widget.onPause != null)
                        ? GestureDetector(
                            onTap: () {
                              ExitScope.remove = ExitScope.editMode;
                              ExitScope.remove = ExitScope.selectedSong;
                              ExitScope.remove = ExitScope.selectedPlaylist;
                              if (_controller.index == 0) {
                                viewModel.applyPlaylists(true);
                                selectedPlaylist.clearList();
                              } else {
                                viewModel.applyLikes(true);
                                selectedLike.clearList();
                              }
                              if (audioProvider.isEmpty) {
                                navProvider.subSwitchForce(false);
                              } else {
                                navProvider.subChange(1);
                              }
                            },
                            child: const EditBtn(type: BtnType.done),
                          )
                        : GestureDetector(
                            onTap: () {
                              ExitScope.add = ExitScope.editMode;
                              viewModel.updateEditStatus(
                                  (_controller.index == 0)
                                      ? EditStatus.playlists
                                      : EditStatus.likes);
                            },
                            child: const EditBtn(type: BtnType.edit),
                          ),
                  ),
              ],
            ),
            Expanded(
              child: TabBarView(
                key: UniqueKey(),
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: widget.tabViewList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

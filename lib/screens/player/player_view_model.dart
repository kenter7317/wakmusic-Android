import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/services/api.dart';

import '../../style/colors.dart';
import '../../style/text_styles.dart';

enum ScrollState { scrolling, notScrolling }

class PlayerViewModel with ChangeNotifier {
  late final API _api;
  ScrollState _scrollState = ScrollState.notScrolling;
  final ScrollController _controller = ScrollController();
  SubtitleController? _lyrics;
  ScrollSnapList? _listView;

  ScrollState get scrollState => _scrollState;
  Widget get listView {
    if(_lyrics == null || _listView == null){
      return const CircularProgressIndicator();
    }else if(_lyrics!.subtitles.isEmpty){
      return Text(
        '가사가 존재하지 않습니다',
        style: WakText.txt14MH.copyWith(color: WakColor.grey500),
        textAlign: TextAlign.center,
      );
    }else{
      return _listView!;
    }
  }

  PlayerViewModel() {
    _api = API();
    getLyrics('fgSXAKsq-Vo');
    _controller.addListener(_scrollListener);
  }

  void updateScrollState(ScrollState state){
    _scrollState = state;
    notifyListeners();
  }

  Future<void> getLyrics(String id) async {
    _listView = null;
    _lyrics = await _api.getLyrics(id: id);
    _listView = ScrollSnapList(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      onItemFocus: (int) => {},
      itemSize: 24,
      itemBuilder: (context, index) {
        return Text(
          _lyrics!.subtitles[index].data,
          style: WakText.txt14MH.copyWith(color: WakColor.grey500),
          textAlign: TextAlign.center,
        );
      },
      itemCount: _lyrics!.subtitles.length,
      listController: _controller,
    );
    notifyListeners();
  }

  void _scrollListener(){
    if(_controller.position.userScrollDirection == ScrollDirection.forward
    || _controller.position.userScrollDirection == ScrollDirection.reverse){
      updateScrollState(ScrollState.scrolling);
    }else{
      updateScrollState(ScrollState.notScrolling);
    }
  }
}
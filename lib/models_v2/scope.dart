import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum ExitScope {
  @Bit(0x0001 | 1)
  searchDuring,

  @Bit(0x0002 | 2)
  editMode,

  @Bit(0x0004 | 4)
  selectedSong,

  @Bit(0x0008 | 8)
  selectedPlaylist,

  @Bit(0x0010 | 16)
  playerPlaylist,

  @Bit(0x0020 | 32)
  player,

  @Bit(0x0040 | 64)
  openedPageRouteBuilder,

  @Bit(0x0080 | 128)
  suggestion,

  @Bit(0x0100 | 256)
  artistDetail,

  @Bit(0x0200 | 512)
  searchAfter,

  @Bit(0x0400 | 1024)
  pageIsNotHome,

  @Bit(0x0800 | 2048)
  @Bit(0x1000 | 4096)
  @Bit(0x2000 | 8192)
  @Bit(0x4000 | 16384)
  @Bit(0x8000 | 32768)
  undefined;

  int get bit => pow(2, index).toInt();
  bool get contain => scope | bit == scope;

  static int _ = 0;
  static int get scope => _;
  static List<ExitScope> get scopes {
    return [if (_ != 0) ...values.where((e) => e.contain)];
  }

  static bool get exitable => _ == 0;

  static set add(ExitScope s) => _ |= s.bit;
  static set remove(ExitScope s) => _ &= ~s.bit;
  static set toggle(ExitScope s) => _ ^= s.bit;

  static final _controller = StreamController<ExitScope>.broadcast(sync: true);
  static Stream<ExitScope> get stream => _controller.stream;

  void pop() async => _controller.add(this);

  @Deprecated('use pop')
  Future<ExitScope?> close(BuildContext context) async {
    switch (this) {
      case searchDuring:
        // FocusManager.instance.primaryFocus?.unfocus();
        // Provider.of<SearchViewModel>(context, listen: false).updateStatus(
        //     searchAfter.contain ? SearchStatus.after : SearchStatus.before);
        return remove = this;
      case editMode:
        return remove = this;
      case selectedSong:
        return remove = this;
      case selectedPlaylist:
        return remove = this;
      case playerPlaylist:
        return remove = this;
      case player:
        return remove = this;
      case openedPageRouteBuilder:
        return remove = this;
      case suggestion:
        return remove = this;
      case artistDetail:
        return remove = this;
      case searchAfter:
        // Provider.of<SelectSongProvider>(context, listen: false).clearList();
        // Provider.of<SearchViewModel>(context, listen: false)
        //     .updateStatus(SearchStatus.before);
        return remove = this;
      case pageIsNotHome:
        return remove = this;
      default:
        return null;
    }
  }
}

// 표기 용도
class Bit {
  const Bit(this.bit);
  final int bit;
}

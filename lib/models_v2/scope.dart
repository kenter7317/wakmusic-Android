import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum ExitScope {
  @Bit(0x0001 | 1) // in_action
  searchDuring,

  @Bit(0x0002 | 2) // pending_action
  editMode,

  @Bit(0x0004 | 4) // pending_action
  selectedSong,

  @Bit(0x0008 | 8) // pending_action
  selectedPlaylist,

  @Bit(0x0010 | 16) // pending_action
  playerPlaylist,

  @Bit(0x0020 | 32) // pending_action
  player,

  @Bit(0x0040 | 64) // in_action
  ossDetail,

  @Bit(0x0080 | 128) // in_action
  ossLicense,

  @Bit(0x0100 | 256) // in_action
  openedPageRouteBuilder,

  @Bit(0x0200 | 512) // in_action
  suggestion,

  @Bit(0x0400 | 1024) // in_action
  artistDetail,

  @Bit(0x0800 | 2048)
  searchAfter,

  @Bit(0x1000 | 4096)
  pageIsNotHome,

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

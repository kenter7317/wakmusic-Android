import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/models/notice.dart';
import 'package:wakmusic/services/api.dart';

class NoticeViewModel with ChangeNotifier {
  late final API _api;
  late Future<List<Notice>> _noticeList;

  Future<List<Notice>> get noticeList => _noticeList;

  NoticeViewModel() {
    _api = API();
    getFAQ();
  }

  Future<void> getFAQ() async {
    _noticeList = _api.fetchNotice();
    notifyListeners();
  }
}
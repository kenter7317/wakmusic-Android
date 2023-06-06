import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/notice.dart';
import 'package:wakmusic/services/apis/api.dart';

class NoticeViewModel with ChangeNotifier {
  late Future<List<Notice>> _noticeList;

  Future<List<Notice>> get noticeList => _noticeList;

  NoticeViewModel() {
    getNotice();
  }

  Future<void> getNotice() async {
    _noticeList = API.notice.all;
    notifyListeners();
  }
}

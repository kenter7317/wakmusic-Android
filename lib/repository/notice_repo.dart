import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakmusic/models_v2/notice.dart';
import 'package:wakmusic/services/apis/api.dart';

class NoticeRepository {
  static const String prefsKey = 'hideNotice';

  NoticeRepository();

  Future<List<int>> getHideHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final history = [...?prefs.getString(prefsKey)?.split(',')];
    return history.map((h) => int.parse(h)).toList();
  }

  Future<List<Notice>> getNoticeDisplay() async {
    final notices = await API.notice.display;
    final history = await getHideHistory();
    _cleanup([...history]);

    return notices.where((n) => !history.contains(n.id)).toList();
  }

  Future<List<Notice>> getNoticeAll() async {
    final notices = await API.notice.all;
    return notices;
  }

  void hideNotice(Notice notice) async {
    final prefs = await SharedPreferences.getInstance();

    final prefix = prefs.getString(prefsKey) != null
        ? '${prefs.getString(prefsKey)},'
        : '';
    prefs.setString(prefsKey, '$prefix${notice.id}');
  }

  void _cleanup(List<int> history) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('hideTime') ?? 0;
    final now = DateTime.now();

    if (now.subtract(const Duration(days: 7)).millisecondsSinceEpoch <
        timestamp) return;

    prefs.setInt('hideTime', now.millisecondsSinceEpoch);
    if (timestamp != 0) {
      final notices = await getNoticeAll();
      prefs.setString(
        prefsKey,
        notices
            .where((n) => history.contains(n.id) && n.endAt.isAfter(now))
            .map((n) => '${n.id}')
            .reduce((o, n) => '$o,$n'),
      );
    }
  }
}

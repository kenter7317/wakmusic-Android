import 'package:wakmusic/services/apis/api.dart';

enum AppFlag {
  none(0),
  ok(1),
  event(2),
  updateInfo(3),
  updateRequired(4);

  const AppFlag(this.code);

  bool get restrict => {none, event, updateRequired}.contains(this);
  bool get isUpdate => {updateInfo, updateRequired}.contains(this);
  final int code;

  factory AppFlag.byCode(int code) {
    return values.singleWhere(
      (e) => e.code == code,
      orElse: () => none,
    );
  }
}

class AppVersion {
  final int major;
  final int minor;
  final int? patch;

  const AppVersion(
    this.major,
    this.minor, [
    this.patch,
  ]);

  factory AppVersion.parse(String str) {
    final raw = str.split('.');
    return AppVersion(
      int.parse(raw[0]),
      int.parse(raw[1]),
      (raw.length < 3) ? null : int.parse(raw[2]),
    );
  }

  @override
  String toString() => [major, minor, if (patch != null) patch].join('.');
}

class Event {
  final AppFlag flag;
  final String? title;
  final String? description;
  final AppVersion? version;

  const Event({
    required this.flag,
    this.title,
    this.description,
    this.version,
  })  : assert(flag != AppFlag.event || title != null),
        assert(flag == AppFlag.event || flag == AppFlag.ok || version != null);

  factory Event.fromJson(JSON json) {
    return Event(
      flag: AppFlag.byCode(json['flag']),
      title: json['title'],
      description: json['description'],
      version:
          json['version'] == null ? null : AppVersion.parse(json['version']),
    );
  }
}

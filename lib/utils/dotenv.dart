import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/utils/json.dart';

JSONType<String> get env => dotenv.env;

enum LaunchMode {
  release,
  debug;

  factory LaunchMode.byName(String name) {
    return values.singleWhere((e) => e.name == name, orElse: () => debug);
  }

  static LaunchMode get now => LaunchMode.byName(dotenv.get('LAUNCH_MODE'));

  static bool get isDebug => now == debug;
  static bool get isRelease => now == release;
}

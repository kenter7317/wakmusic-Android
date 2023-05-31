import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/enums/types.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class ChartsAPI extends API {
  @override
  String get url => dotenv.get('API_CHARTS');

  const ChartsAPI();

  Future<List<Song>> top({
    required ChartType type,
    int limit = 100,
  }) async {
    throw '';
  }

  Future<DateTime> get updatedTime async {
    final url = dotenv.get('API_UPDATED');

    throw '';
  }
}

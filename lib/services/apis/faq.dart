import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/faq.dart';
import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/services/apis/api.dart';

class FAQAPI extends API {
  @override
  String get url => dotenv.get('API_FAQ');

  const FAQAPI();

  Future<List<Category>> categories() async {
    throw '';
  }

  Future<List<FAQ>> list() async {
    throw '';
  }
}

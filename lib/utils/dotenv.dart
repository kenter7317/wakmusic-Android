import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/utils/json.dart';

JSONType<String> get env => dotenv.env;

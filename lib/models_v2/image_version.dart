import 'package:wakmusic/utils/json.dart';

class ImageVersion {
  final int round;
  final int square;

  const ImageVersion({
    this.round = 1,
    this.square = 1,
  });

  factory ImageVersion.fromJson(JSON json) {
    return ImageVersion(
      round: json['round'],
      square: json['square'],
    );
  }
}

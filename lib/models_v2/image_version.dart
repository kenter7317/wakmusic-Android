import 'package:wakmusic/utils/json.dart';

class ImageQuery {
  String get name => throw UnimplementedError();
  int get round => throw UnimplementedError();
  int get square => throw UnimplementedError();
  int get version => throw UnimplementedError();

  const ImageQuery();
}

class ImageVersion extends ImageQuery {
  @override
  final int round;

  @override
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

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

enum ThumbnailType {
  max('maxresdefault'),
  standard('sddefault'),
  high('hqdefault'),
  medium('mddefault'),
  def('default');

  final String filename;
  const ThumbnailType(this.filename);
}

ExtendedImage loadImage(
  String? songId,
  ThumbnailType type, {
  bool small = false,
  double borderRadius = 8,
}) {
  final link = 'https://i.ytimg.com/vi/$songId/${type.filename}.jpg';
  final wakThumbnail = ExtendedImage.asset(
    'assets/images/img_${small ? 40 : 81}_thumbnail.png',
    fit: BoxFit.cover,
  );

  if (songId == null || songId.isEmpty) {
    return wakThumbnail;
  }

  return ExtendedImage.network(
    link,
    fit: BoxFit.cover,
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.circular(borderRadius),
    loadStateChanged: (state) {
      if (state.extendedImageLoadState == LoadState.completed) return null;
      if (type == ThumbnailType.max) {
        return loadImage(songId, ThumbnailType.high);
      }
      return wakThumbnail;
    },
    cacheMaxAge: const Duration(days: 30),
  );
}

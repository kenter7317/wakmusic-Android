import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

LoadImage(String? songId) {

  List<String> links = [
    'https://i.ytimg.com/vi/$songId/maxresdefault.jpg',
    'https://i.ytimg.com/vi/$songId/hqdefault.jpg'
  ];

  if(songId != null && songId.isNotEmpty) {
    for(var i = 0; i < 2; ++i){
      try{
        return ExtendedImage.network(
          links[i],
          fit: BoxFit.cover,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          loadStateChanged: (state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                return Image.asset(
                  'assets/images/img_81_thumbnail.png',
                  fit: BoxFit.cover,
                );
              case LoadState.failed:
                throw Exception('max image loading failed');
              default:
                return null;
            }
          },
          cacheMaxAge: const Duration(days: 30),
        ).image;
      }catch(_) {
        continue;
      }
    }
  }

  return Image.asset(
    'assets/images/img_81_thumbnail.png',
    fit: BoxFit.cover
  ).image;
}

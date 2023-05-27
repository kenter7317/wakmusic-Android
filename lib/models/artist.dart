import 'dart:ui';

import 'package:wakmusic/services/api.dart';

class Artist {
  final String id;
  final String name;
  final String short;
  final String group;
  final String groupKr;
  final bool graduated;
  final String title;
  final String appTitle;
  final String description;
  final List<dynamic> colors;
  final String? youtube;
  final String? twitch;
  final String? instagram;
  final String roundImg;
  final int roundImgVer;
  final int squareImgVer;

  const Artist({
    required this.id,
    required this.name,
    required this.short,
    required this.group,
    required this.groupKr,
    required this.graduated,
    required this.title,
    required this.appTitle,
    required this.description,
    required this.colors,
    required this.youtube,
    required this.twitch,
    required this.instagram,
    required this.roundImg,
    required this.roundImgVer,
    required this.squareImgVer,
  });

  factory Artist.fromJson(Map<dynamic, dynamic> json) => Artist(
        id: json['id'],
        name: json['name'],
        short: json['short'],
        group: json['group'],
        groupKr: json['group_kr'],
        graduated: json['graduated'],
        title: json['title'],
        appTitle: json['app_title'],
        description: json['description'],
        colors: json['color'],
        youtube: json['youtube'],
        twitch: json['twitch'],
        instagram: json['instagram'],
        roundImgVer: json['image_round_version'],
        squareImgVer: json['image_square_version'],
        roundImg: '$staticBaseUrl/artist/round/${json['id']}.png'
            '?v=${json['image_round_version']}',
        // background: 'https://wakmusic.xyz/static/artist/big/${json['id']}.jpg',
      );
}

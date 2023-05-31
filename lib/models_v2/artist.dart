import 'dart:ui';

import 'package:wakmusic/models_v2/image_version.dart';
import 'package:wakmusic/services/apis/api.dart';

class Artist {
  final String id;
  final String name;
  final String short;
  final bool graduated;
  final String title;
  final String appTitle;
  final String description;
  final List<ArtistColor> colors;
  final String? youtube;
  final String? twitch;
  final String? instagram;
  final ArtistGroup group;
  final ImageVersion imageVersion;

  String get roundImage =>
      '${API.static.url}/artist/round/$id.png' '?v=${imageVersion.round}';

  const Artist({
    required this.id,
    required this.name,
    required this.short,
    required this.graduated,
    required this.title,
    required this.appTitle,
    required this.description,
    required this.colors,
    required this.youtube,
    required this.twitch,
    required this.instagram,
    required this.group,
    required this.imageVersion,
  });

  factory Artist.fromJson(JSON json) {
    return Artist(
      id: json['artistId'],
      name: json['name'],
      short: json['short'],
      graduated: json['graduated'],
      title: json['title'],
      appTitle: json['appTitle'],
      description: json['description'],
      colors: (json['color'] as List).map((e) {
        final temp = List<String>.from(e as List);
        return ArtistColor(
          color: Color(int.parse('0xFF${temp[0]}')),
          opacity: double.parse(temp[1]) * 0.6 / 100,
          stop: double.parse(temp[2]),
        );
      }).toList(),
      youtube: json['youtube'],
      twitch: json['twitch'],
      instagram: json['instagram'],
      group: ArtistGroup.fromJson(json['group'] as JSON),
      imageVersion: ImageVersion.fromJson(json['image'] as JSON),
    );
  }
}

class ArtistGroup {
  final String en;
  final String kr;

  const ArtistGroup({
    required this.en,
    required this.kr,
  });

  factory ArtistGroup.fromJson(JSON json) {
    return ArtistGroup(
      en: json['en'],
      kr: json['kr'],
    );
  }
}

class ArtistColor {
  final Color color;
  final double opacity;
  final double stop;

  const ArtistColor({
    required this.color,
    required this.opacity,
    required this.stop,
  });
}

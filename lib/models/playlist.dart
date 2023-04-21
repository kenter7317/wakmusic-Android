class Playlist {
  final String? key;
  final String title;
  final String? creator;
  final String image;
  final List<String> songlist;
  final int imageVersion;

  const Playlist({
    this.key,
    required this.title,
    this.creator,
    required this.image,
    required this.songlist,
    this.imageVersion = 1,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    key: json['key'],
    title: json['title'],
    creator: json['creator'],
    image: json['image'],
    songlist: (json['songlist'] as List).map((song) => song as String).toList(),
    imageVersion: json['image_version'],
  );
}

class Reclist extends Playlist{
  const Reclist({
    required super.title,
    required super.image,
    required super.songlist,
    super.imageVersion,
  });
}
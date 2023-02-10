class Playlist {
  final String? key;
  final String title;
  final String? creator;
  final String image;
  final List<String> songlist;

  const Playlist({
    this.key,
    required this.title,
    this.creator,
    required this.image,
    required this.songlist,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    key: json['key'],
    title: json['title'],
    creator: json['creator'],
    image: json['image'],
    songlist: (json['songlist'] as List).map((song) => song as String).toList(),
  );
}

class Reclist extends Playlist{
  const Reclist({
    required super.title,
    required super.image,
    required super.songlist,
  });
}
import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models_v2/artist.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class ArtistsViewModel with ChangeNotifier {
  late final Future<List<Artist>> _artistsList;
  late Artist _artist;
  //Map<AlbumType, Future<List<Song>>> _albums = {};
  final Map<AlbumType, List<Song>> _albums = {};
  late List<bool> _isLastAlbum;

  ArtistsViewModel() {
    getArtistsList();
  }

  Future<List<Artist>> get artistsList => _artistsList;
  Artist get artist => _artist;
  //Map<AlbumType, Future<List<Song>>> get albums => _albums;
  Map<AlbumType, List<Song>> get albums => _albums;
  List<bool> get isLastAlbum => _isLastAlbum;

  Future<void> getArtistsList() async {
    _artistsList = API.artist.list;
    notifyListeners();
  }

  Future<void> initAlbums() async {
    for (AlbumType type in AlbumType.values) {
      _albums[type] = await API.artist.albums(
        id: artist.id,
        sort: type,
        start: 0,
      );
    }
    notifyListeners();
  }

  Future<void> getAlbums(AlbumType type, int start) async {
    List<Song> curList = _albums[type]!;
    List<Song> addList = await API.artist.albums(
      id: artist.id,
      sort: type,
      start: start,
    );

    if (addList.isEmpty) {
      _isLastAlbum[type.index] = true;
    } else {
      curList.addAll(addList);
      _albums[type] = curList;
    }

    notifyListeners();
  }

  void setArtist(Artist artist) async {
    if (artist.id != _artist.id) {
      clear();
    }
    _artist = artist;
    _isLastAlbum = [false, false, false];
    await initAlbums();

    notifyListeners();
  }

  void clear() {
    _albums.clear();
    _isLastAlbum = List.generate(3, (index) => false);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models/artist.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/services/api.dart';

class ArtistsViewModel with ChangeNotifier {
  late final API _api;
  late final Future<List<Artist>> _artistsList;
  late Artist _artist;
  //Map<AlbumType, Future<List<Song>>> _albums = {};
  Map<AlbumType, List<Song>> _albums = {};
  late List<bool> _isLastAlbum;
  
  ArtistsViewModel() {
    _api = API();
    getArtistsList();
  }

  Future<List<Artist>> get artistsList => _artistsList;
  Artist get artist => _artist;
  //Map<AlbumType, Future<List<Song>>> get albums => _albums;
  Map<AlbumType, List<Song>> get albums => _albums;
  List<bool> get isLastAlbum => _isLastAlbum;

  Future<void> getArtistsList() async {
    _artistsList =  _api.fetchArtists();
    notifyListeners();
  }
  
  Future<void> initAlbums() async {
    for (AlbumType type in AlbumType.values) {
      //_albums[type] = _api.fetchAlbums(artist.id, type.eng, 0);
      _albums[type] = await _api.fetchAlbums(artist.id, type.eng, 0);
    }
    notifyListeners();
  }

  Future<void> getAlbums(AlbumType type, int start) async {
    List<Song> curList = _albums[type]!;
    List<Song> addList = await _api.fetchAlbums(artist.id, type.eng, start);
    
    if (addList.isEmpty) {
      _isLastAlbum[type.index] = true;
    } else {
      print(addList[0].title);
      print(_albums[type]!.length);
      curList.addAll(addList);
      _albums[type] = curList;
    }

    notifyListeners();
  }

  void setArtist(Artist artist) async {
    _artist = artist;
    _isLastAlbum = [false, false, false];
    await initAlbums();

    notifyListeners();
  }
}
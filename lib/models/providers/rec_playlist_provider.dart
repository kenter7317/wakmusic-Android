import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/services/api.dart';

class RecPlaylistProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _infoList = [
    {
      'title': '고멤가요제',
      'iconName': 'GomemSongFestival',
      'songList': ['', 'mLLvBeyKIUI']
    },
    {
      'title': '연말공모전',
      'iconName': 'Competition',
      'songList': ['', 'mLLvBeyKIUI', '0D7GPhsrXYo']
    },
    {
      'title': '상콘 OST',
      'iconName': 'situationalplay_OST',
      'songList': ['', 'mLLvBeyKIUI', '0D7GPhsrXYo', 'HXA9ZL8K5Js']
    },
    {
      'title': '힙합 SWAG',
      'iconName': 'Hiphop',
      'songList': [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c'
      ]
    },
    {
      'title': '캐롤',
      'iconName': 'carol',
      'songList': [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c',
        'z_FW8Tnj2z0'
      ]
    },
    {
      'title': '노동요',
      'iconName': 'worksong',
      'songList': [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c',
        'z_FW8Tnj2z0',
        'ybQ2nXaoPMQ'
      ]
    },
  ];
  late final API _api;
  late final List<Future<List<Song>>> _songLists;

  List<Map<String, dynamic>> get infoList => _infoList;
  List<Future<List<Song>>> get songLists => _songLists;

  RecPlaylistProvider() {
    _api = API();
    getList();
  }

  Future<void> getList() async {
    _songLists = _infoList.map((info) => _api.search(keyword: info['songList'].join(','), type: SearchType.ids)).toList();
    notifyListeners();
  }
}

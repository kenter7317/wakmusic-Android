import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models/playlist.dart';

class RecPlaylistProvider extends ChangeNotifier {
  /* no api yet to fetch RecPlaylist */
  final List<Reclist> _list = [
    const Reclist(
      title: '고멤가요제',
      image: '고멤가요제',
      iconName: 'GomemSongFestival',
      songlist: ['', ''],
    ),
    const Reclist(
      title: '연말공모전',
      image: '연말공모전',
      iconName: 'Competition',
      songlist: ['', 'mLLvBeyKIUI', '0D7GPhsrXYo'],
    ),
    const Reclist(
      title: '상콘 OST',
      image: '상콘OST',
      iconName: 'situationalplay_OST',
      songlist: ['', 'mLLvBeyKIUI', '0D7GPhsrXYo', 'HXA9ZL8K5Js'],
    ),
    const Reclist(
      title: '힙합 SWAG',
      image: '힙합',
      iconName: 'Hiphop',
      songlist: [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c'
      ],
    ),
    const Reclist(
      title: '캐롤',
      image: '캐롤',
      iconName: 'carol',
      songlist: [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c',
        'z_FW8Tnj2z0'
      ],
    ),
    const Reclist(
      title: '노동요',
      image: '노동요',
      iconName: 'worksong',
      songlist: [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c',
        'z_FW8Tnj2z0',
        'ybQ2nXaoPMQ'
      ],
    ),
  ];

  List<Reclist> get list => _list;
}
